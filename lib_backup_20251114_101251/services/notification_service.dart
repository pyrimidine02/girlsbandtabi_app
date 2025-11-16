import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class NotificationService {
  NotificationService();

  final ApiClient _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final envelope = await _api.get(
      ApiConstants.notifications,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
    final raw = envelope.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic>
            ? (raw['items'] as List?) ?? const <dynamic>[]
            : const <dynamic>[]);
    return list
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<void> markRead(String id) async {
    await _api.post(ApiConstants.notificationRead(id));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final envelope = await _api.get(ApiConstants.notificationSettings);
    return envelope.requireDataAsMap();
  }

  Future<void> updateSettings(Map<String, dynamic> body) async {
    await _api.put(ApiConstants.notificationSettings, data: body);
  }
}
