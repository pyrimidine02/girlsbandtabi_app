import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../models/home_summary_model.dart';
import '../services/home_service.dart';
import 'content_filter_provider.dart';

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

final homeSummaryProvider = FutureProvider.autoDispose<HomeSummary>((ref) async {
  final service = ref.watch(homeServiceProvider);
  final project = ref.watch(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
  final unit = ref.watch(selectedBandProvider);
  return service.getSummary(
    projectId: project,
    unitIds: unit != null ? [unit] : null,
  );
});
