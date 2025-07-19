import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import '../helpers/event_bus.dart';
import '../widgets/title_list.dart';
import '../widgets/model_selector.dart';
import '../widgets/list_header.dart';
import '../widgets/modern_components.dart';
import '../theme/app_theme.dart';

import 'chat_view.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final _drawer = AdvancedDrawerController();
  List<Widget>? _action;
  Widget? _currentWidget;

  //--------------------------------------------------------------------------//
  @override
  void initState() {
    super.initState();
    _initEventConnector();
    _currentWidget = const ChatView();
  }

  //--------------------------------------------------------------------------//
  void _initEventConnector() async {
    MyEventBus().on<ChangeTitleEvent>().listen((event) {
      if (mounted) {
        _action = event.action;
        setState(() {});
      }
    });

    MyEventBus().on<CloseDrawerEvent>().listen((event) {
      _drawer.hideDrawer();
    });

    MyEventBus().on<ReloadModelEvent>().listen((event) {
      setState(() {}); // Just refresh the state to rebuild ModelSelector
    });
  }

  //--------------------------------------------------------------------------//
  void _handleMenuButtonPressed() {
    _drawer.showDrawer();
  }

  //--------------------------------------------------------------------------//
  PreferredSizeWidget _appbar() {
    return ModernAppBar(
      title: const ModelSelector(),
      leading: ModernIconButton(
        icon: Icons.menu,
        onPressed: _handleMenuButtonPressed,
        style: IconButtonStyle.normal,
      ),
      actions: _action,
    );
  }

  //--------------------------------------------------------------------------//
  Widget _listContainer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppBorderRadius.lg),
          bottomRight: Radius.circular(AppBorderRadius.lg),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ListHeader(),
          Expanded(child: TitleList()),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AdvancedDrawer(
      backdropColor: AppColors.primary(isDark).withValues(alpha: 0.7),
      controller: _drawer,
      animateChildDecoration: true,
      rtlOpening: false,
      openScale: 1.0,
      openRatio: 0.8,
      disabledGestures: true,
      child: Scaffold(
        backgroundColor: AppColors.background(isDark),
        appBar: _appbar(),
        body: Container(child: _currentWidget),
      ),
      drawer: SafeArea(
        child: _listContainer(),
      ),
    );
  }
}
