import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/model/rate_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/GlCategories/model/cat_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/model/gl_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/model/emp_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/UserDetail/Ui/Log/model/user_log_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/model/usr_report_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/model/fetch_atat_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchTRPT/model/trtp_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/TxnByReference/model/txn_ref_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/AccountStatement/model/stmt_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/GLStatement/model/gl_statement_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/TrialBalance/model/trial_balance_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/TotalDailyTxn/model/daily_txn_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transactions/TransactionRef/model/txn_report_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/model/com_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/ProductCategory/model/pro_cat_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_stock_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/TxnTypes/model/txn_types_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/stk_acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/model/estimate_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewSale/model/sale_invoice_items.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Orders/model/orders_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/model/driver_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingView/model/shp_details_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/model/vehicle_model.dart';
import '../Views/Menu/Ui/Dashboard/Views/DailyGross/model/gross_model.dart';
import '../Views/Menu/Ui/Dashboard/Views/Stats/model/stats_model.dart';
import '../Views/Menu/Ui/HR/Ui/UserDetail/Ui/Permissions/per_model.dart';
import '../Views/Menu/Ui/HR/Ui/Users/model/user_model.dart';
import '../Views/Menu/Ui/Journal/Ui/FetchGLAT/model/glat_model.dart';
import '../Views/Menu/Ui/Journal/Ui/GetOrder/model/get_order_model.dart';
import '../Views/Menu/Ui/Report/Ui/Finance/ArApReport/model/ar_ap_model.dart';
import '../Views/Menu/Ui/Report/Ui/Finance/BalanceSheet/model/bs_model.dart';
import '../Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/model/rate_report_model.dart';
import '../Views/Menu/Ui/Report/Ui/Transport/model/shp_report_model.dart';
import '../Views/Menu/Ui/Settings/Ui/Company/Branch/Ui/BranchLimits/model/limit_model.dart';
import '../Views/Menu/Ui/Settings/Ui/Company/Branches/model/branch_model.dart';
import '../Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_model.dart';
import '../Views/Menu/Ui/Stakeholders/Ui/Individuals/model/individual_model.dart';
import '../Views/Menu/Ui/Stock/Ui/OrderScreen/GetOrderById/model/ord_by_id_model.dart';
import '../Views/Menu/Ui/Stock/Ui/OrderScreen/NewPurchase/model/purchase_invoice_items.dart';
import '../Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingView/model/shipping_model.dart';

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
  Future<List<AccountsModel>> getAccountFilter({final String? include, final String? input,final String? exclude, final String? ccy,}) async {
    try {

      // Fetch data from API
      final response = await api.post(
        endpoint: "/journal/allAccounts.php",
        data: {
          "ccy": ccy,
          "input": input,
          "include": include,
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

  /// GL Accounts | System .....................................................
  Future<List<GlAccountsModel>> getGl() async {
    try {

      // Fetch data from API
      final response = await api.get(
        endpoint: "/finance/glAccount.php",
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
  Future<Map<String, dynamic>> addGl({required GlAccountsModel newAccount}) async {
    try {
      final response = await api.post(
          endpoint: "/finance/glAccount.php",
          data: newAccount.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> editGl({required GlAccountsModel newAccount}) async {
    try {
      final response = await api.put(
          endpoint: "/finance/glAccount.php",
          data: newAccount.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> deleteGl({required int accNumber}) async {
    try {
      final response = await api.delete(
          endpoint: "/finance/glAccount.php",
          data: {
            "acc":accNumber
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// GL Sub Categories ........................................................
  Future<List<GlCategoriesModel>> getGlSubCategories({required int catId}) async {
    try {

      // Fetch data from API
      final response = await api.get(
        endpoint: "/finance/accountCategory.php",
        queryParams: {
          "cat":catId
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
            .map((json) => GlCategoriesModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
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
  Future<Map<String, dynamic>> updateShipping({required ShippingModel newShipping}) async {
    try {
      final response = await api.put(
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
  Future<List<ShippingModel>> getAllShipping({int? id}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (id != null) {
        queryParams['shpID'] = id;
      }
      final response = await api.get(
        endpoint: '/transport/shipping.php',
        queryParams: queryParams,
      );
      // Check for error messages
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        final msg = response.data['msg'];
        if (msg == 'failed' || msg == 'error') {
          throw msg;
        }
      }

      // Handle empty or null response
      if (response.data == null) {
        return [];
      }

      // Parse the response
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ShippingModel.fromMap(json))
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        // If it's a single object, wrap it in a list
        return [ShippingModel.fromMap(response.data)];
      }

      return [];
    } on DioException catch (e) {
      throw 'Network error: ${e.message}';
    } catch (e) {
      throw '$e';
    }
  }
  Future<ShippingDetailsModel> getShippingById({required int shpId}) async {
    try {
      final queryParams = {'shpID': shpId};
      final response = await api.get(
        endpoint: '/transport/shipping.php',
        queryParams: queryParams,
      );

      final data = response.data;

      // Check for error messages
      if (data is Map<String, dynamic> && data['msg'] != null) {
        final msg = data['msg'];
        if (msg == 'failed' || msg == 'error') {
          throw Exception('Failed to load shipping details');
        }
      }

      // Handle different response formats
      if (data is Map<String, dynamic>) {
        // Direct object response (your API format for single shipping)
        return ShippingDetailsModel.fromMap(data);
      } else if (data is List) {
        // List response - take first item
        if (data.isEmpty) {
          throw Exception("No shipping found with ID: $shpId");
        }

        final firstItem = data.first;
        if (firstItem is Map<String, dynamic>) {
          return ShippingDetailsModel.fromMap(firstItem);
        }
        throw Exception("Invalid data format in list response");
      }

      throw Exception("Invalid API response format");
    } on DioException catch (e) {
      throw 'Network error: ${e.message}';
    } catch (e) {
      throw 'Failed to load shipping details: $e';
    }
  }
  Future<TrptModel> getTrpt({required String reference}) async {
    try {
      final queryParams = {'ref': reference};
      final response = await api.get(
          endpoint: '/transport/shippingTransaction.php',
          queryParams: queryParams
      );

      final data = response.data;

      // Case 1: API returns a single object
      if (data is Map<String, dynamic>) {
        return TrptModel.fromMap(data);
      }

      // Case 2: API returns a list with data
      if (data is List) {
        if (data.isEmpty) {
          throw Exception("No transport data found for reference: $reference");
        }
        if (data.first is Map<String, dynamic>) {
          return TrptModel.fromMap(data.first);
        }
        throw Exception("Invalid data format in list response");
      }

      throw Exception("Invalid API response format");
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> updateShippingExpense({required String? usrName, required int shpId, required String amount, required String reference, required String narration}) async {
    try {
      final response = await api.put(
          endpoint: "/transport/shippingTransaction.php",
          data: {
            "usrName": usrName,
            "shpID": shpId,
            "trnReference": reference,
            "amount": amount,
            "narration": narration
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> addShippingExpense({required String? usrName, required int shpId, required String amount, required int accNumber, required String narration}) async {
    try {
      final response = await api.post(
          endpoint: "/transport/shippingTransaction.php",
          data: {
            "usrName": usrName,
            "shpID": shpId,
            "accNumber": accNumber,
            "amount": amount,
            "narration": narration
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> addShippingPayment({required String? usrName, required String paymentType, required int shpId, double? cashAmount, double? accountAmount, int? accNumber}) async {
    try {
      final response = await api.post(
          endpoint: "/transport/shippingPayment.php",
          data: {
            "usrName": usrName,
            "shpID": shpId,
            "pType": paymentType,
            "cashAmount": cashAmount,
            "cardAmount": accountAmount,
            "account": accNumber
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> editShippingPayment({required String? reference, required String? usrName, required String paymentType, required int shpId, double? cashAmount, double? accountAmount, int? accNumber}) async {
    try {
      final response = await api.put(
          endpoint: "/transport/shippingPayment.php",
          data: {
            "trdReference":reference,
            "usrName": usrName,
            "shpID": shpId,
            "pType": paymentType,
            "cashAmount": cashAmount,
            "cardAmount": accountAmount,
            "account": accNumber
          }
      );
      return response.data;
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
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Products .................................................................
  Future<Map<String, dynamic>> addProduct({required ProductsModel newProduct}) async {
    try {
      final response = await api.post(
          endpoint: "/inventory/product.php",
          data: newProduct.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateProduct({required ProductsModel newProduct}) async {
    try {
      final response = await api.put(
          endpoint: "/inventory/product.php",
          data: newProduct.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> deleteProduct({required int proId}) async {
    try {
      final response = await api.delete(
          endpoint: "/inventory/product.php",
          data: {
            "proID": proId
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<List<ProductsModel>> getProduct({int? proId}) async {
    try {
      final queryParams = {'proID': proId};
      final response = await api.get(
        endpoint: "/inventory/product.php",
        queryParams: queryParams,
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null) {
        return [];
      }

      // Handle single product
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('proID') || response.data.containsKey('proId')) {
          return [ProductsModel.fromMap(response.data)];
        }
      }

      // Handle list of products
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductsModel.fromMap(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
  Future<List<ProductsStockModel>> getProductStock({int? proId, int? noStock}) async {
    try {
      final queryParams = {'proID': proId,'av':noStock??0};
      // Fetch data from API
      final response = await api.get(
          endpoint: "/inventory/availableProducts.php",
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
            .map((json) => ProductsStockModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  /// Product Category .........................................................
  Future<Map<String, dynamic>> addProCategory({required ProCategoryModel newCategory}) async {
    try {
      final response = await api.post(
          endpoint: "/setting/productCategory.php",
          data: newCategory.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateProCategory({required ProCategoryModel newCategory}) async {
    try {
      final response = await api.put(
          endpoint: "/setting/productCategory.php",
          data: newCategory.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<List<ProCategoryModel>> getProCategory({int? catId}) async {
    try {
      final queryParams = {'pcID': catId};
      // Fetch data from API
      final response = await api.get(
        endpoint: "/setting/productCategory.php",
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
            .map((json) => ProCategoryModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  /// Orders ...................................................................
  Future<List<OrdersModel>> getOrders({int? orderId}) async {
    try {
      final queryParams = {'ordID': orderId};
      // Fetch data from API
      final response = await api.get(
          endpoint: "/inventory/ordersView.php",
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
            .map((json) => OrdersModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<OrderByIdModel>> getOrderById({int? orderId}) async {
    try {
      final queryParams = {'ordID': orderId};
      final response = await api.get(
          endpoint: "/inventory/salePurchase.php",
          queryParams: queryParams
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null) {
        return [];
      }

      // Your API returns a single order with records included
      if (response.data is Map<String, dynamic>) {
        final orderData = response.data as Map<String, dynamic>;
        if (orderData.containsKey('ordID') || orderData.containsKey('ordId')) {
          final order = OrderByIdModel.fromMap(orderData);
          return [order];
        }
      }

      // If it's a list (though your API doesn't seem to return this)
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => OrderByIdModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  ///Estimate ..................................................................
  Future<List<EstimateModel>> getAllEstimates() async {
    try {
      final response = await api.get(
        endpoint: "/inventory/estimate.php",
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => EstimateModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  Future<EstimateModel?> getEstimateById({required int orderId}) async {
    try {
      final queryParams = {'ordID': orderId};
      final response = await api.get(
          endpoint: "/inventory/estimate.php",
          queryParams: queryParams
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null) {
        return null;
      }

      if (response.data is Map<String, dynamic>) {
        return EstimateModel.fromMap(response.data);
      }

      return null;
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  Future<Map<String, dynamic>> addEstimate({
    required String usrName,
    required int perID,
    required String? xRef,
    required List<EstimateRecord> records,
  }) async {
    try {
      final data = {
        "usrName": usrName,
        "ordName": "Estimate",
        "ordPersonal": perID,
        "ordxRef": xRef ?? "",
        "records": records.map((r) => r.toMap()).toList(),
      };

      final response = await api.post(
        endpoint: "/inventory/estimate.php",
        data: data,
      );

      return response.data is Map<String, dynamic>
          ? response.data
          : {'msg': 'Invalid response format'};

    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  Future<Map<String, dynamic>> updateEstimate({
    required String usrName,
    required int orderId,
    required int perID,
    required String? xRef,
    required List<EstimateRecord> records,
  }) async {
    try {
      final data = {
        "usrName": usrName,
        "ordName": "Estimate",
        "ordID": orderId,
        "ordPersonal": perID,
        "ordxRef": xRef ?? "",
        "records": records.map((r) => r.toMap()).toList(),
      };

      final response = await api.put(
        endpoint: "/inventory/estimate.php",
        data: data,
      );
      return response.data is Map<String, dynamic>
          ? response.data
          : {'msg': 'Invalid response format'};

    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  Future<Map<String, dynamic>> deleteEstimate({
    required int orderId,
    required String usrName,
  }) async {
    try {
      final response = await api.delete(
          endpoint: "/inventory/estimate.php",
          data: {
            "ordID": orderId,
            "usrName": usrName
          }
      );

      return response.data is Map<String, dynamic>
          ? response.data
          : {'msg': 'Invalid response format'};

    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  Future<Map<String, dynamic>> convertEstimateToSale({
    required String usrName,
    required int orderId,
    required int perID,
    required int account, // payment account
    required String amount, // total invoice amount .. if it's cash set accNo null with amount
  }) async {
    try {
      final data = {
        "usrName": usrName,
        "ordID": orderId,
        "ordPersonal": perID,
        "account": account,
        "amount": amount,
      };

      final response = await api.post(
        endpoint: "/inventory/estimateToSale.php",
        data: data,
      );

      return response.data is Map<String, dynamic>
          ? response.data
          : {'msg': 'Invalid response format'};

    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }



  /// Purchase Invoice...........................................................................
  Future<Map<String, dynamic>> addPurchaseInvoice({
    required String usrName,
    required int perID,
    required String? xRef,
    required String orderName, //Purchase or Sale
    int? account,
    double? amount,
    required List<PurchaseInvoiceRecord> records,
  }) async {
    try {
      final data = {
        "usrName": usrName,
        "ordName": orderName,
        "ordPersonal": perID,
        "ordxRef": xRef ?? "",
        "account": account ?? 0,
        "amount": amount ?? 0.0,
        "records": records.map((r) => r.toJson()).toList(),
      };

      final response = await api.post(
        endpoint: "/inventory/salePurchase.php",
        data: data,
      );

      // Return the full response data
      return response.data is Map<String, dynamic>
          ? response.data
          : {'msg': 'Invalid response format'};

    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  Future<Map<String, dynamic>> addSaleInvoice({
    required String usrName,
    required int perID,
    required String? xRef,
    required String orderName,
    int? account,
    double? amount,
    required List<SaleInvoiceRecord> records,
  }) async {
    try {
      final data = {
        "usrName": usrName,
        "ordName": orderName,
        "ordPersonal": perID,
        "ordxRef": xRef ?? "",
        "account": account ?? 0,
        "amount": amount ?? 0.0,
        "records": records.map((r) => r.toJson()).toList(),
      };

      final response = await api.post(
        endpoint: "/inventory/salePurchase.php",
        data: data,
      );

      return response.data is Map<String, dynamic>
          ? response.data
          : {'msg': 'Invalid response format'};

    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }



  // In repositories.dart or similar
  Future<bool> updatePurchaseOrder({
    required int orderId,
    required String usrName,
    required List<Map<String, dynamic>> records,
    required Map<String, dynamic> orderData, // Add this
  }) async {
    try {
      final response = await api.put(
        endpoint: "/inventory/salePurchase.php",
        data: orderData,
      );
      final message = response.data['msg']?.toString() ?? '';
      return message.toLowerCase().contains('success') ||
          message.toLowerCase().contains('authorized');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteOrder({
    required int orderId,
    required String usrName,
    required String? ref,
    required String? ordName,

  }) async {
    try {
      final data = {
        "ordID": orderId,
        "usrName": usrName,
        "ordTrnRef":ref,
        "ordName":ordName
      };

      final response = await api.delete(
        endpoint: "/inventory/salePurchase.php",
        data: data,
      );

      return response.data['msg'] == 'success';
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<OrderTxnModel> fetchOrderTxn({required String reference}) async {
    try {
      final response = await api.get(
        endpoint: "/inventory/spTransaction.php",
        queryParams: {'ref': reference},
      );

      // Convert the response data to OrderTxnModel
      return OrderTxnModel.fromMap(response.data);
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Transaction Types ........................................................
  Future<Map<String, dynamic>> addTxnType({required TxnTypeModel newType}) async {
    try {
      final response = await api.post(
          endpoint: "/setting/trnType.php",
          data: newType.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> updateTxnType({required TxnTypeModel newType}) async {
    try {
      final response = await api.put(
          endpoint: "/setting/trnType.php",
          data: newType.toMap()
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<Map<String, dynamic>> deleteTxnType({required String trnCode}) async {
    try {
      final response = await api.delete(
          endpoint: "/setting/trnType.php",
          data: {
            "trntCode": trnCode
          }
      );
      return response.data;
    } on DioException catch (e) {
      throw '${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }
  Future<List<TxnTypeModel>> getTxnTypes({String? trnCode}) async {
    try {
      final queryParams = {'trntCode': trnCode};
      // Fetch data from API
      final response = await api.get(
        endpoint: "/setting/trnType.php",
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
            .map((json) => TxnTypeModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }

  /// User Log .................................................................
  Future<List<UserLogModel>> getUserLog({String? usrName, String? fromDate, String? toDate}) async {
    try {
      final queryParams = {
        'usrName': usrName,
        'fromDate': fromDate,
        'toDate': toDate
      };
      // Fetch data from API
      final response = await api.post(
          endpoint: "/reports/userLogs.php",
          data: queryParams
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
            .map((json) => UserLogModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  ///Reports ...................................................................
  // Account Statement
  Future<AccountStatementModel> getAccountStatement({required int account, required String fromDate, required String toDate}) async {
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
  Future<GlStatementModel> getGlStatement({required int account, required String currency, required int branchCode, required String fromDate, required String toDate}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/glStatement.php",
          data: {
            "ccy": currency,
            "branch": branchCode,
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

      return GlStatementModel.fromApiResponse(decodedData);

    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw e.toString();
    }
  }
  //Get Transaction Details By Ref
  Future<TxnReportByRefModel> getTransactionByRefReport({required String ref}) async {
    try {
      final response = await api.get(
          endpoint: "/reports/referenceHistory.php",
          queryParams: {
            "ref": ref,
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

      return TxnReportByRefModel.fromMap(decodedData);

    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw e.toString();
    }
  }

  /// Dashboard Statistics.....................................................
  Future<List<DailyGrossModel>> getDailyGross({required String from, required String to, required int startGroup, required int stopGroup}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/dailyGrossing.php",
          data: {
            "from": from,
            "to": to,
            "startGroup": startGroup,
            "stopGroup": stopGroup
          }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => DailyGrossModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await api.get(
        endpoint: "/reports/counts.php",
      );

      if (response.data is Map && response.data['msg'] != null) {
        throw response.data['msg'];
      }

      if (response.data == null || response.data.isEmpty) {
        throw "No data received";
      }

      return DashboardStatsModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );

    } on DioException catch (e) {
      throw e.message ?? "Network error";
    } catch (e) {
      throw e.toString();
    }
  }
  Future<List<ArApModel>> getArApReport({String? name, String? ccy}) async {
    try {
      final response = await api.post(
        endpoint: "/reports/stakeholderBalances.php",
        data: {
          "name":name,
          "ccy":ccy
        }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ArApModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<TrialBalanceModel>> getTrialBalance({required String date}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/trialBalance.php",
          data: {
            "date":date,
          }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => TrialBalanceModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<TotalDailyTxnModel>> totalDailyTxnReport({required String fromDate, required String toDate}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/dailyTotalTransactions.php",
          data: {
            "fromDate":fromDate,
            "toDate":toDate
          }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => TotalDailyTxnModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<BalanceSheetModel> balanceSheet() async {
    try {
      final response = await api.get(
        endpoint: "/reports/balanceSheet.php",
      );

      // Check if API returned a message
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      // If response is null
      if (response.data == null) {
        throw Exception("No data found");
      }

      // Convert the JSON to BalanceSheetModel
      if (response.data is Map<String, dynamic>) {
        return BalanceSheetModel.fromMap(response.data);
      }

      throw Exception("Unexpected response format");
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<ExchangeRateReportModel>> exchangeRateReport({String? fromDate, String? toDate, String? fromCcy, String? toCcy}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/currencyRate.php",
          data: {
            "fromDate":fromDate,
            "toDate":toDate,
            "fromCcy": fromCcy,
            "toCcy": toCcy
          }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ExchangeRateReportModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<UsersReportModel>> getUsersReport({String? usrName, int? status, int? branch, String? role}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/usersList.php",
          data: {
            "username":usrName,
            "status":status,
            "branch": branch,
            "role": role
          }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => UsersReportModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
  Future<List<ShippingReportModel>> getShippingReport({int? vehicle, int? status, int? customer, String? fromDate, String? toDate}) async {
    try {
      final response = await api.post(
          endpoint: "/reports/shippingList.php",
          data: {
            "fromDate": fromDate,
            "toDate": toDate,
            "vehicle": vehicle,
            "customer": customer,
            "status": status
          }
      );

      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        throw Exception(response.data['msg']);
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ShippingReportModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw "$e";
    }
  }
}