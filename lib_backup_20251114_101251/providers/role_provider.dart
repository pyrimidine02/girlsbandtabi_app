import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

final userRoleProvider = FutureProvider<String?>((ref) async {
  try {
    final envelope = await ApiClient.instance.get(ApiConstants.me);
    final data = envelope.requireDataAsMap();
    return data['role'] as String?;
  } catch (_) {
    return null;
  }
});
