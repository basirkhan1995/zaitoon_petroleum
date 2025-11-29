import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'localization_services.dart';

class ApiServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://100.30.64.72/rapi",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        'Cache-Control': 'no-cache',
      },
    ),
  );

  Future<String> _checkConnectivity() async {
    print('🔍 [DEBUG] _checkConnectivity() called');

    final locale = localizationService.loc;
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();

    print('🔍 [DEBUG] Connectivity result: $connectivityResult');

    if (connectivityResult.contains(ConnectivityResult.none)) {
      print('❌ [DEBUG] No connectivity detected, throwing error');
      throw DioException(
        requestOptions: RequestOptions(path: '/'),
        error: locale.noInternet,
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

    print('✅ [DEBUG] Connectivity check passed: $activeConnections');
    return 'Connected via: $activeConnections';
  }

  // Error handling helper
  String _handleError(DioException e) {
    print('🔍 [DEBUG] _handleError() called');
    print('🔍 [DEBUG] Error type: ${e.type}');
    print('🔍 [DEBUG] Error message: ${e.message}');
    print('🔍 [DEBUG] Response status: ${e.response?.statusCode}');
    print('🔍 [DEBUG] Response data: ${e.response?.data}');

    final locale = localizationService.loc;
    if (e.type == DioExceptionType.connectionError) {
      print('❌ [DEBUG] Handling as connection error');
      return locale.noInternet;
    } else if (e.response != null) {
      print('❌ [DEBUG] Handling as response error: ${e.response?.statusCode}');
      switch (e.response?.statusCode) {
        case 400:return locale.badRequest;
        case 401:return locale.unAuthorized;
        case 403:return locale.forbidden;
        case 404:return locale.url404;
        case 500:return locale.internalServerError;
        case 503:return locale.serviceUnavailable;
        default:return "${locale.serverError}: ${e.response?.statusCode} - ${e.response?.statusMessage}";
      }
    } else {
      print('❌ [DEBUG] Handling as network error');
      return locale.networkError;
    }
  }

  // GET method
  Future<Response> get( {required String endpoint, Map<String, dynamic>? queryParams}) async {
    print('🌐 [DEBUG] GET request to: $endpoint');
    try {
      await _checkConnectivity();
      print('✅ [DEBUG] Connectivity check passed for GET');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      print('✅ [DEBUG] GET request successful: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('❌ [DEBUG] GET request failed with DioException');
      throw _handleError(e);
    }
  }

  // POST method
  Future<Response> post({required String endpoint, required dynamic data}) async {
    print('🌐 [DEBUG] POST request to: $endpoint');
    print('📦 [DEBUG] POST data: $data');
    try {
      await _checkConnectivity();
      print('✅ [DEBUG] Connectivity check passed for POST');
      final response = await _dio.post(
        endpoint,
        data: data,
      );
      print('✅ [DEBUG] POST request successful: ${response.statusCode}');
      print('📨 [DEBUG] POST response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      print('❌ [DEBUG] POST request failed with DioException');
      throw _handleError(e);
    }
  }

  // PUT (Update) method
  Future<Response> put({required String endpoint, required dynamic data}) async {
    print('🌐 [DEBUG] PUT request to: $endpoint');
    try {
      await _checkConnectivity();
      print('✅ [DEBUG] Connectivity check passed for PUT');
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      print('✅ [DEBUG] PUT request successful: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('❌ [DEBUG] PUT request failed with DioException');
      throw _handleError(e);
    }
  }

  // DELETE method
  Future<Response> delete({required String endpoint, required dynamic data}) async {
    print('🌐 [DEBUG] DELETE request to: $endpoint');
    try {
      await _checkConnectivity();
      print('✅ [DEBUG] Connectivity check passed for DELETE');
      final response = await _dio.delete(endpoint, data: data);
      print('✅ [DEBUG] DELETE request successful: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('❌ [DEBUG] DELETE request failed with DioException');
      throw _handleError(e);
    }
  }

  //Method to upload file
  Future<Response> uploadFile({
    required String endpoint,
    required FormData data,
  }) async {
    print('🌐 [DEBUG] UPLOAD request to: $endpoint');
    try {
      await _checkConnectivity();
      print('✅ [DEBUG] Connectivity check passed for UPLOAD');
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      print('✅ [DEBUG] UPLOAD request successful: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('❌ [DEBUG] UPLOAD request failed with DioException');
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
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {
//         "Content-Type": "application/json",
//         'Cache-Control': 'no-cache',
//       },
//     ),
//   );
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