class HttpConstants {
  static const int success = 200;
  static const int createSuccess = 201;
  static const int noContentSuccess = 204;
  static const int redirect = 302;
  static const int badRequest = 400;
  static const int unprocessableEntity = 422;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int cartDataException = 406;
  static const int serverError = 500;
  static const String dataVersionNumber = '1.0';

  static const String xRequestId = 'X-Request-Id';
  static const String contentType = 'Content-Type';

  static const String dataVersion = 'Data-Version';
  static const String osType = 'os-type';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String jsonContentType = 'application/json';
  static String multiPartFormDataType = 'multipart/form-data';
  static const String formUrlEncodedType = 'application/x-www-form-urlencoded';
  static const String multipartFormDataType = 'multipart/form-data';
  static const String timeZoneOffsetMinutes = 'timeZoneOffsetMinutes';
  static const String location = 'location';
  static const String cookie = 'cookie';
  static const String authCookie = 'auth-cookie';
}
