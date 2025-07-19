import 'package:flutter/material.dart';

import '../helpers/event_bus.dart';
import 'app_title.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09090B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      height: 56,
      child: Row(
        children: [
          const Expanded(child: AppTitle()),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  MyEventBus().fire(RefreshMainListEvent());
                },
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: isDark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF71717A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
