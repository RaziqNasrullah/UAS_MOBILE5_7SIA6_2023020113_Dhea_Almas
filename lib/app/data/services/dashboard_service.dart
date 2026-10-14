import '../../models/dashboard_summary.dart';
import 'api_service.dart';

class DashboardService {
  DashboardService(this._api);
  final ApiService _api;

  Future<DashboardSummary> getSummary() async {
    final res = await _api.get('dashboard/summary.php');
    return DashboardSummary.fromJson(asMap(res.data));
  }
}
