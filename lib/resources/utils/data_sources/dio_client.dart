import 'package:dio/dio.dart';
import '../../../resources/utils/data_sources/local.dart';
import '../../../models/exceptions/api_exception.dart';
import '../../constains/constants.dart';


class DioClient {
  static final Dio _dio = Dio(BaseOptions(validateStatus: (status) => true));

  DioClient() {
    _dio.interceptors.add(_authInterceptor());
  }

  // Add headers

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (request, handler) async {
        final isLoginRequest = request.path.endsWith('/api/auth/access-token');

        if (!isLoginRequest) {
          final token = (await SharedPre.instance).getString(SharedPrefsConstants.ACCESS_TOKEN_KEY);
          if (token != null && token.isNotEmpty) {
            request.headers.addAll({
              "Authorization": 'Bearer $token',
              "Accept": 'application/json',
            });
          }
        } else {
          request.headers.addAll({"Accept": 'application/json'});
        }

        return handler.next(request);
      },
      onError: (DioError error, ErrorInterceptorHandler handler) async {
        final requestOptions = error.requestOptions;

        // Kiểm tra xem request này đã retry chưa
        final hasRetried = requestOptions.extra['retried'] == true;
        if (error.response?.statusCode == 401  && !hasRetried) {

          final refreshToken = (await SharedPre.instance).getString(SharedPrefsConstants.REFRESH_TOKEN_KEY);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              // Gửi request refresh token
              final tokenResponse = await _dio.post(
                '${ApiConstants.getBaseUrl}/api/auth/refresh-token',
                data: {'refreshToken': refreshToken},
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                ),
              );

              final newAccessToken = tokenResponse.data['accessToken'];
              if (newAccessToken != null) {
                // Lưu access token mới
                await (await SharedPre.instance).setString(SharedPrefsConstants.ACCESS_TOKEN_KEY, newAccessToken);

                // Lấy request gốc để retry
                final RequestOptions requestOptions = error.requestOptions;

                // Cập nhật header Authorization với token mới
                final Options options = Options(
                  method: requestOptions.method,
                  headers: {
                    ...requestOptions.headers,
                    'Authorization': 'Bearer $newAccessToken',
                  },
                  contentType: requestOptions.contentType,
                  responseType: requestOptions.responseType,
                  extra: {...requestOptions.extra, 'retried': true},  // Đánh dấu đã retry
                );

                // Retry request gốc với token mới
                final Response retryResponse = await _dio.request(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: options,
                );

                return handler.resolve(retryResponse);
              }
            } catch (e) {
              // Refresh token lỗi, có thể logout user hoặc báo lỗi
              return handler.next(error);
            }
          }
        }

        return handler.next(error);
      },

    );
  }

  // Future<Response<Map<String, dynamic>>> get(String path, {Map<String, dynamic>? queryParameters}) async {
  //   try {
  //     Response<Map<String, dynamic>> response = await _dio.get(path, queryParameters: queryParameters);
  //     return response;
  //   } on Exception catch (exception) {
  //     throw handleError(exception);
  //   }
  // }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      Response response =
          await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on Exception catch (exception) {
      print(exception.toString());
      throw handleError(exception);
    }
  }

  Future<Response<Map<String, dynamic>>> postLogin(String path,
      {Map<String, dynamic>? queryParameters, dynamic data}) async {
    _dio.options.headers.remove(Headers.contentTypeHeader);
    _dio.options.headers['Content-Type'] = 'application/json';
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(path, queryParameters: queryParameters, data: data);
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }

  Future<Response<String>> postFile(
      String path, {
        Map<String, dynamic>? queryParameters,
        dynamic data,
        bool isMultipart = false,
      }) async {
    try {
      if (isMultipart) {
        _dio.options.headers.remove(Headers.contentTypeHeader);
      } else {
        _dio.options.headers[Headers.contentTypeHeader] = 'application/json';
      }

      final response = await _dio.post<String>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(responseType: ResponseType.plain), // 🔥 plain text
      );
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }

  Future<Response> download(
      String url,
      String savePath, {
        Map<String, dynamic>? queryParameters,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            "Accept": 'application/json',
          },
        ),
      );
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }


  Future<Response> post(String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      // Nếu multipart, bỏ header content-type cho Dio tự thêm
      if (isMultipart) {
        _dio.options.headers.remove(Headers.contentTypeHeader);
      } else {
        // Ngược lại thì đặt Content-Type là JSON
        _dio.options.headers[Headers.contentTypeHeader] = 'application/json';
      }

      final response = await _dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
      );
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }

  Future<Response> put(String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      if (isMultipart) {
        _dio.options.headers.remove(Headers.contentTypeHeader);
      } else {
        _dio.options.headers[Headers.contentTypeHeader] = 'application/json';
      }

      final response = await _dio.put(
        path,
        queryParameters: queryParameters,
        data: data,
      );
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }
  Future<Response> patch(String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      if (isMultipart) {
        _dio.options.headers.remove(Headers.contentTypeHeader);
      } else {
        _dio.options.headers[Headers.contentTypeHeader] = 'application/json';
      }

      final response = await _dio.patch(
        path,
        queryParameters: queryParameters,
        data: data,
      );
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }


  Future<Response<Map<String, dynamic>>> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    _dio.options.headers.remove(Headers.contentTypeHeader);
    _dio.options.headers['Content-Type'] = 'application/json';
    try {
      Response<Map<String, dynamic>> response =
          await _dio.delete(path, queryParameters: queryParameters);
      return response;
    } on Exception catch (exception) {
      throw handleError(exception);
    }
  }

  ApiException handleError(Exception error) {
    String errorDescription = "";
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioExceptionType.connectionTimeout:
          errorDescription = "Connection timeout with API server";
          break;
        case DioExceptionType.unknown:
          errorDescription =
              "Connection to API server failed due to internet connection";
          break;
        case DioExceptionType.connectionError:
          errorDescription = "Connection to API server failed";
          break;
        case DioExceptionType.receiveTimeout:
          errorDescription = "Receive timeout in connection with API server";
          break;
        case DioExceptionType.badResponse:
          errorDescription =
              "Received invalid status code: ${error.response?.statusCode}";
          break;
        case DioExceptionType.sendTimeout:
          errorDescription = "Send timeout in connection with API server";
          break;
        case DioExceptionType.badCertificate:
          errorDescription = "Bad certificate";
          break;
        default:
          errorDescription = "Unexpected error occurred";
          break;
      }
    } else {
      errorDescription = "Unexpected error occurred";
    }

    return ApiException(message: errorDescription);
  }
}
