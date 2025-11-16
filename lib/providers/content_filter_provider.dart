import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'project_provider.dart';

/// Currently selected project code.
/// null means "전체"(All).
final selectedProjectProvider = StateProvider<String?>((ref) => ref.watch(selectedProjectIdentifierProvider));
final selectedProjectNameProvider = StateProvider<String?>((ref) => null);

/// Currently selected band id for the selected project.
/// null means "전체"(All bands).
final selectedBandProvider = StateProvider<String?>((ref) => null);
final selectedBandNameProvider = StateProvider<String?>((ref) => null);
