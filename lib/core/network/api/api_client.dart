import '../../config/configuration.dart';
import '../http/http_client.dart';
import '../http/http_constants.dart';

class MyApiClient extends HttpClient {
  MyApiClient()
    : super(
        host: Configuration.apiHostUrl,
        header: {
          HttpConstants.contentType: HttpConstants.jsonContentType,
          HttpConstants.dataVersion: HttpConstants.dataVersionNumber,
        },
      );

  void updateAuthorizationHeader(String accessToken) {
    header = {
      ...header,
      HttpConstants.authorization: '${HttpConstants.bearer} $accessToken',
    };
  }

  void removeAuthorizationHeader() {
    header.remove(HttpConstants.authorization);
  }

  Map<String, String> getClientAuthenticationHeader() => header;
}
