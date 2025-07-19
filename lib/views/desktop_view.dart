import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

import 'chat_view.dart';
import '../widgets/title_list.dart';
import '../widgets/model_selector.dart';
import '../widgets/list_header.dart';
import '../widgets/app_title.dart';
import '../widgets/modern_components.dart';
import '../helpers/event_bus.dart';
import '../theme/app_theme.dart';

class DesktopView extends StatefulWidget {
  const DesktopView({super.key});

  @override
  createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView> {
  final double _initialWeight = 0.35;
  List<Widget>? _action;

  @override
  void initState() {
    super.initState();
    _initEventConnector();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //--------------------------------------------------------------------------//
  void _initEventConnector() async {
    MyEventBus().on<ChangeTitleEvent>().listen((event) {
      if (mounted) {
        _action = event.action;
        setState(() {});
      }
    });
  }

  //--------------------------------------------------------------------------//
  PreferredSizeWidget _buildToolbar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ModernAppBar(
      title: Row(
        children: [
          AppTitle(textColor: AppColors.textPrimary(isDark)),
          const SizedBox(width: AppSpacing.lg),
          const ModelSelector(),
          const Spacer(),
        ],
      ),
      backgroundColor: AppColors.surface(isDark),
      actions: _action,
    );
  }

  //--------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: _buildToolbar(),
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        indicator: SplitIndicator(
          viewMode: SplitViewMode.Horizontal,
          color: AppColors.border(isDark),
        ),
        activeIndicator: SplitIndicator(
          viewMode: SplitViewMode.Horizontal,
          color: AppColors.accent(isDark),
        ),
        controller:
            SplitViewController(weights: [_initialWeight, 1 - _initialWeight]),
        children: [
          // Left panel (1 part)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              border: Border(
                right: BorderSide(color: AppColors.border(isDark)),
              ),
            ),
            child: const Column(
              children: [
                ListHeader(),
                Expanded(child: TitleList()),
              ],
            ),
          ),
          // Right panel (2 parts)
          Container(
            color: AppColors.background(isDark),
            child: const ChatView(),
          ),
        ],
      ),
    );
  }
}
