import '../constants/exception_constants.dart';
import 'server_exception.dart';

class ConflictException extends ServerException {
  ConflictException(
    String error, {
    String? url,
  }) : super(
          codeInt: ExceptionConstants.conflictExceptionCode,
          codeString: ExceptionConstants.conflictString,
          message: error,
        );
}
