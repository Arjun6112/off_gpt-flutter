import 'package:flutter/material.dart';

import '../helpers/event_bus.dart';
import '../theme/app_theme.dart';
import 'app_title.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary(isDark),
        border: Border(bottom: BorderSide(color: AppColors.border(isDark))),
      ),
      height: 56,
      child: Row(
        children: [
          AppTitle(),
          Spacer(),
          IconButton(
              onPressed: () {
                MyEventBus().fire(RefreshMainListEvent());
              },
              icon: Icon(Icons.refresh, color: AppColors.surface(isDark))),
        ],
      ),
    );
  }
}
