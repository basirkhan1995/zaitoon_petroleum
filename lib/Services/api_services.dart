import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'localization_services.dart';

class ApiServices {
  final String ip = "52.21.3.100";

  late Dio _dio;

  ApiServices() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          'Cache-Control': 'no-cache',
        },
      ),
    );
  }

  Dio get client => _dio;

  //--------------------------------------------------------------------
  // Internet Connectivity Check
  //--------------------------------------------------------------------
  Future<void> _checkConnectivity() async {
    final locale = localizationService.loc;
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.none)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/'),
        error: locale.noInternet,
        type: DioExceptionType.connectionError,
      );
    }
  }

  //--------------------------------------------------------------------
  // Auto HTTPS → HTTP Fallback request handler
  //--------------------------------------------------------------------
  Future<Response> _request(
      String method,
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParams,
      }) async {
    final httpsUrl = "https://$ip/rapi$endpoint";
    final httpUrl = "http://$ip/rapi$endpoint";

    try {
      return await _dio.request(
        httpsUrl,
        data: data,
        queryParameters: queryParams,
        options: Options(method: method),
      );
    } catch (e) {
      // Retry with HTTP
      return await _dio.request(
        httpUrl,
        data: data,
        queryParameters: queryParams,
        options: Options(method: method),
      );
    }
  }

  //--------------------------------------------------------------------
  // Error handler
  //--------------------------------------------------------------------
  String _handleError(DioException e) {
    final locale = localizationService.loc;

    if (e.type == DioExceptionType.connectionError) {
      return locale.noInternet;
    } else if (e.response != null) {
      switch (e.response?.statusCode) {
        case 400:
          return locale.badRequest;
        case 401:
          return locale.unAuthorized;
        case 403:
          return locale.forbidden;
        case 404:
          return locale.url404;
        case 500:
          return locale.internalServerError;
        case 503:
          return locale.serviceUnavailable;
        default:
          return "${locale.serverError}: ${e.response?.statusCode} - ${e.response?.statusMessage}";
      }
    } else {
      return locale.networkError;
    }
  }

  //--------------------------------------------------------------------
  // GET
  //--------------------------------------------------------------------
  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      await _checkConnectivity();
      return await _request("GET", endpoint, queryParams: queryParams);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //--------------------------------------------------------------------
  // POST
  //--------------------------------------------------------------------
  Future<Response> post({
    required String endpoint,
    required dynamic data,
  }) async {
    try {
      await _checkConnectivity();
      return await _request("POST", endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //--------------------------------------------------------------------
  // PUT
  //--------------------------------------------------------------------
  Future<Response> put({
    required String endpoint,
    required dynamic data,
  }) async {
    try {
      await _checkConnectivity();
      return await _request("PUT", endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //--------------------------------------------------------------------
  // DELETE
  //--------------------------------------------------------------------
  Future<Response> delete({
    required String endpoint,
    required dynamic data,
  }) async {
    try {
      await _checkConnectivity();
      return await _request("DELETE", endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //--------------------------------------------------------------------
  // File Upload
  //--------------------------------------------------------------------
  Future<Response> uploadFile({
    required String endpoint,
    required FormData data,
  }) async {
    try {
      await _checkConnectivity();
      return await _dio.request(
        "http://$ip/rapi$endpoint",
        data: data,
        options: Options(
          method: "POST",
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}


// import 'package:dio/dio.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'localization_services.dart';
//
// class ApiServices {
//
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: "http://100.30.64.72/rapi",
//
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {
//         "Content-Type": "application/json",
//         'Cache-Control': 'no-cache',
//       },
//     ),
//   );
//
//
//   Dio get client => _dio;
//
//   Future<String> _checkConnectivity() async {
//
//     final locale = localizationService.loc;
//     final List<ConnectivityResult> connectivityResult =
//     await Connectivity().checkConnectivity();
//
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       throw DioException(
//         requestOptions: RequestOptions(path: '/'),
//         error: locale.noInternet,
//         type: DioExceptionType.connectionError,
//       );
//     }
//
//     final activeConnections = connectivityResult
//         .where((type) => type != ConnectivityResult.none)
//         .map((type) {
//       switch (type) {
//         case ConnectivityResult.mobile:
//           return 'Mobile data';
//         case ConnectivityResult.wifi:
//           return 'Wi-Fi';
//         case ConnectivityResult.ethernet:
//           return 'Ethernet';
//         case ConnectivityResult.vpn:
//           return 'VPN';
//         case ConnectivityResult.bluetooth:
//           return 'Bluetooth';
//         case ConnectivityResult.other:
//           return 'Other network';
//         default:
//           return 'Unknown connection';
//       }
//     }).join(', ');
//
//     return 'Connected via: $activeConnections';
//   }
//
//
//   // Error handling helper
//   String _handleError(DioException e) {
//     final locale = localizationService.loc;
//     if (e.type == DioExceptionType.connectionError) {
//       return locale.noInternet;
//     } else if (e.response != null) {
//       switch (e.response?.statusCode) {
//         case 400:return locale.badRequest;
//         case 401:return locale.unAuthorized;
//         case 403:return locale.forbidden;
//         case 404:return locale.url404;
//         case 500:return locale.internalServerError;
//         case 503:return locale.serviceUnavailable;
//         default:return "${locale.serverError}: ${e.response?.statusCode} - ${e.response?.statusMessage}";
//       }
//     } else {
//       return locale.networkError;
//     }
//   }
//
//   // GET method
//   Future<Response> get( {required String endpoint, Map<String, dynamic>? queryParams}) async {
//     try {
//       await _checkConnectivity();
//       return await _dio.get(
//         endpoint,
//         queryParameters: queryParams,
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   // POST method
//   Future<Response> post({required String endpoint, required dynamic data}) async {
//     try {
//       await _checkConnectivity();
//       return await _dio.post(
//         endpoint,
//         data: data,
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   // PUT (Update) method
//   Future<Response> put({required String endpoint, required dynamic data}) async {
//     try {
//       await _checkConnectivity();
//       return await _dio.put(
//         endpoint,
//         data: data,
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   // DELETE method
//   Future<Response> delete({required String endpoint, required dynamic data}) async {
//     try {
//       await _checkConnectivity();
//       return await _dio.delete(endpoint, data: data);
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   //Method to upload file
//   Future<Response> uploadFile({
//     required String endpoint,
//     required FormData data,
//   }) async {
//     try {
//       await _checkConnectivity();
//       return await _dio.post(
//         endpoint,
//         data: data,
//         options: Options(
//           contentType: 'multipart/form-data',
//         ),
//       );
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
// }
//
