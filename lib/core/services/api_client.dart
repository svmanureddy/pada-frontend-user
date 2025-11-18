import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:deliverapp/core/services/service_locator.dart';
import 'package:deliverapp/core/services/storage_service.dart';
import 'package:flutter/material.dart';

import '../../routers/routing_constants.dart';
import '../constants.dart';
import '../errors/exceptions.dart';
import 'navigation_service.dart';

///Base options for dio client.
var options = BaseOptions(
    baseUrl: baseUrl,
    contentType: "application/json",
    connectTimeout: const Duration(milliseconds: 30000),
    receiveTimeout: const Duration(milliseconds: 30000),
    headers: {
      'Accept-Language': 'en',
      'x-api-key': xApiKey,
      "x-device-type": "mobile",
      'x-app-version': '11.5'
    });

///**Api client for application.**
class BaseClient {
  final StorageService storageService = locator.get<StorageService>();

  ///Dio instance variable.
  Dio dio;

  // ignore: unused_field
  String _authToken = '';

  BaseClient() : dio = Dio(options);

  setToken(String token) {
    _authToken = "Bearer $token";
    debugPrint("auth success:: $_authToken");
  }

  Future<Map<String, dynamic>> getHeaders2(
      {bool isAuthenticated = true,
      Map<String, dynamic>? headersIncoming}) async {
    String? token = await storageService.getAuthToken();
    Map<String, dynamic> headers = dio.options.headers;
    try {
      if (isAuthenticated && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      if (headersIncoming != null) {
        headers.addAll(headersIncoming);
      }
      return headers;
    } catch (e) {
      return headers;
    }
  }

  Future<Map<String, dynamic>> getHeadersForRefresh() async {
    String? token = await storageService.getRefreshToken();
    Map<String, dynamic> headers = dio.options.headers;
    try {
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    } catch (e) {
      return headers;
    }
  }

  ///Add header to dio api calls.
  Map<String, dynamic> getHeaders(
      {bool isAuthenticated = true, Map<String, dynamic>? headersIncoming}) {
    Map<String, dynamic> headers = dio.options.headers;

    try {
      debugPrint("auth::$_authToken");
      if (isAuthenticated && _authToken != '') {
        headers['Authorization'] = _authToken;
      }
      if (headersIncoming != null) {
        headers.addAll(headersIncoming);
      }
      return headers;
    } catch (e) {
      return headers;
    }
  }

  ///Get data using dio.
  get(
      {required String url,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $url");
      var response = await dio.get(url,
          options: Options(
              headers: await getHeaders2(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.message}");
      throw _dioException(dioError);
    } catch (e) {
      rethrow;
    }
  }

  getRefreshTok(
      {required String url,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      var response = await dio.get(url,
          options: Options(headers: await getHeadersForRefresh()));
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      rethrow;
    }
  }

  ///Post data with dio.
  post(
      {required String url,
      dynamic payload,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      debugPrint("PAYLOAD: $payload");
      String? token = await storageService.getAuthToken();
      debugPrint("TOKEN: $token");
      debugPrint("auth:: Bearer $token");
      var response = await dio.post(url,
          data: payload ?? {},
          options: Options(
              headers: await getHeaders2(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      // if (response.statusCode == 401) {
      //   navigationService.navigatePushNamedAndRemoveUntilTo(
      //       loginScreenRoute, null);
      // }
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  ///Post data with dio.
  otpPost(
      {required String url,
      dynamic payload,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      debugPrint("PAYLOAD: $payload");
      debugPrint("TOKEN: $_authToken");
      // debugPrint("HEADERS: ${await getHeaders2()}");
      var response = await dio.post(url,
          data: payload ?? {},
          options: Options(
              headers: getHeaders(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      // if (response.statusCode == 401) {
      //   navigationService.navigatePushNamedAndRemoveUntilTo(
      //       loginScreenRoute, null);
      // }
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  ///Post data with dio.
  postNew(
      {required String url,
      dynamic payload,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      debugPrint("PAYLOAD: $payload");
      debugPrint("TOKEN: $_authToken");
      debugPrint("HEADERS: ${await getHeaders2()}");
      var response = await dio.post(url,
          data: payload ?? {},
          options: Options(
              headers: await getHeaders2(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.message}");
      throw _dioException(dioError);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  ///Put data using dio.
  put(
      {required String url,
      Map<String, dynamic>? payload,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      debugPrint("PAYLOAD: $payload");
      String? token = await storageService.getAuthToken();
      debugPrint("TOKEN: $token");
      var response = await dio.put(url,
          data: payload ?? {},
          options: Options(
              headers: await getHeaders2(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      rethrow;
    }
  }

  ///Delete data using dio.
  delete(
      {required String url,
      dynamic payload,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      debugPrint("PAYLOAD: $payload");
      String? token = await storageService.getAuthToken();
      debugPrint("TOKEN: $token");
      var response = await dio.delete(url,
          data: payload ?? {},
          options: Options(
              headers: await getHeaders2(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      rethrow;
    }
  }

  ///Download data using dio.
  download(
      {required String url,
      required String filePath,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $baseUrl$url");
      await dio.download(url, filePath,
          options: Options(
              headers: getHeaders(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      rethrow;
    }
  }

  ///Get remoteConfiguration using dio.
  getRemoteConfig(
      {required String url,
      bool isAuthenticated = true,
      Map<String, dynamic>? headers}) async {
    try {
      debugPrint("URL: $url");
      var response = await dio.get(url,
          options: Options(
              headers: getHeaders(
                  isAuthenticated: isAuthenticated, headersIncoming: headers)));
      return _processResponse(response);
    } on DioException catch (dioError) {
      debugPrint("DioError: ${dioError.response}");
      throw _dioException(dioError);
    } catch (e) {
      rethrow;
    }
  }

  ///Process the response and throws exception accordingly with status code.
  _processResponse(Response? response) {
    switch (response?.statusCode) {
      case 200:
        var decodedJson = response?.data;
        return decodedJson;
      case 201:
        var decodedJson = response?.data;
        return decodedJson;
      case 400:
        var decodedResponse = jsonDecode(response.toString());
        var message = decodedResponse["message"]?.toString() ?? 'Bad request';
        debugPrint("./.../// $message");
        throw ClientException(message: message, response: response?.data);
      case 401:
        var decodedResponse = jsonDecode(response.toString());
        var message = decodedResponse["message"]?.toString() ?? 'Unauthorized';
/*       Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
          );*/
        navigationService.navigatePushNamedAndRemoveUntilTo(
            loginScreenRoute, null);

        /* final resp = await ApiService().getRefreshToken();
        debugPrint("refresh resp:: $resp");
        if(resp != null) {
          if (resp['success'] == true) {
            storageService.setRefreshToken(resp['data']['token']);
          }
        }
        return;*/
        throw ClientException(
            message: message, response: response?.data, statusCode: 401);
      case 404:
        var decodedResponse = jsonDecode(response.toString());
        var message = decodedResponse["message"]?.toString() ?? 'Not found';

        throw ClientException(message: message, response: response?.data);
      case 500:
        {
          var decodedResponse = jsonDecode(response.toString());
          var message = decodedResponse["message"]?.toString() ?? 'Internal server error';
          debugPrint("mess: $message");

          throw ServerException(message: message);
        }
      case 504:
        var decodedResponse = jsonDecode(response.toString());
        var message = decodedResponse["message"]?.toString() ?? 'Gateway timeout';

        throw ServerException(message: message);
      default:
        var decodedResponse = jsonDecode(response.toString());
        var message = decodedResponse["message"]?.toString() ?? 'Something went wrong';
        debugPrint("msg::::$message");

        throw HttpException(statusCode: response?.statusCode, message: message);
    }
  }

  ///Returns type of exception using DioErrorType.
  _dioException(DioException dioErr) {
    switch (dioErr.type) {
      case DioExceptionType.badResponse:
        throw _processResponse(dioErr.response);
      case DioExceptionType.sendTimeout:
        throw HttpException(
            statusCode: dioErr.response?.statusCode,
            message: dioErr.response?.statusMessage);
      case DioExceptionType.receiveTimeout:
        throw HttpException(
            statusCode: dioErr.response?.statusCode,
            message: dioErr.response?.statusMessage);
      case DioExceptionType.connectionTimeout:
        throw TimeOutException(
            statusCode: dioErr.response?.statusCode);
      default:
        throw HttpException(
            statusCode: dioErr.response?.statusCode,
            message: dioErr.response?.statusMessage);
    }
  }
}
