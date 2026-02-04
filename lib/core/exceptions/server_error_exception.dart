import '../constants/exception_constants.dart';
import 'server_exception.dart';

class ServerErrorException extends ServerException {
  ServerErrorException(
    String error, {
    super.path,
  }) : super(
          codeInt: ExceptionConstants.internalServerErrorCode,
          codeString: ExceptionConstants.internalServerErrorString,
          message: error,
        );
}
