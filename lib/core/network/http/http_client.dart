import 'dart:convert';
import 'dart:io' as dart_io;
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mime/mime.dart' as mime;
import 'package:nanoid/nanoid.dart';

import '../../constants/logger_constant.dart';
import '../../extensions/string_extensions.dart';
import 'http_constants.dart';
import 'http_method_enum.dart';
import 'http_util.dart';

class HttpClient {
  late IOClient _client;
  String host;
  Map<String, String> header;

  HttpClient({required this.host, required this.header}) {
    final httpClient = dart_io.HttpClient()
      ..badCertificateCallback =
          (dart_io.X509Certificate cert, String host, int port) => true;
    _client = IOClient(httpClient);
  }

  Uri getParsedUrl(String path) {
    return Uri.parse('$host$path');
  }

  Future<void> uploadToS3(String url, File file) async {
    final httpClient = dart_io.HttpClient()
      ..badCertificateCallback =
          (dart_io.X509Certificate cert, String host, int port) => true;
    IOClient client = IOClient(httpClient);
    final buff = file.readAsBytesSync();
    await client.put(
      Uri.parse(url),
      body: buff,
      headers: {'Content-Type': 'image/jpeg'},
    );
  }

  String parseDataAndSplitString(dynamic data) =>
      json.encode(data).splitLongStringForLogging();

  Map<String, String> getRequestIdHeader() => {
    HttpConstants.xRequestId: nanoid(),
  };

  dynamic send(Request request) async {
    print(
      '====> Sending HTTP Request\n'
      'Method: ${request.method}\n'
      'Header: ${parseDataAndSplitString(request.headers)}\n'
      'Url: ${request.url.toString()}',
    );

    final streamedResponse = await _client.send(request);
    return Response.fromStream(streamedResponse);
  }

  dynamic get(
    String path, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {...header, ...overrideHeader};

    logData.debug(
      'HTTP Request\n'
      'Method: GET\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}',
    );

    final response = await _client.get(
      getParsedUrl(path),
      headers: requestHeader,
    );
    return HttpUtil.getResponse(response);
  }

  dynamic post(
    String path,
    dynamic data, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };
    final contentType = requestHeader[HttpConstants.contentType];

    String jsonBody;
    dynamic encodedBody;
    if (data == null) {
      jsonBody = '';
      encodedBody = '';
    } else {
      jsonBody = json.encode(data);
      encodedBody = HttpUtil.encodeRequestBody(data, contentType!);
    }

    logData.debug(
      'HTTP Request\n'
      'Method: POST\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}\n'
      'jsonBody: ${parseDataAndSplitString(jsonBody)}\n',
    );

    final response = await _client.post(
      getParsedUrl(path),
      body: encodedBody,
      headers: requestHeader,
    );
    return HttpUtil.getResponse(response);
  }

  dynamic postBlankData(
    String path, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };
    logData.debug(
      'HTTP Request\n'
      'Method: POST\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}\n',
    );

    final response = await _client.post(
      getParsedUrl(path),
      headers: requestHeader,
    );
    return HttpUtil.getResponse(response);
  }

  dynamic uploadFile(
    String path,
    Map<String, dart_io.File> mapFile,
    Map<String, dynamic> data, [
    HttpMethodType method = HttpMethodType.post,
    Map<String, String> overrideHeader = const {},
  ]) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };

    logData.verbose(
      'HTTP request\n'
      'Method: ${HttpMethod(type: method).toString()}\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}',
    );

    final request =
        MultipartRequest(
            HttpMethod(type: method).toString(),
            getParsedUrl(path),
          )
          ..headers.addAll(requestHeader)
          ..headers['accept'] = HttpConstants.jsonContentType
          ..headers[HttpConstants.contentType] =
              HttpConstants.multiPartFormDataType;

    // var request = MultipartRequest(
    //     HttpMethod(type: method).toString(), getParsedUrl(path))
    //   ..headers.addAll(requestHeader);
    // request.files.add(await MultipartFile.fromPath('file', data["file"]));

    // StreamedResponse response = await request.send();
    // print(response.statusCode);

    data.forEach((key, value) => request.fields[key] = value);
    mapFile.forEach((key, value) async {
      final mimeTypeData = mime
          .lookupMimeType(value.path, headerBytes: [0xFF, 0xD8])!
          .split('/');
      return request.files.add(
        await MultipartFile.fromPath(
          key,
          value.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );
    });

    final Response response = await Response.fromStream(await request.send());
    return HttpUtil.getResponse(response);
  }

  dynamic uploadMultipleFiles(
    String path,
    Map<String, List<dart_io.File>> mapFile,
    Map<String, dynamic> data, [
    HttpMethodType method = HttpMethodType.post,
    Map<String, String> overrideHeader = const {},
  ]) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };

    logData.verbose(
      'HTTP request\n'
      'Method: ${HttpMethod(type: method).toString()}\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}',
    );

    final request =
        MultipartRequest(
            HttpMethod(type: method).toString(),
            getParsedUrl(path),
          )
          ..headers.addAll(requestHeader)
          ..headers['accept'] = HttpConstants.jsonContentType
          ..headers[HttpConstants.contentType] =
              HttpConstants.multiPartFormDataType;

    data.forEach((key, value) => request.fields[key] = value);
    mapFile.forEach((key, value) async {
      for (var file in value) {
        final mimeTypeData = mime
            .lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])!
            .split('/');
        return request.files.add(
          await MultipartFile.fromPath(
            key,
            file.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );
      }
    });

    final Response response = await Response.fromStream(await request.send());
    return HttpUtil.getResponse(response);
  }

  dynamic patch(
    String path,
    dynamic data, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };

    logData.debug(
      'HTTP Request\n'
      'Method: PATCH\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}\n'
      'Data: ${parseDataAndSplitString(data)}',
    );

    final response = await _client.patch(
      getParsedUrl(path),
      body: HttpUtil.encodeRequestBody(
        data,
        requestHeader[HttpConstants.contentType]!,
      ),
      headers: requestHeader,
    );
    return HttpUtil.getResponse(response);
  }

  dynamic put(
    String path,
    dynamic data, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };

    logData.debug(
      'HTTP Request\n'
      'Method: PUT\n'
      'Header: ${parseDataAndSplitString(header)}\n'
      'Url: ${getParsedUrl(path)}\n'
      'Data: ${parseDataAndSplitString(data)}',
    );

    final response = await _client.put(
      getParsedUrl(path),
      body: json.encode(data),
      headers: requestHeader,
    );
    return HttpUtil.getResponse(response);
  }

  dynamic delete(
    String path,
    dynamic data, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };

    logData.debug(
      'HTTP Request\n'
      'Method: DELETE\n'
      'Header: ${parseDataAndSplitString(header)}\n'
      'Url: ${getParsedUrl(path)}\n',
    );

    final response = await _client.delete(
      getParsedUrl(path),
      headers: requestHeader,
      body: HttpUtil.encodeRequestBody(
        data,
        requestHeader[HttpConstants.contentType]!,
      ),
    );
    return HttpUtil.getResponse(response);
  }

  dynamic deleteWithBody(
    String path,
    dynamic data, {
    Map<String, String> overrideHeader = const {},
  }) async {
    final requestHeader = {
      ...header,
      ...overrideHeader,
      // ...getRequestIdHeader()
    };

    logData.verbose(
      'HTTP request\n'
      'Header: ${parseDataAndSplitString(requestHeader)}\n'
      'Url: ${getParsedUrl(path)}',
    );

    final request = Request('DELETE', getParsedUrl(path))
      ..headers.addAll(requestHeader)
      ..body = json.encode(data);

    final streamedResponse = await _client.send(request);
    return Response.fromStream(streamedResponse);
  }
}
