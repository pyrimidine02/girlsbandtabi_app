import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/content_filter_provider.dart';

final selectionPersistenceProvider = Provider<Future<void>>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  // Load once on startup
  final savedProject = prefs.getString('selected_project');
  final savedBand = prefs.getString('selected_band');

  final currentProject = ref.read(selectedProjectProvider);
  final currentBand = ref.read(selectedBandProvider);

  if (currentProject == null && savedProject != null) {
    ref.read(selectedProjectProvider.notifier).state = savedProject;
  }
  if (currentBand == null && savedBand != null) {
    ref.read(selectedBandProvider.notifier).state = savedBand;
  }

  // Persist on changes
  ref.listen<String?>(selectedProjectProvider, (prev, next) async {
    final p = await SharedPreferences.getInstance();
    if (next == null) {
      await p.remove('selected_project');
    } else {
      await p.setString('selected_project', next);
    }
  });

  ref.listen<String?>(selectedBandProvider, (prev, next) async {
    final p = await SharedPreferences.getInstance();
    if (next == null) {
      await p.remove('selected_band');
    } else {
      await p.setString('selected_band', next);
    }
  });
});

