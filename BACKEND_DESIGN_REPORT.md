# Puzzle Health - Backend Design Report

## Executive Summary

This document outlines the complete backend architecture for the Puzzle Health application, a Flutter-based health tracking system that collects data from iOS Health/Android Health Connect and provides personalized health insights and weekly goals.

**Key Requirements:**
- Store user health data from multiple categories (activity, vitals, sleep, body measurements)
- Generate and persist health baselines and targets
- Track user progress over time
- Support authentication and user profiles
- Provide REST API for mobile app

---

## Table of Contents

1. [System Architecture](#1-system-architecture)
2. [Database Design](#2-database-design)
3. [API Endpoints Specification](#3-api-endpoints-specification)
4. [Authentication & Security](#4-authentication--security)
5. [Data Flow & Processing](#5-data-flow--processing)
6. [Frontend Integration Points](#6-frontend-integration-points)
7. [Implementation Roadmap](#7-implementation-roadmap)
8. [Technology Stack Recommendations](#8-technology-stack-recommendations)

---

## 1. System Architecture

### 1.1 High-Level Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (iOS/Android)  │
└────────┬────────┘
         │ HTTPS/REST
         ↓
┌─────────────────┐
│   API Gateway   │
│  (Load Balancer)│
└────────┬────────┘
         │
         ↓
┌─────────────────────────────────────┐
│        Application Server           │
│  ┌──────────────────────────────┐  │
│  │   REST API Layer             │  │
│  │  - Auth Controller           │  │
│  │  - Health Data Controller    │  │
│  │  - Baseline Controller       │  │
│  │  - Target Controller         │  │
│  │  - Progress Controller       │  │
│  │  - Insight Controller        │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │   Business Logic Layer       │  │
│  │  - Health Analyzer Service   │  │
│  │  - Insight Generator Service │  │
│  │  - Target Calculator Service │  │
│  │  - Progress Tracker Service  │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │   Data Access Layer          │  │
│  │  - Repositories              │  │
│  │  - ORM/Query Builder         │  │
│  └──────────────────────────────┘  │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         ↓                 ↓
┌─────────────────┐ ┌──────────────┐
│   Primary DB    │ │  Redis Cache │
│  (PostgreSQL)   │ │  (Optional)  │
└─────────────────┘ └──────────────┘
```

### 1.2 Backend Components

**API Gateway/Load Balancer:**
- Handle SSL/TLS termination
- Rate limiting per user/IP
- Request routing to application servers
- DDoS protection

**Application Server:**
- RESTful API endpoints
- JWT token validation
- Business logic processing
- Data validation and sanitization
- Error handling and logging

**Database:**
- PostgreSQL (recommended) or MySQL
- Stores user data, health records, baselines, targets, progress
- Supports JSONB for flexible health data storage
- Proper indexing for time-series queries

**Cache Layer (Optional but Recommended):**
- Redis for session management
- Cache frequently accessed baselines
- Store temporary analysis results
- Rate limiting counters

---

## 2. Database Design

### 2.1 Entity Relationship Diagram

```
┌─────────────┐       ┌──────────────────┐       ┌─────────────────┐
│   Users     │◄──────┤  HealthDataPoints│       │  HealthBaselines│
│             │ 1   * │                  │       │                 │
│ - id        │       │ - id             │  ┌───►│ - id            │
│ - email     │       │ - user_id        │  │    │ - user_id       │
│ - password  │       │ - type           │  │    │ - created_at    │
│ - created_at│       │ - value          │  │    │ - analysis_from │
└──────┬──────┘       │ - unit           │  │    │ - analysis_to   │
       │              │ - source         │  │    │ - metrics       │
       │              │ - recorded_at    │  │    │ - patterns      │
       │              └──────────────────┘  │    └─────────────────┘
       │                                    │
       │              ┌──────────────────┐  │
       └──────────────┤  HealthTargets   │  │
                    * │                  │  │
                      │ - id             │  │
                      │ - user_id        │  │
                      │ - baseline_id    ├──┘
                      │ - target_steps   │
                      │ - target_type    │
                      │ - duration_days  │
                      │ - start_date     │
                      │ - end_date       │
                      │ - status         │
                      └──────────────────┘
                               │
                               │
                      ┌────────┴─────────┐
                      │  DailyProgress   │
                      │                  │
                      │ - id             │
                      │ - target_id      │
                      │ - date           │
                      │ - steps_achieved │
                      │ - on_track       │
                      │ - data_synced_at │
                      └──────────────────┘

┌──────────────────┐       ┌──────────────────┐
│  HealthInsights  │       │  UserSessions    │
│                  │       │                  │
│ - id             │       │ - id             │
│ - user_id        │       │ - user_id        │
│ - baseline_id    │       │ - token          │
│ - insight_type   │       │ - device_info    │
│ - category       │       │ - created_at     │
│ - message        │       │ - expires_at     │
│ - created_at     │       │ - last_active    │
└──────────────────┘       └──────────────────┘
```

### 2.2 Database Schema (PostgreSQL)

#### 2.2.1 Users Table
Stores user authentication and profile information.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'UTC',
    platform VARCHAR(20), -- 'ios' or 'android'
    health_data_source VARCHAR(50), -- 'apple_health' or 'health_connect'
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

#### 2.2.2 Health Data Points Table
Stores raw health data synced from devices.

```sql
CREATE TABLE health_data_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    data_type VARCHAR(50) NOT NULL, -- 'STEPS', 'HEART_RATE', 'SLEEP', etc.
    value NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- 'count', 'bpm', 'minutes', 'kg', etc.
    source_name VARCHAR(100), -- e.g., 'Apple Watch', 'Fitbit', 'Manual'
    source_id VARCHAR(255), -- Original ID from health platform
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL, -- When data was recorded
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- When synced to backend
    metadata JSONB, -- Additional flexible data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, data_type, recorded_at, source_id)
);

CREATE INDEX idx_health_data_user_type ON health_data_points(user_id, data_type);
CREATE INDEX idx_health_data_recorded_at ON health_data_points(recorded_at);
CREATE INDEX idx_health_data_user_recorded ON health_data_points(user_id, recorded_at);
CREATE INDEX idx_health_data_type_recorded ON health_data_points(data_type, recorded_at);
```

**Data Types Enumeration:**
- Activity: `STEPS`, `DISTANCE`, `ACTIVE_ENERGY`, `BASAL_ENERGY`, `FLIGHTS_CLIMBED`, `WORKOUT`
- Vitals: `HEART_RATE`, `RESTING_HEART_RATE`, `HEART_RATE_VARIABILITY`, `BLOOD_OXYGEN`, `BLOOD_PRESSURE_SYSTOLIC`, `BLOOD_PRESSURE_DIASTOLIC`, `RESPIRATORY_RATE`, `BODY_TEMPERATURE`, `BLOOD_GLUCOSE`
- Sleep: `SLEEP_SESSION`, `SLEEP_DEEP`, `SLEEP_LIGHT`, `SLEEP_REM`, `SLEEP_AWAKE`
- Body: `WEIGHT`, `HEIGHT`, `BMI`, `BODY_FAT_PERCENTAGE`, `LEAN_BODY_MASS`
- Nutrition: `WATER`, `NUTRITION`

#### 2.2.3 Health Baselines Table
Stores calculated health baselines over time periods.

```sql
CREATE TABLE health_baselines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    baseline_type VARCHAR(50) DEFAULT 'initial', -- 'initial', 'rolling', 'milestone'
    analysis_period_start DATE NOT NULL,
    analysis_period_end DATE NOT NULL,

    -- Activity Metrics
    avg_steps_per_day NUMERIC(10, 2),
    total_steps INTEGER,
    avg_calories_per_day NUMERIC(10, 2),
    avg_distance_per_day NUMERIC(10, 2),
    distance_unit VARCHAR(10) DEFAULT 'km',
    avg_floors_per_day NUMERIC(10, 2),
    workouts_per_week NUMERIC(5, 2),

    -- Vitals Metrics
    avg_heart_rate NUMERIC(6, 2),
    avg_resting_heart_rate NUMERIC(6, 2),
    avg_hrv NUMERIC(6, 2),
    avg_blood_oxygen NUMERIC(5, 2),
    avg_respiratory_rate NUMERIC(5, 2),

    -- Sleep Metrics
    avg_sleep_hours NUMERIC(5, 2),
    sleep_consistency_score NUMERIC(5, 2), -- 0-100
    avg_deep_sleep_percent NUMERIC(5, 2),
    avg_light_sleep_percent NUMERIC(5, 2),
    avg_rem_sleep_percent NUMERIC(5, 2),

    -- Body Metrics
    latest_weight NUMERIC(6, 2),
    weight_unit VARCHAR(10) DEFAULT 'kg',
    latest_height NUMERIC(6, 2),
    height_unit VARCHAR(10) DEFAULT 'cm',
    latest_bmi NUMERIC(5, 2),
    latest_body_fat_percent NUMERIC(5, 2),

    -- Pattern Analysis
    activity_pattern VARCHAR(50), -- 'consistent', 'sporadic', 'weekend_warrior', etc.
    step_variance NUMERIC(10, 2),
    active_days_per_week NUMERIC(3, 1),
    weekday_weekend_ratio NUMERIC(5, 2),

    -- Data Quality
    data_completeness_score NUMERIC(5, 2), -- 0-100
    days_with_data INTEGER,
    total_days_analyzed INTEGER,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_baselines_user ON health_baselines(user_id);
CREATE INDEX idx_baselines_created ON health_baselines(created_at DESC);
CREATE INDEX idx_baselines_user_created ON health_baselines(user_id, created_at DESC);
CREATE INDEX idx_baselines_type ON health_baselines(baseline_type);
```

#### 2.2.4 Health Targets Table
Stores user goals and targets.

```sql
CREATE TABLE health_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    baseline_id UUID REFERENCES health_baselines(id) ON DELETE SET NULL,

    target_metric VARCHAR(50) NOT NULL DEFAULT 'steps', -- 'steps', 'sleep', 'weight', etc.
    target_value NUMERIC(10, 2) NOT NULL,
    baseline_value NUMERIC(10, 2),
    increase_percentage NUMERIC(5, 2),

    target_type VARCHAR(50), -- 'maintain', 'gentle_increase', 'moderate_increase', 'aggressive_increase'
    duration_days INTEGER NOT NULL,

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'abandoned', 'failed'

    -- Goal Statement
    goal_statement TEXT, -- "Walk 5,500 steps daily this week"
    constraint_explanation TEXT, -- "No running, jumping, or gym workouts"

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_targets_user ON health_targets(user_id);
CREATE INDEX idx_targets_status ON health_targets(status);
CREATE INDEX idx_targets_dates ON health_targets(start_date, end_date);
CREATE INDEX idx_targets_user_active ON health_targets(user_id, status) WHERE status = 'active';
```

#### 2.2.5 Daily Progress Table
Tracks daily progress toward targets.

```sql
CREATE TABLE daily_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES health_targets(id) ON DELETE CASCADE,
    progress_date DATE NOT NULL,

    steps_achieved INTEGER,
    target_steps INTEGER,
    steps_remaining INTEGER,
    on_track BOOLEAN,

    -- Additional metrics
    calories_burned NUMERIC(10, 2),
    distance_covered NUMERIC(10, 2),
    active_minutes INTEGER,

    -- Sleep tracking (if applicable)
    sleep_hours NUMERIC(5, 2),

    data_synced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, target_id, progress_date)
);

CREATE INDEX idx_progress_target ON daily_progress(target_id);
CREATE INDEX idx_progress_date ON daily_progress(progress_date DESC);
CREATE INDEX idx_progress_user_date ON daily_progress(user_id, progress_date DESC);
CREATE INDEX idx_progress_target_date ON daily_progress(target_id, progress_date);
```

#### 2.2.6 Health Insights Table
Stores generated insights shown to users.

```sql
CREATE TABLE health_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    baseline_id UUID REFERENCES health_baselines(id) ON DELETE SET NULL,
    target_id UUID REFERENCES health_targets(id) ON DELETE SET NULL,

    insight_type VARCHAR(50) NOT NULL, -- 'honest', 'neutral', 'positive', 'curious', 'data_quality'
    category VARCHAR(50) NOT NULL, -- 'steps', 'sleep', 'heart_rate', 'pattern', etc.

    primary_message TEXT NOT NULL,
    secondary_message TEXT,

    numeric_value NUMERIC(10, 2),
    value_unit VARCHAR(20),

    icon_name VARCHAR(50),
    metadata JSONB,

    shown_to_user BOOLEAN DEFAULT FALSE,
    shown_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_insights_user ON health_insights(user_id);
CREATE INDEX idx_insights_baseline ON health_insights(baseline_id);
CREATE INDEX idx_insights_created ON health_insights(created_at DESC);
CREATE INDEX idx_insights_shown ON health_insights(shown_to_user);
```

#### 2.2.7 User Sessions Table
Manages authentication sessions.

```sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    access_token VARCHAR(500) NOT NULL UNIQUE,
    refresh_token VARCHAR(500) UNIQUE,

    device_info JSONB, -- {platform, os_version, app_version, device_model}
    fcm_token VARCHAR(500), -- For push notifications

    ip_address INET,
    user_agent TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    is_revoked BOOLEAN DEFAULT FALSE,
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_token ON user_sessions(access_token);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);
CREATE INDEX idx_sessions_active ON user_sessions(user_id, is_revoked) WHERE is_revoked = FALSE;
```

#### 2.2.8 Audit Log Table (Optional but Recommended)
Tracks important events for debugging and compliance.

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    action VARCHAR(100) NOT NULL, -- 'login', 'data_sync', 'baseline_created', etc.
    resource_type VARCHAR(50), -- 'user', 'baseline', 'target', etc.
    resource_id UUID,

    details JSONB,
    ip_address INET,
    user_agent TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```

### 2.3 Data Retention Policies

**Health Data Points:**
- Keep raw data for 2 years
- Archive older data to cold storage
- Aggregated data in baselines retained indefinitely

**User Sessions:**
- Active sessions expire after 30 days
- Revoked sessions deleted after 90 days

**Audit Logs:**
- Keep for 1 year minimum
- Compliance requirements may require longer retention

---

## 3. API Endpoints Specification

### 3.1 Authentication Endpoints

#### POST /api/v1/auth/register
Register a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "full_name": "John Doe",
  "platform": "ios",
  "timezone": "America/New_York"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "full_name": "John Doe",
      "created_at": "2025-02-01T10:00:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
      "expires_in": 2592000
    }
  }
}
```

#### POST /api/v1/auth/login
Authenticate user and receive access token.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "device_info": {
    "platform": "ios",
    "os_version": "17.2",
    "app_version": "1.0.0",
    "device_model": "iPhone 15 Pro"
  },
  "fcm_token": "fNY6gK8..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "full_name": "John Doe",
      "onboarding_completed": false
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
      "expires_in": 2592000
    }
  }
}
```

#### POST /api/v1/auth/refresh
Refresh access token using refresh token.

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 2592000
  }
}
```

#### POST /api/v1/auth/logout
Revoke current session.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### 3.2 Health Data Endpoints

#### POST /api/v1/health/sync
Bulk sync health data from device.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json
```

**Request:**
```json
{
  "data_points": [
    {
      "type": "STEPS",
      "value": 8543,
      "unit": "count",
      "source_name": "Apple Watch",
      "source_id": "com.apple.health:steps:123456",
      "recorded_at": "2025-02-01T23:59:59Z"
    },
    {
      "type": "HEART_RATE",
      "value": 72,
      "unit": "bpm",
      "source_name": "Apple Watch",
      "source_id": "com.apple.health:hr:123457",
      "recorded_at": "2025-02-01T14:30:00Z"
    },
    {
      "type": "SLEEP_SESSION",
      "value": 450,
      "unit": "minutes",
      "source_name": "iPhone",
      "source_id": "com.apple.health:sleep:123458",
      "recorded_at": "2025-02-01T07:00:00Z",
      "metadata": {
        "sleep_stages": {
          "deep": 90,
          "light": 240,
          "rem": 120
        }
      }
    }
  ],
  "sync_timestamp": "2025-02-01T10:00:00Z"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "synced_count": 3,
    "skipped_count": 0,
    "failed_count": 0,
    "sync_id": "550e8400-e29b-41d4-a716-446655440001"
  }
}
```

#### GET /api/v1/health/data
Retrieve user's health data with filters.

**Query Parameters:**
- `types`: Comma-separated data types (e.g., `STEPS,HEART_RATE`)
- `start_date`: ISO date (e.g., `2025-01-01`)
- `end_date`: ISO date (e.g., `2025-01-31`)
- `aggregation`: `daily`, `weekly`, `monthly` (optional)
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 100, max: 1000)

**Example Request:**
```
GET /api/v1/health/data?types=STEPS&start_date=2025-01-01&end_date=2025-01-31&aggregation=daily
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "data_points": [
      {
        "date": "2025-01-01",
        "type": "STEPS",
        "value": 7543,
        "unit": "count",
        "source": "Apple Watch"
      },
      {
        "date": "2025-01-02",
        "type": "STEPS",
        "value": 8234,
        "unit": "count",
        "source": "Apple Watch"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_items": 31,
      "items_per_page": 100
    }
  }
}
```

---

### 3.3 Baseline Endpoints

#### POST /api/v1/baselines/analyze
Trigger baseline analysis for a date range.

**Request:**
```json
{
  "start_date": "2025-01-01",
  "end_date": "2025-01-30",
  "baseline_type": "initial"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "baseline": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "baseline_type": "initial",
      "analysis_period_start": "2025-01-01",
      "analysis_period_end": "2025-01-30",
      "metrics": {
        "activity": {
          "avg_steps_per_day": 6234,
          "total_steps": 186820,
          "avg_calories_per_day": 452,
          "workouts_per_week": 2.5
        },
        "vitals": {
          "avg_heart_rate": 72,
          "avg_resting_heart_rate": 58,
          "avg_hrv": 45.2
        },
        "sleep": {
          "avg_sleep_hours": 7.2,
          "sleep_consistency_score": 78,
          "deep_sleep_percent": 20,
          "light_sleep_percent": 55,
          "rem_sleep_percent": 25
        },
        "body": {
          "latest_weight": 75.5,
          "weight_unit": "kg",
          "latest_bmi": 23.4
        }
      },
      "patterns": {
        "activity_pattern": "consistent",
        "step_variance": 1234.5,
        "active_days_per_week": 6.2,
        "weekday_weekend_ratio": 1.05
      },
      "data_quality": {
        "data_completeness_score": 92,
        "days_with_data": 28,
        "total_days_analyzed": 30
      },
      "created_at": "2025-02-01T10:00:00Z"
    }
  }
}
```

#### GET /api/v1/baselines
Get user's baselines.

**Query Parameters:**
- `type`: Filter by baseline type (initial, rolling, milestone)
- `limit`: Number of results (default: 10)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "baselines": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440002",
        "baseline_type": "initial",
        "analysis_period_start": "2025-01-01",
        "analysis_period_end": "2025-01-30",
        "avg_steps_per_day": 6234,
        "activity_pattern": "consistent",
        "created_at": "2025-02-01T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_items": 1
    }
  }
}
```

#### GET /api/v1/baselines/:id
Get specific baseline details.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "baseline": {
      // Full baseline object as shown in POST /baselines/analyze
    }
  }
}
```

#### GET /api/v1/baselines/latest
Get user's most recent baseline.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "baseline": {
      // Full baseline object
    }
  }
}
```

---

### 3.4 Target Endpoints

#### POST /api/v1/targets
Create a new health target/goal.

**Request:**
```json
{
  "baseline_id": "550e8400-e29b-41d4-a716-446655440002",
  "target_metric": "steps",
  "target_value": 7500,
  "target_type": "gentle_increase",
  "duration_days": 7,
  "start_date": "2025-02-03",
  "goal_statement": "Walk 7,500 steps daily this week",
  "constraint_explanation": "No running, jumping, or gym workouts. Walking only."
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "target": {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "baseline_id": "550e8400-e29b-41d4-a716-446655440002",
      "target_metric": "steps",
      "target_value": 7500,
      "baseline_value": 6234,
      "increase_percentage": 20.3,
      "target_type": "gentle_increase",
      "duration_days": 7,
      "start_date": "2025-02-03",
      "end_date": "2025-02-09",
      "status": "active",
      "goal_statement": "Walk 7,500 steps daily this week",
      "constraint_explanation": "No running, jumping, or gym workouts. Walking only.",
      "created_at": "2025-02-01T10:00:00Z"
    }
  }
}
```

#### GET /api/v1/targets/active
Get user's current active target.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "target": {
      // Full target object
    },
    "progress": {
      "days_completed": 3,
      "total_days": 7,
      "on_track": true,
      "completion_percentage": 42.86
    }
  }
}
```

#### GET /api/v1/targets/:id
Get specific target details.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "target": {
      // Full target object
    }
  }
}
```

#### PATCH /api/v1/targets/:id
Update target status or details.

**Request:**
```json
{
  "status": "completed"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "target": {
      // Updated target object
      "status": "completed",
      "completed_at": "2025-02-09T23:59:59Z"
    }
  }
}
```

#### GET /api/v1/targets/history
Get user's past targets.

**Query Parameters:**
- `status`: Filter by status (completed, abandoned, failed)
- `page`: Page number
- `limit`: Items per page (default: 20)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "targets": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440003",
        "target_value": 7500,
        "duration_days": 7,
        "status": "completed",
        "start_date": "2025-01-27",
        "end_date": "2025-02-02",
        "goal_statement": "Walk 7,500 steps daily this week",
        "completion_percentage": 100,
        "avg_achievement": 7823
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 48
    }
  }
}
```

---

### 3.5 Progress Endpoints

#### POST /api/v1/progress/daily
Record or update daily progress.

**Request:**
```json
{
  "target_id": "550e8400-e29b-41d4-a716-446655440003",
  "progress_date": "2025-02-01",
  "steps_achieved": 7823,
  "target_steps": 7500,
  "on_track": true,
  "calories_burned": 485,
  "distance_covered": 6.2,
  "active_minutes": 95
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "progress": {
      "id": "550e8400-e29b-41d4-a716-446655440004",
      "target_id": "550e8400-e29b-41d4-a716-446655440003",
      "progress_date": "2025-02-01",
      "steps_achieved": 7823,
      "target_steps": 7500,
      "steps_remaining": 0,
      "on_track": true,
      "updated_at": "2025-02-01T23:59:59Z"
    }
  }
}
```

#### GET /api/v1/progress/today
Get today's progress for active target.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "progress": {
      "progress_date": "2025-02-01",
      "steps_achieved": 5234,
      "target_steps": 7500,
      "steps_remaining": 2266,
      "on_track": false,
      "percentage_complete": 69.8
    },
    "target": {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "goal_statement": "Walk 7,500 steps daily this week",
      "days_completed": 3,
      "total_days": 7
    }
  }
}
```

#### GET /api/v1/progress/target/:target_id
Get all progress for a specific target.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "target": {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "target_value": 7500,
      "duration_days": 7,
      "start_date": "2025-02-03",
      "end_date": "2025-02-09"
    },
    "daily_progress": [
      {
        "date": "2025-02-03",
        "steps_achieved": 7823,
        "on_track": true
      },
      {
        "date": "2025-02-04",
        "steps_achieved": 6934,
        "on_track": false
      }
    ],
    "summary": {
      "avg_steps": 7378,
      "days_on_track": 5,
      "days_off_track": 2,
      "completion_rate": 71.4
    }
  }
}
```

---

### 3.6 Insight Endpoints

#### GET /api/v1/insights
Get insights for the user.

**Query Parameters:**
- `baseline_id`: Filter by baseline
- `category`: Filter by category (steps, sleep, heart_rate, pattern)
- `shown`: Boolean filter (true = already shown, false = not yet shown)
- `limit`: Number of results (default: 10)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "insights": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "insight_type": "honest",
        "category": "steps",
        "primary_message": "You averaged 6,234 steps over the last 30 days",
        "secondary_message": null,
        "numeric_value": 6234,
        "value_unit": "steps/day",
        "shown_to_user": false,
        "created_at": "2025-02-01T10:00:00Z"
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440006",
        "insight_type": "neutral",
        "category": "pattern",
        "primary_message": "You're already moving consistently",
        "secondary_message": "We're focusing on consistency, not intensity",
        "shown_to_user": false,
        "created_at": "2025-02-01T10:00:05Z"
      }
    ]
  }
}
```

#### PATCH /api/v1/insights/:id/mark-shown
Mark an insight as shown to the user.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "insight": {
      "id": "550e8400-e29b-41d4-a716-446655440005",
      "shown_to_user": true,
      "shown_at": "2025-02-01T10:05:00Z"
    }
  }
}
```

---

### 3.7 User Profile Endpoints

#### GET /api/v1/user/profile
Get user profile information.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "full_name": "John Doe",
      "platform": "ios",
      "health_data_source": "apple_health",
      "onboarding_completed": true,
      "created_at": "2025-01-01T10:00:00Z"
    }
  }
}
```

#### PATCH /api/v1/user/profile
Update user profile.

**Request:**
```json
{
  "full_name": "John Smith",
  "timezone": "America/Los_Angeles"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      // Updated user object
    }
  }
}
```

#### PATCH /api/v1/user/onboarding
Mark onboarding as completed.

**Request:**
```json
{
  "completed": true
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "onboarding_completed": true
  }
}
```

#### DELETE /api/v1/user/account
Delete user account and all associated data.

**Request:**
```json
{
  "confirm": "DELETE"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Account deleted successfully"
}
```

---

### 3.8 Error Response Format

All error responses follow this format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

**Common Error Codes:**
- `VALIDATION_ERROR` (400) - Invalid request data
- `UNAUTHORIZED` (401) - Authentication required or token invalid
- `FORBIDDEN` (403) - Insufficient permissions
- `NOT_FOUND` (404) - Resource not found
- `CONFLICT` (409) - Resource conflict (e.g., duplicate email)
- `UNPROCESSABLE_ENTITY` (422) - Business logic validation failed
- `RATE_LIMIT_EXCEEDED` (429) - Too many requests
- `INTERNAL_SERVER_ERROR` (500) - Server error

---

## 4. Authentication & Security

### 4.1 Authentication Flow

**JWT-Based Authentication:**
1. User registers or logs in
2. Server generates JWT access token (30-day expiration)
3. Server generates refresh token (90-day expiration)
4. Client stores both tokens securely
5. Client includes access token in Authorization header for all requests
6. On token expiration, client uses refresh token to get new access token

**JWT Payload Structure:**
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "iat": 1706778000,
  "exp": 1709370000,
  "type": "access"
}
```

### 4.2 Security Best Practices

**Password Security:**
- Minimum 8 characters
- Require uppercase, lowercase, number
- Hash with bcrypt (cost factor 12+)
- Implement password reset flow via email

**Token Security:**
- Use strong secret keys (256-bit minimum)
- Rotate secret keys periodically
- Store refresh tokens hashed in database
- Implement token blacklisting for logout

**API Security:**
- HTTPS/TLS 1.3 only
- Rate limiting per user/IP
- Request validation and sanitization
- SQL injection prevention (use parameterized queries)
- XSS prevention (sanitize inputs)
- CORS configuration (whitelist mobile app)

**Data Privacy:**
- Encrypt sensitive data at rest
- Anonymize data in logs
- Implement data retention policies
- GDPR/CCPA compliance for data deletion
- User consent for health data processing

### 4.3 Rate Limiting

**Per User:**
- Auth endpoints: 10 requests/minute
- Sync endpoint: 20 requests/hour
- General API: 100 requests/minute

**Per IP (unauthenticated):**
- Register: 5 requests/hour
- Login: 10 requests/hour

### 4.4 Data Access Control

**Principle: Users can only access their own data**
- All endpoints require authentication
- Filter all queries by authenticated user_id
- Validate resource ownership before operations
- Log all data access for audit

---

## 5. Data Flow & Processing

### 5.1 Health Data Sync Flow

```
Flutter App
    │
    │ 1. Fetch health data from device (last 30 days)
    │    HealthService.fetchLastNDays(30)
    │
    │ 2. Remove duplicates locally
    │    HealthService.removeDuplicates()
    │
    │ 3. Format data points for API
    │    Convert HealthDataPoint → JSON
    │
    ↓
POST /api/v1/health/sync
    │
    │ 4. Validate request data
    │    - Check data types
    │    - Validate values/units
    │    - Check date ranges
    │
    │ 5. Deduplicate against existing data
    │    - Match by (user_id, type, recorded_at, source_id)
    │    - Skip duplicates
    │
    │ 6. Bulk insert new data points
    │    - Batch INSERT statements
    │    - Transaction for consistency
    │
    │ 7. Return sync results
    │    - Synced count
    │    - Skipped count
    │    - Failed count
    │
    ↓
Database (health_data_points table)
```

### 5.2 Baseline Analysis Flow

```
Trigger: User completes onboarding OR scheduled job (weekly)
    │
    │ 1. Query health data for date range
    │    SELECT * FROM health_data_points
    │    WHERE user_id = ? AND recorded_at BETWEEN ? AND ?
    │
    ↓
HealthAnalyzer Service
    │
    │ 2. Process Activity Metrics
    │    - Group steps by date, SUM daily
    │    - Calculate avg_steps_per_day
    │    - Calculate total_steps, calories, distance
    │
    │ 3. Process Vitals
    │    - Average heart rates
    │    - Calculate HRV, SpO2 averages
    │
    │ 4. Process Sleep Data
    │    - Average sleep duration
    │    - Calculate consistency score (variance)
    │    - Sleep stage percentages
    │
    │ 5. Identify Patterns
    │    - Calculate step variance
    │    - Count active days per week
    │    - Weekday vs weekend ratio
    │    - Classify pattern type
    │
    │ 6. Calculate data completeness
    │    - Days with data / total days * 100
    │
    ↓
POST /api/v1/baselines/analyze
    │
    │ 7. Save baseline to database
    │    INSERT INTO health_baselines
    │
    ↓
Database (health_baselines table)
    │
    ↓
InsightGenerator Service
    │
    │ 8. Generate insights from baseline
    │    - Primary: Average steps message
    │    - Secondary: Pattern constraint
    │    - Type: honest/neutral/positive based on values
    │
    │ 9. Save insights to database
    │    INSERT INTO health_insights
    │
    ↓
Return baseline + insights to app
```

### 5.3 Target Creation & Progress Tracking Flow

```
1. User completes onboarding with baseline
    ↓
2. App or backend generates target
    - Based on baseline avg_steps_per_day
    - Calculate achievable increase (5-30%)
    - Set duration (7 days default)
    - Create goal statement
    ↓
POST /api/v1/targets
    - Save target to health_targets table
    - Status: active
    ↓
3. Daily health data sync
    ↓
POST /api/v1/health/sync
    ↓
4. Background job: Calculate daily progress
    - Query today's steps from health_data_points
    - Compare to target value
    - Determine on_track status
    - UPDATE or INSERT into daily_progress
    ↓
5. App fetches today's status
    ↓
GET /api/v1/progress/today
    - Return steps_achieved, steps_remaining, on_track
    ↓
6. Display on HomePage
    - "You need 2,266 more steps today"
    - OR "You're on track (7,823 steps)"
    ↓
7. Week ends
    ↓
PATCH /api/v1/targets/:id {status: "completed"}
    - Calculate final achievement percentage
    - Generate new rolling baseline if successful
    - Create next target if desired
```

### 5.4 Background Jobs

**Daily Jobs:**
- Calculate daily progress for all active targets
- Send push notifications for off-track users (optional)
- Clean up expired sessions

**Weekly Jobs:**
- Generate rolling baselines for active users
- Archive completed targets
- Generate weekly summary reports

**Monthly Jobs:**
- Data cleanup and archival
- Generate monthly health reports
- Audit log cleanup

---

## 6. Frontend Integration Points

### 6.1 Onboarding Flow Integration

**Step 1: OnboardingRevealPage**
- No backend integration needed
- Pure UI presentation

**Step 2: OnboardingHealthPermissionPage**
- Request device health permissions (local)
- No backend call yet

**Step 3: OnboardingMagicPage**
- **Frontend:** Fetch last 30 days of health data using HealthService
- **Frontend:** Remove duplicates locally
- **Backend Call:** `POST /api/v1/health/sync` - Send all health data
- **Backend Call:** `POST /api/v1/baselines/analyze` with date range
- **Backend Returns:** HealthBaseline with metrics and patterns
- **Frontend:** Store baseline locally (optional) or fetch when needed

**Step 4: OnboardingInsightsPage**
- **Backend Call:** `GET /api/v1/insights?shown=false&limit=2`
- **Backend Returns:** List of 1-2 generated insights
- **Frontend:** Display insights with animations
- **Backend Call:** `PATCH /api/v1/insights/:id/mark-shown` for each shown
- **Backend Call:** `PATCH /api/v1/user/onboarding {completed: true}`
- **Frontend:** Navigate to dashboard

### 6.2 HomePage Integration

**Current Mock Data to Replace:**
```dart
// MOCK DATA - Replace with API calls
final weeklyGoal = "Walk 7,500 steps daily this week";
final constraint = "No running, jumping, or gym workouts";
final daysCompleted = 3;
final totalDays = 7;
final todaySteps = 5234;
final targetSteps = 7500;
```

**Backend Integration:**

**On Page Load:**
1. **Call:** `GET /api/v1/targets/active`
   - Returns active target with goal_statement, constraint, dates

2. **Call:** `GET /api/v1/progress/today`
   - Returns today's steps, target, remaining steps, on_track status

**Update HomePage with:**
```dart
// From /targets/active
final weeklyGoal = target.goal_statement;
final constraint = target.constraint_explanation;
final totalDays = target.duration_days;

// From /progress/today
final daysCompleted = progress.days_completed;
final todaySteps = progress.steps_achieved;
final targetSteps = progress.target_steps;
final stepsRemaining = progress.steps_remaining;
final onTrack = progress.on_track;
```

**Real-time Updates:**
- Refresh every 15-30 minutes when app is active
- Or implement WebSocket for live step updates (optional)

### 6.3 HistoryPage Integration

**Backend Call:**
```dart
GET /api/v1/targets/history?status=completed&limit=20
```

**Display:**
- List of past targets with completion status
- Show avg achievement vs target
- Date ranges
- Baseline improvements over time

### 6.4 DataPage Integration

**Backend Calls:**
1. `GET /api/v1/baselines?type=rolling&limit=10`
   - Shows rolling 30-day baselines over time

2. `GET /api/v1/health/data?types=STEPS&aggregation=weekly&start_date=...`
   - Shows weekly step trends

**Display:**
- Current rolling baseline
- Historical baseline chart
- Activity pattern evolution
- Data confidence scores

### 6.5 Login/Register Integration

**LoginPage:**
- Call `POST /api/v1/auth/login` with email/password
- Store access_token and refresh_token in SharedPreferences
- Update ApiClient with `updateAuthorizationHeader(token)`
- Navigate based on onboarding_completed status

**Register (if implementing):**
- Call `POST /api/v1/auth/register`
- Same token storage and navigation flow

### 6.6 Health Data Sync Strategy

**When to Sync:**
1. **Initial Sync:** During onboarding (last 30 days)
2. **Daily Sync:** Once per day in background
3. **Manual Sync:** Pull-to-refresh option
4. **Real-time:** After significant activity (optional)

**Sync Implementation:**
```dart
Future<void> syncHealthData() async {
  // 1. Fetch new data from device (last 7 days)
  final healthData = await HealthService.fetchLastNDays(7);

  // 2. Remove local duplicates
  final dedupedData = HealthService.removeDuplicates(healthData);

  // 3. Format for API
  final dataPoints = dedupedData.map((point) => {
    'type': point.type.name,
    'value': point.value,
    'unit': point.unit.name,
    'source_name': point.sourceName,
    'source_id': point.sourceId,
    'recorded_at': point.dateTime.toIso8601String(),
  }).toList();

  // 4. Send to backend
  final response = await apiClient.post(
    '/health/sync',
    body: {'data_points': dataPoints},
  );

  // 5. Update local state if needed
  if (response.success) {
    // Optionally refresh today's progress
    await fetchTodayProgress();
  }
}
```

### 6.7 Error Handling

**Handle these scenarios:**
- Network errors: Show offline message, queue sync for later
- Authentication errors: Refresh token or prompt re-login
- Validation errors: Show user-friendly messages
- Rate limiting: Backoff and retry strategy

**Example:**
```dart
try {
  final response = await apiClient.post('/health/sync', body: data);
  if (response.success) {
    // Success handling
  }
} on UnauthorizedException {
  // Try to refresh token
  await authService.refreshToken();
  // Retry request
} on ServerException catch (e) {
  // Show error message
  showErrorSnackbar('Failed to sync data. Please try again.');
} on NetworkException {
  // Queue for background sync
  await syncQueue.add(data);
}
```

### 6.8 Offline Support (Optional Enhancement)

**Local Database:**
- Use sqflite to cache recent data
- Store last baseline, active target, progress
- Sync when connection restored

**Sync Strategy:**
- Mark local changes with sync_status (pending, synced, failed)
- Background sync job when online
- Conflict resolution (server wins for health data)

---

## 7. Implementation Roadmap

### Phase 1: Core Backend Setup (Week 1-2)
- [ ] Set up project structure and dependencies
- [ ] Configure PostgreSQL database
- [ ] Create database schema and migrations
- [ ] Implement user authentication (register, login, JWT)
- [ ] Basic API framework with error handling
- [ ] Logging and monitoring setup

### Phase 2: Health Data Storage (Week 3-4)
- [ ] Implement health data sync endpoint
- [ ] Data validation and deduplication logic
- [ ] Query endpoints for health data retrieval
- [ ] Aggregation functions (daily, weekly, monthly)
- [ ] Performance optimization (indexing, batch inserts)

### Phase 3: Analysis Engine (Week 5-6)
- [ ] Port HealthAnalyzer logic to backend
- [ ] Baseline calculation endpoint
- [ ] Pattern recognition algorithms
- [ ] Data quality scoring
- [ ] Insight generation service
- [ ] Target calculation logic

### Phase 4: Progress Tracking (Week 7-8)
- [ ] Target management endpoints (CRUD)
- [ ] Daily progress calculation
- [ ] Progress retrieval endpoints
- [ ] Background jobs for daily calculations
- [ ] Status update logic (on_track, completed, failed)

### Phase 5: Frontend Integration (Week 9-10)
- [ ] Update Flutter app to use backend APIs
- [ ] Replace all mock data
- [ ] Implement sync strategy
- [ ] Error handling and offline support
- [ ] Testing on iOS and Android
- [ ] Performance optimization

### Phase 6: Production Readiness (Week 11-12)
- [ ] Security audit
- [ ] Load testing and optimization
- [ ] Deploy to production environment
- [ ] Set up monitoring and alerts
- [ ] Documentation completion
- [ ] User acceptance testing

---

## 8. Technology Stack Recommendations

### 8.1 Backend Framework Options

**Option 1: Node.js + Express (Recommended)**
- **Pros:** Fast development, large ecosystem, JavaScript/TypeScript
- **Cons:** Less type-safe than alternatives
- **Good for:** Rapid development, startups, JSON-heavy APIs

**Option 2: Python + FastAPI**
- **Pros:** Excellent for data processing, automatic API docs, type hints
- **Cons:** Slightly slower than Node.js
- **Good for:** Data science integration, ML-ready

**Option 3: Go + Gin**
- **Pros:** Excellent performance, compiled, strong typing
- **Cons:** More verbose, smaller ecosystem
- **Good for:** High-performance requirements, large scale

**Option 4: Kotlin + Spring Boot**
- **Pros:** Strong typing, enterprise-ready, great for Android devs
- **Cons:** More boilerplate, slower startup
- **Good for:** Android-focused teams, enterprise

### 8.2 Recommended Stack (Node.js/TypeScript)

```
┌─────────────────────────────────────┐
│         Tech Stack                  │
├─────────────────────────────────────┤
│ Language:    TypeScript 5.x         │
│ Runtime:     Node.js 20.x LTS       │
│ Framework:   Express.js 4.x         │
│ ORM:         Prisma or TypeORM      │
│ Database:    PostgreSQL 15+         │
│ Cache:       Redis 7.x              │
│ Auth:        jsonwebtoken, bcrypt   │
│ Validation:  Zod or Joi             │
│ Logging:     Winston or Pino        │
│ Testing:     Jest + Supertest       │
│ Docs:        Swagger/OpenAPI        │
└─────────────────────────────────────┘
```

**Project Structure:**
```
backend/
├── src/
│   ├── controllers/        # Route handlers
│   ├── services/           # Business logic
│   ├── repositories/       # Data access
│   ├── models/             # Type definitions
│   ├── middleware/         # Auth, validation, etc.
│   ├── utils/              # Helpers
│   ├── config/             # Configuration
│   └── index.ts            # Entry point
├── prisma/
│   ├── schema.prisma       # Database schema
│   └── migrations/         # DB migrations
├── tests/
│   ├── unit/
│   └── integration/
├── .env.example
├── package.json
└── tsconfig.json
```

### 8.3 Deployment Options

**Option 1: Cloud Platform (Recommended)**
- **Heroku:** Easiest, good for MVP ($7-25/month)
- **Railway:** Modern, good DX ($5-20/month)
- **Render:** Similar to Heroku, competitive pricing

**Option 2: Container Orchestration**
- **AWS ECS + RDS:** Scalable, production-ready ($50-200/month)
- **Google Cloud Run + Cloud SQL:** Serverless, pay-per-use
- **DigitalOcean App Platform:** Simple, affordable ($12-50/month)

**Option 3: Self-Hosted**
- **DigitalOcean Droplet:** Full control ($6-40/month)
- **Linode/Vultr:** Similar pricing and features
- Requires manual setup and maintenance

### 8.4 Development Tools

**Required:**
- Git for version control
- Docker for local development
- Postman/Insomnia for API testing
- pgAdmin or TablePlus for database management

**Recommended:**
- GitHub Actions for CI/CD
- Sentry for error tracking
- DataDog or New Relic for monitoring
- Mixpanel or Amplitude for analytics

---

## 9. Next Steps

### Immediate Actions:

1. **Choose Technology Stack**
   - Decide on backend language/framework
   - Set up development environment
   - Initialize project repository

2. **Set Up Database**
   - Install PostgreSQL locally
   - Create database and user
   - Run schema migrations
   - Seed test data

3. **Implement Authentication**
   - User registration endpoint
   - Login with JWT
   - Token refresh mechanism
   - Secure password hashing

4. **Build Health Data Sync**
   - Sync endpoint implementation
   - Deduplication logic
   - Data validation
   - Test with Flutter app

5. **Frontend Integration POC**
   - Update onboarding to use real API
   - Test data sync from device to backend
   - Verify baseline calculation
   - Display real data on HomePage

### Questions to Answer:

1. **Backend Language:** Node.js, Python, Go, or Kotlin?
2. **Hosting:** Where will you deploy (Heroku, AWS, DigitalOcean)?
3. **Push Notifications:** Do you need real-time notifications?
4. **Social Features:** Any plans for sharing or community features?
5. **Data Export:** Should users be able to export their health data?
6. **API Versioning:** Start with /v1 or /api/v1?
7. **Multi-Device:** Support multiple devices per user?
8. **Data Retention:** How long to keep raw health data?

---

## 10. Summary

This backend design provides:

**Database Schema:**
- 8 core tables for users, health data, baselines, targets, progress, insights, sessions, audit
- Optimized indexes for time-series queries
- JSONB for flexible metadata storage
- Full referential integrity

**API Endpoints:**
- 30+ REST endpoints covering all app features
- Authentication with JWT
- Health data sync and retrieval
- Baseline analysis and insights
- Target management and progress tracking
- User profile management

**Security:**
- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting
- Data privacy and GDPR compliance
- Audit logging

**Integration Points:**
- Clear mapping from Flutter app features to API endpoints
- Sync strategy for health data
- Real-time progress updates
- Offline support considerations

**Implementation Plan:**
- 12-week roadmap
- Phased approach from core to advanced features
- Testing and production deployment

The backend is designed to be:
- **Scalable:** Can handle growth in users and data
- **Secure:** Industry-standard authentication and data protection
- **Maintainable:** Clean architecture with separation of concerns
- **Performant:** Optimized queries and caching strategies
- **Extensible:** Easy to add new health metrics and features

You're ready to start building! Begin with Phase 1 (Core Backend Setup) and integrate with your Flutter app progressively.

---

**Document Version:** 1.0
**Last Updated:** February 1, 2025
**Author:** Backend Architecture Team
