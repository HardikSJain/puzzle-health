import '../constants/exception_constants.dart';
import 'server_exception.dart';

class UnauthorisedException extends ServerException {
  UnauthorisedException(
    String error, {
    String? url,
  }) : super(
          codeInt: ExceptionConstants.unauthorizedCode,
          codeString: ExceptionConstants.unauthorizedString,
          message: error,
        );
}
