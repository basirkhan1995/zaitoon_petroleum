import 'package:dio/dio.dart';
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/user_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';


class Repositories {
  final ApiServices api;
  const Repositories(this.api);

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

  ///Accounts | Stakeholder's Account ..........................................
  Future<List<AccountsModel>> getAccounts({int? ownerId}) async {
    try {
      // Build query parameters dynamically
      final queryParams = ownerId != null ? {'perID': ownerId} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/stakeholder/account.php",
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

  ///Users .....................................................................
  Future<List<UsersModel>> getUsers({int? usrOwner}) async {
    try {
      // Build query parameters dynamically
      final queryParams = usrOwner != null ? {'perID': usrOwner} : null;

      // Fetch data from API
      final response = await api.get(
        endpoint: "/user/users.php",
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
}