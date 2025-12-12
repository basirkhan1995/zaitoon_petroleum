import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/model/rate_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/model/gl_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/model/emp_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/model/fetch_atat_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/TxnByReference/model/txn_ref_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/AccountStatement/model/stmt_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/model/com_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/stk_acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/model/driver_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/model/shipping_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/model/vehicle_model.dart';
import '../Views/Menu/Ui/HR/Ui/UserDetail/Ui/Permissions/per_model.dart';
import '../Views/Menu/Ui/HR/Ui/Users/model/user_model.dart';
import '../Views/Menu/Ui/Journal/Ui/FetchGLAT/model/glat_model.dart';
import '../Views/Menu/Ui/Settings/Ui/Company/Branch/Ui/BranchLimits/model/limit_model.dart';
import '../Views/Menu/Ui/Settings/Ui/Company/Branches/model/branch_model.dart';
import '../Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';

class Repositories {
  final ApiServices api;
  const Repositories(this.api);

  ///Authentication ............................................................
  Future<Map<String, dynamic>> login({required String username, required String password}) async {
    try {
      final response = await api.post(
        endpoint: "/user/login.php",
        data: {"usrName": username, "usrPass": password},
      );

      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Get Company ...............................................................
  Future<CompanySettingsModel> getCompanyProfile() async {
    try {
      final response = await api.get(
        endpoint: "/setting/companyProfile.php",
      );

      final data = response.data;

      // Case 3: API returns a single object instead of list
      if (data is Map<String, dynamic>) {
        return CompanySettingsModel.fromMap(data);
      }
      // Case 4: API returns a list with first object as map
      if (data is List && data.first is Map<String, dynamic>) {
        return CompanySettingsModel.fromMap(data.first);
      }
      throw Exception("Invalid API response format");

    } on DioException catch (e) {
      throw e.message ?? "Network error";
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> editCompanyProfile({required CompanySettingsModel newData}) async {
    try {
      final response = await api.put(
          endpoint: "/setting/companyProfile.php",
          data: newData.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> uploadCompanyProfile({required Uint8List image}) async {
    try {
      // Create a valid filename like Postman does
      final String fileName = "photo_${DateTime.now().millisecondsSinceEpoch}.jpg";

      FormData formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(
          image,
          filename: fileName,
          contentType: MediaType("image", "jpeg"),
        ),
      });

      final response = await api.uploadFile(
        endpoint: "/setting/companyProfile.php",
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Stakeholder | Individuals .................................................
  Future<List<IndividualsModel>> getStakeholders({int? indId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = indId != null ? {'perID': indId} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/stakeholder/personal.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => IndividualsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addStakeholder({required IndividualsModel stk}) async {
    try {
      final response = await api.post(
        endpoint: "/stakeholder/personal.php",
        data: stk.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> editStakeholder({required IndividualsModel stk}) async {
    try {
      final response = await api.put(
          endpoint: "/stakeholder/personal.php",
          data: stk.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<IndividualsModel> getPersonProfileById({required int perId}) async {
    try {
      final response = await api.get(
        endpoint: "/stakeholder/personal.php",
        queryParams: {'perID': perId},
      );

      final data = response.data;

      // Case 1: API returns an error message
      if (data is Map && data['msg'] != null) {
        throw Exception(data['msg']);
      }

      // Case 2: API returns a list, but empty
      if (data is List && data.isEmpty) {
        throw Exception("Person not found");
      }

      // Case 3: API returns a single object instead of list
      if (data is Map<String, dynamic>) {
        return IndividualsModel.fromMap(data);
      }

      // Case 4: API returns a list with first object as map
      if (data is List && data.first is Map<String, dynamic>) {
        return IndividualsModel.fromMap(data.first);
      }

      throw Exception("Invalid API response format");

    } on DioException catch (e) {
      throw e.message ?? "Network error";
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> uploadPersonalPhoto({required int perID, required Uint8List image,}) async {
    try {
      // Create a valid filename like Postman does
      final String fileName = "photo_${DateTime.now().millisecondsSinceEpoch}.jpg";

      FormData formData = FormData.fromMap({
        "perID": perID.toString(),
        "image": MultipartFile.fromBytes(
          image,
          filename: fileName,
          contentType: MediaType("image", "jpeg"),
        ),
      });

      final response = await api.uploadFile(
        endpoint: "/stakeholder/uploadPersonalPhoto.php",
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }


  ///Accounts | Stakeholder's Account ..........................................
  Future<List<AccountsModel>> getAccounts({int? ownerId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = ownerId != null ? {'perID': ownerId} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/journal/allAccounts.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => AccountsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<StakeholdersAccountsModel>> getStakeholdersAccounts({String? search}) async {
    try {
      final response = await api.post(
        endpoint: "/journal/accountDetails.php",
        data: {
          "searchValue": search
        }
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => StakeholdersAccountsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addAccount({required AccountsModel newAccount}) async {
    try {
      final response = await api.post(
          endpoint: "/stakeholder/account.php",
          data: newAccount.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> editAccount({required AccountsModel newAccount}) async {
    try {
      final response = await api.put(
          endpoint: "/stakeholder/account.php",
          data: newAccount.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<List<AccountsModel>> getAccountFilter({final int? start, final int? end, final String? input, final String? locale, final String? exclude, final String? ccy,}) async {
    try {

      // Fetch data from API
      final response = await api.post(
        endpoint: "/journal/allAccounts.php",
        data: {
          "ccy": ccy,
          "local": locale,
          "input": input,
          "groupStart": start,
          "groupStop": end,
          "account": exclude
        }
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => AccountsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  /// GL Accounts | System
  Future<List<GlAccountsModel>> getAllGlAccounts({String? local}) async {
    try {
      // Build query parameters dynamically
      final queryParams = local != null ? {'local': local} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/finance/glAccount.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => GlAccountsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<GlAccountsModel>> getGlAccountsByOptions({List<int>? categories, List<int>? excludeAccounts, String? search, String? local}) async {
    try {

      final response = await api.post(
        endpoint: "/journal/getAccounts.php",
        data: {
          "locale": local,
          "categories": categories,
          "exclude_accounts": excludeAccounts,
          "search": search
        },
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => GlAccountsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> deleteGl({required int accNumber}) async {
    try {
      final response = await api.delete(
          endpoint: "/finance/glAccount.php",
          data: {
            "gl":accNumber
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  ///Users .....................................................................
  Future<List<UsersModel>> getUsers({int? usrOwner}) async {
    try {
      // Build query parameters dynamically
      final queryParams = usrOwner != null ? {'perID': usrOwner} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/HR/users.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => UsersModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addUser({required UsersModel newUser}) async {
    try {
      final response = await api.post(
          endpoint: "/HR/users.php",
          data: newUser.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> editUser({required UsersModel newUser}) async {
    try {
      final response = await api.put(
          endpoint: "/HR/users.php",
          data: newUser.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Employees .................................................................
  Future<List<EmployeeModel>> getEmployees({int? empId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = empId != null ? {'empID': empId} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/HR/employees.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => EmployeeModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addEmployee({required EmployeeModel newEmployee}) async {
    try {
      final response = await api.post(
          endpoint: "/HR/employees.php",
          data: newEmployee.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateEmployee({required EmployeeModel newEmployee}) async {
    try {
      final response = await api.put(
          endpoint: "/HR/employees.php",
          data: newEmployee.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Permissions ..............................................................
  Future<List<UserPermissionsModel>> getPermissions({required String usrName}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'username': usrName};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/user/permissions.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => UserPermissionsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> updatePermissionStatus({required int uprRole, required int usrId, required String usrName, required bool uprStatus}) async {
    try {
      final response = await api.put(
          endpoint: "/user/permissions.php",
          data: {
            "uprRole":uprRole,
            "uprUserID":usrId,
            "uprStatus":uprStatus
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Currencies ................................................................
  Future<List<CurrenciesModel>> getCurrencies({required int? status}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'status': status};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/finance/currency.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => CurrenciesModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> updateCcyStatus({required bool status, required String? ccyCode}) async {
    try {
      final response = await api.put(
          endpoint: "/finance/currency.php",
          data: {
            "ccyStatus": status,
            "ccyCode":ccyCode,
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Exchange Rate .............................................................
  Future<List<ExchangeRateModel>> getExchangeRate({required String? ccyCode}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'ccy': ccyCode};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/finance/exchangeRate.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => ExchangeRateModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addExchangeRate({required ExchangeRateModel newRate}) async {
    try {
      final response = await api.post(
          endpoint: "/finance/exchangeRate.php",
          data: newRate.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<String?> getSingleRate({required String fromCcy, required String toCcy}) async {
    try {
      final response = await api.post(
        endpoint: "/journal/getSingleExRate.php",
        data: {
          'ccyFrom': fromCcy,
          'ccyTo': toCcy,
        },
      );

      // Handle server error response
      if (response.data is Map<String, dynamic> &&
          response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // Expecting a Map: { "crExchange": "66.300000" }
      if (response.data is Map<String, dynamic>) {
        return response.data["crExchange"]?.toString();
      }

      return null;
    } on DioException catch (e) {
      throw e.message ?? "Unknown Dio error";
    } catch (e) {
      throw e.toString();
    }
  }

  ///Driver ....................................................................
  Future<List<DriverModel>> getDrivers({int? empId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'empID': empId};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/transport/drivers.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => DriverModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  ///Vehicles ..................................................................
  Future<List<VehicleModel>> getVehicles({int? vehicleId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'vclID': vehicleId};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/transport/vehicle.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => VehicleModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addVehicle({required VehicleModel newVehicle}) async {
    try {
      final response = await api.post(
          endpoint: "/transport/vehicle.php",
          data: newVehicle.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateVehicle({required VehicleModel newVehicle}) async {
    try {
      final response = await api.put(
          endpoint: "/transport/vehicle.php",
          data: newVehicle.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Shipping .................................................................
  Future<Map<String, dynamic>> addShipping({required ShippingModel newShipping}) async {
    try {
      final response = await api.post(
          endpoint: "/transport/shipping.php",
          data: newShipping.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<ShippingModel>> getShipping({required int id}) async {
    try {
      final queryParams = {'shpID': id};
      final response = await api.get(
          endpoint: '/transport/shipping.php',
          queryParams: queryParams
      );


      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => ShippingModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Fetch GL transaction by Vehicle ID
  Future<GlatModel> getGlatTransaction(String ref) async {
    try {
      final response = await api.get(
        endpoint: "/transport/vehicleTransaction.php",
        queryParams: {"ref": ref},
      );

      // The API already returns your JSON object
      final data = response.data;

      // Parse into model
      return GlatModel.fromMap(data);
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Transactions | Cash Deposit | Withdraw ...................................
  Future<List<TransactionsModel>> getTransactionsByStatus({String? status}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'status': status};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/journal/getTransactions.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => TransactionsModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<TxnByReferenceModel> getTxnByReference({required String reference}) async {
    try {
      final queryParams = {'ref': reference};
      final response = await api.get(
          endpoint: '/journal/getSingleTransaction.php',
          queryParams: queryParams
      );

      final data = response.data;

      // Case 3: API returns a single object instead of list
      if (data is Map<String, dynamic>) {
        return TxnByReferenceModel.fromMap(data);
      }
      // Case 4: API returns a list with first object as map
      if (data is List && data.first is Map<String, dynamic>) {
        return TxnByReferenceModel.fromMap(data.first);
      }
      throw Exception("Invalid API response format");
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<FetchAtatModel> getATATByReference({required String reference}) async {
    try {
      final queryParams = {'ref': reference};
      final response = await api.get(
        endpoint: '/journal/fundTransfer.php',
        queryParams: queryParams,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return FetchAtatModel.fromMap(data);
      }

      // Optional: handle case where API accidentally wraps in a list
      if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
        return FetchAtatModel.fromMap(data.first);
      }

      throw Exception("Invalid API response format: $data");
    } on DioException catch (e) {
      throw e.message ?? 'Unknown Dio error';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> cashFlowOperations({required TransactionsModel newTransaction}) async {
    try {
      final response = await api.post(
          endpoint: "/journal/cashWD.php",
          data: newTransaction.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> fundTransfer({required TransactionsModel newTransaction}) async {
    try {
      final response = await api.post(
          endpoint: "/journal/fundTransfer.php",
          data: newTransaction.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> bulkTransfer({required String userName, required List<Map<String, dynamic>> records,}) async {
    try {
      final response = await api.post(
        endpoint: '/journal/fundTransferMA.php',
        data: {
          'usrName': userName,
          'records': records,
        },
      );

      // Parse response
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is String) {
        // If response is a simple string message
        return {'msg': responseData};
      }

      return {'msg': 'Unknown response format'};
    } catch (e) {
      throw Exception('Failed to save bulk transfer: $e');
    }
  }
  Future<Map<String, dynamic>> fxTransfer({required String userName, required List<Map<String, dynamic>> records,}) async {
    try {
      final response = await api.post(
        endpoint: '/journal/crossCurrency.php',
        data: {
          'usrName': userName,
          'records': records,
        },
      );

      // Parse response
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is String) {
        // If response is a simple string message
        return {'msg': responseData, 'account': responseData};
      }

      return {'msg': 'Unknown response format'};
    } catch (e) {
      throw Exception('Failed to save bulk transfer: $e');
    }
  }

  Future<Map<String, dynamic>> authorizeTxn({required String reference, required String? usrName}) async {
    try {
      final response = await api.put(
          endpoint: "/journal/transactionActivity.php",
          data: {
            "reference": reference,
            "username":usrName,
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> reverseTxn({required String reference, required String? usrName}) async {
    try {
      final response = await api.post(
          endpoint: "/journal/transactionActivity.php",
          data: {
            "reference": reference,
            "username":usrName,
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> deleteTxn({required String reference, required String? usrName}) async {
    try {
      final response = await api.delete(
          endpoint: "/journal/transactionActivity.php",
          data: {
            "reference": reference,
            "username":usrName,
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateTxn({required TransactionsModel newTxn}) async {
    try {
      final response = await api.put(
          endpoint: "/journal/cashWD.php",
          data: newTxn.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Password Settings .........................................................
  Future<Map<String, dynamic>> forceChangePassword({required String credential, required String newPassword}) async {
    try {
      final response = await api.put(
          endpoint: "/user/changePass.php",
          data: {
            "usrName": credential,
            "usrPass": newPassword
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> changePassword({required String credential,required String oldPassword, required String newPassword}) async {
    try {
      final response = await api.post(
          endpoint: "/user/changePass.php",
          data: {
            "usrName": credential,
            "usrPass": oldPassword,
            "usrNewPass": newPassword
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> resetPassword({required String credential,required String oldPassword, required String newPassword}) async {
    try {
      final response = await api.put(
          endpoint: "/user/users.php",
          data: {
            "credential": credential,
            "newPassword": newPassword
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Branches & Limits  .................................................
  Future<List<BranchModel>> getBranches({int? brcId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'brcID': brcId};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/setting/branch.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => BranchModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addBranch({required BranchModel newBranch}) async {
    try {
      final response = await api.post(
          endpoint: "/setting/branch.php",
          data: newBranch.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateBranch({required BranchModel newBranch}) async {
    try {
      final response = await api.put(
          endpoint: "/setting/branch.php",
          data: newBranch.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<List<BranchLimitModel>> getBranchLimits({int? brcCode}) async {
    try {
      // Build query parameters dynamically
      final queryParams = {'code': brcCode};

      // Fetch data from API
      final response = await api.get(
        endpoint: "/setting/branchAuthLimit.php",
        queryParams: queryParams,
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => BranchLimitModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addEditBranchLimit({required BranchLimitModel newLimit}) async {
    try {
      final response = await api.post(
          endpoint: "/setting/branchAuthLimit.php",
          data: newLimit.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Storage ..................................................................
  Future<List<StorageModel>> getStorage() async {
    try {

      // Fetch data from API
      final response = await api.get(
        endpoint: "/setting/storage.php",
      );

      // Handle error messages from server
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If data is null or empty, return empty list
      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      // Parse list of stakeholders safely
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // ensure map type
            .map((json) => StorageModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<Map<String, dynamic>> addStorage({required StorageModel newStorage}) async {
    try {
      final response = await api.post(
          endpoint: "/setting/storage.php",
          data: newStorage.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateStorage({required StorageModel newStorage}) async {
    try {
      final response = await api.put(
          endpoint: "/setting/storage.php",
          data: newStorage.toMap()
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  ///Reports ...................................................................
  // In your API service method
  Future<AccountStatementModel> getAccountStatement({required int account, required String fromDate, required String toDate,}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/accountStatement.php",
          data: {
            "account": account,
            "fromDate": fromDate,
            "toDate": toDate
          }
      );

      // Handle message response
      if (response.data is Map && response.data['msg'] != null) {
        throw response.data['msg'];
      }

      // Handle empty response
      if (response.data == null || response.data.isEmpty) {
        throw "No data received";
      }

      // Convert response to string and back to ensure proper typing
      final jsonString = json.encode(response.data);
      final decodedData = json.decode(jsonString) as dynamic;

      return AccountStatementModel.fromApiResponse(decodedData);

    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw e.toString();
    }
  }

}