import '../constants/exception_constants.dart';
import 'server_exception.dart';

class UnProcessableException extends ServerException {
  UnProcessableException(String error)
      : super(
          codeInt: ExceptionConstants.unprocessableEntityCode,
          codeString: ExceptionConstants.unprocessableEntityString,
          message: error,
        );
}
