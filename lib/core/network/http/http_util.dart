import 'dart:convert';

import 'package:http/http.dart';

import '../../exceptions/bad_request_exception.dart';
import '../../exceptions/conflict_exception.dart';
import '../../exceptions/forbidden_exception.dart';
import '../../exceptions/not_found_exception.dart';
import '../../exceptions/server_error_exception.dart';
import '../../exceptions/unauthorized_exception.dart';
import '../../exceptions/unprocessable_entity_exception.dart';
import '../api/api_params_constants.dart';
import 'http_constants.dart';

class HttpUtil {
  static const unknownError = 'UNKNOWN_ERROR';

  static dynamic encodeRequestBody(dynamic data, String contentType) {
    return contentType == HttpConstants.jsonContentType
        ? utf8.encode(json.encode(data))
        : data;
  }

  static dynamic getResponse(Response response) {
    // logData.i(
    //   'HTTP Response\n'
    //   'Status: ${response.statusCode}\n'
    //   'Request: ${response.request}\n'
    //   'Data: ${response.body.splitLongStringForLogging()}',
    // );

    switch (response.statusCode) {
      case HttpConstants.success:
      case HttpConstants.createSuccess:
      case HttpConstants.noContentSuccess:
        return _getSuccessResponse(response);

      case HttpConstants.redirect:
        return response;

      case HttpConstants.badRequest:
        throw BadRequestException(
          getErrorMessage(json.decode(response.body)),
        );

      case HttpConstants.unprocessableEntity:
        throw UnProcessableException(
          getErrorMessage(json.decode(response.body)),
        );

      case HttpConstants.conflict:
        throw ConflictException(
          getErrorMessage(json.decode(response.body)),
        );

      case HttpConstants.unauthorized:
        throw UnauthorisedException(
            getErrorMessage(json.decode(response.body)));

      case HttpConstants.forbidden:
        throw ForbiddenException(
          getErrorMessage(json.decode(response.body)),
        );

      case HttpConstants.notFound:
        throw NotFoundException(
          getErrorMessage(json.decode(response.body)),
        );

      case HttpConstants.serverError:
      default:
        final decodedResponse = json.decode(response.body);
        throw ServerErrorException(
          getErrorMessage(decodedResponse),
          path: errorPath(decodedResponse),
        );
    }
  }

  static dynamic getFileResponse(Response response) {
    switch (response.statusCode) {
      case HttpConstants.success:
      case HttpConstants.createSuccess:
        return response;

      default:
        getResponse(response);
    }
  }

  static dynamic _getSuccessResponse(Response response) {
    final responseJson = <String, dynamic>{};
    if (response.body.isNotEmpty == true) {
      final jsonResponseBody = json.decode(response.body);
      if (jsonResponseBody is Map<String, dynamic>) {
        responseJson.addAll(json.decode(response.body));
      } else {
        return jsonResponseBody;
      }
    }
    // _responseJson[JsonKeysConstants.responseStatusCode] = response.statusCode;
    return responseJson;
  }

  static String getErrorMessage(dynamic result) {
    if (result['error'] is String) {
      return result['error'];
    } else if (result['message'] is String) {
      return result['message'];
    } else if (result['error'] != null && result['error']['message'] != null) {
      return result['error']['message'];
    }
    return unknownError;
  }

  static String errorPath(dynamic result) {
    if (result['error'] != null && result['error']['path'] != null) {
      return result['error']['path'];
    }
    return unknownError;
  }

  static String formPathWithQueryParams(
    String endpoint, {
    required Map<String, dynamic> paramsMap,
  }) {
    String path = endpoint;
    if (paramsMap.isNotEmpty == true) {
      bool firstQueryParam = true;
      for (final key in paramsMap.keys) {
        final paramString =
            '$key${ApiParamsConstants.paramEquals}${paramsMap[key]}';
        if (firstQueryParam) {
          path = '$path${ApiParamsConstants.paramsStart}$paramString';
          firstQueryParam = false;
        } else {
          path = '$path${ApiParamsConstants.paramsSeparator}$paramString';
        }
      }
    }
    return path;
  }
}
