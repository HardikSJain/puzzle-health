class Configuration {
  static String? _apiHostUrl;

  void setConfigurationValues(Map<String, dynamic> config) {
    _apiHostUrl = config["apiHostUrl"];
  }

  static String get apiHostUrl => _apiHostUrl!;
}
