import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/core/widgets/navigation/gbt_bottom_nav.dart';

void main() {
  testWidgets('GBTBottomNav triggers onTap with selected index', (
    tester,
  ) async {
    var tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: GBTBottomNav(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
            items: const [
              GBTBottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
              ),
              GBTBottomNavItem(
                icon: Icons.music_note_outlined,
                activeIcon: Icons.music_note,
                label: '라이브',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tappedIndex, -1);

    await tester.tap(find.text('라이브'));
    await tester.pump();

    expect(tappedIndex, 1);
  });
}
