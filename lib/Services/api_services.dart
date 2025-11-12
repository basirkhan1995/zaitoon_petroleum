import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiServices {

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://www.zaitoonsoft.com/rapi", // Change to your API URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        'Cache-Control': 'no-cache',
      },
    ),
  );


  Future<String> _checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/'),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    final activeConnections = connectivityResult
        .where((type) => type != ConnectivityResult.none)
        .map((type) {
      switch (type) {
        case ConnectivityResult.mobile:
          return 'Mobile data';
        case ConnectivityResult.wifi:
          return 'Wi-Fi';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.other:
          return 'Other network';
        default:
          return 'Unknown connection';
      }
    }).join(', ');

    return 'Connected via: $activeConnections';
  }


  // Error handling helper
  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return "localizations.noInternet";
    } else if (e.response != null) {
      switch (e.response?.statusCode) {
        case 400:return "localizations.badRequest"; // Example: "Bad Request! Please check your input."
        case 401:return "localizations.unauthorized"; // Example: "Unauthorized! Please login again."
        case 403:return "localizations.forbidden"; // Example: "Access Denied! You don't have permission."
        case 404:return "localizations.url404NotFound"; // Example: "Resource Not Found!"
        case 500:return "localizations.internalServerError"; // Example: "Server Error! Please try again later."
        case 503:return "localizations.serviceUnavailable"; // Example: "Service Unavailable! Please try later."
        default:return "${"localizations.serverError"}: ${e.response?.statusCode} - ${e.response?.statusMessage}";
      }
    } else {
      return "localizations.networkError";
    }
  }

  // GET method
  Future<Response> get( {required String endpoint, Map<String, dynamic>? queryParams}) async {
    try {
      await _checkConnectivity();
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST method
  Future<Response> post({required String endpoint, required dynamic data}) async {
    try {
      await _checkConnectivity();
      return await _dio.post(
        endpoint,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT (Update) method
  Future<Response> put({required String endpoint, required dynamic data}) async {
    try {
      await _checkConnectivity();
      return await _dio.put(
        endpoint,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE method
  Future<Response> delete({required String endpoint, required dynamic data}) async {
    try {
      await _checkConnectivity();
      return await _dio.delete(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //Method to upload file
  Future<Response> uploadFile({
    required String endpoint,
    required FormData data,
  }) async {
    try {
      await _checkConnectivity();
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}