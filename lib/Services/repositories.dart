
import 'package:dio/dio.dart';
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Models/ind_model.dart';

class Repositories {
  final ApiServices api;
  const Repositories(this.api);

  //Get User profile | Fetch User profile using logged in username
  Future<List<StakeholdersModel>> getAllCompanyAccounts({int? indId}) async {
    try {
      final response = await api.get(
        endpoint: "/stakeholder/personal.php",
      );

      // Handle message response for invalid account/name
      if (response.data is Map && response.data['msg'] != null) {
        if (response.data['msg'] == 'invalid perID') {
          return []; // Return empty list for invalid search
        }
        throw Exception(response.data['msg']); // Throw other messages
      }

      // Handle empty response
      if (response.data == null || response.data.isEmpty) {
        return [];
      }

      // Handle list response
      if (response.data is List) {
        final users = (response.data as List).where((item) => item != null).map<StakeholdersModel?>((accountJson) {
          try {
            return StakeholdersModel.fromMap(accountJson);
          } catch (e) {
            return null;
          }
        }).whereType<StakeholdersModel>().toList();
        return users;
      }

      return [];
    } on DioException catch (e) {
      throw "${e.message}";
    } catch (e) {
      throw e.toString();
    }
  }

}