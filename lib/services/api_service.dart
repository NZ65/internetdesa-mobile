import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: StorageService.getBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Request & Auth Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Re-read baseUrl in case it was modified in settings
        options.baseUrl = StorageService.getBaseUrl();

        final token = StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String errorMsg = 'Terjadi gangguan koneksi ke server.';
        if (e.response != null && e.response?.data != null) {
          if (e.response?.data is Map && e.response?.data['message'] != null) {
            errorMsg = e.response?.data['message'];
          }
        } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          errorMsg = 'Koneksi ke server timeout. Silakan periksa jaringan Anda.';
        }
        return handler.reject(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: errorMsg,
        ));
      },
    ));
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // Multipart POST (for uploading camera photos / proofs)
  Future<Response> postMultipart(String path, Map<String, dynamic> data, Map<String, File?> files) async {
    final formDataMap = Map<String, dynamic>.from(data);

    for (var entry in files.entries) {
      if (entry.value != null && await entry.value!.exists()) {
        final fileName = entry.value!.path.split('/').last;
        formDataMap[entry.key] = await MultipartFile.fromFile(
          entry.value!.path,
          filename: fileName,
        );
      }
    }

    final formData = FormData.fromMap(formDataMap);
    return await _dio.post(path, data: formData);
  }
}
