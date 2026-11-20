import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import '../../data/services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: StorageService.getBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.baseUrl = StorageService.getBaseUrl();
        final token = StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String msg = 'Gagal terhubung ke server.';
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          msg = e.response?.data['message'];
        } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          msg = 'Waktu permintaan habis (Timeout). Periksa koneksi internet Anda.';
        } else if (e.type == DioExceptionType.badResponse) {
          msg = 'Server merespon dengan status ${e.response?.statusCode}.';
        }
        return handler.reject(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: ApiException(msg, e.response?.statusCode),
        ));
      },
    ));
  }

  Dio get dio => _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException(e.message ?? 'Terjadi kesalahan sistem.');
    }
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException(e.message ?? 'Terjadi kesalahan sistem.');
    }
  }

  Future<dynamic> postMultipart(String path, Map<String, dynamic> fields, Map<String, File?> files) async {
    try {
      final formDataMap = Map<String, dynamic>.from(fields);
      for (var entry in files.entries) {
        if (entry.value != null && await entry.value!.exists()) {
          final filename = entry.value!.path.split('/').last;
          formDataMap[entry.key] = await MultipartFile.fromFile(
            entry.value!.path,
            filename: filename,
          );
        }
      }
      final formData = FormData.fromMap(formDataMap);
      final response = await _dio.post(path, data: formData);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException(e.message ?? 'Terjadi kesalahan saat mengunggah berkas.');
    }
  }
}
