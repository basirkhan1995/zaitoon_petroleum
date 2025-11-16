
import 'package:dio/dio.dart';
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Models/ind_model.dart';

class Repositories {
  final ApiServices api;
  const Repositories(this.api);

  //Get User profile | Fetch User profile using logged in username
  Future<List<StakeholdersModel>> getStakeholders({int? indId}) async {
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
            .map((json) => StakeholdersModel.fromMap(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw "Network error: ${e.message}";
    } catch (e) {
      throw "Unexpected error: $e";
    }
  }


}