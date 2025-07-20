import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import '../helpers/event_bus.dart';
import '../widgets/title_list.dart';
import '../widgets/model_selector.dart';
import '../widgets/list_header.dart';
import '../widgets/modern_components.dart';

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
        color: isDark
            ? const Color(0xFF09090B) // Zinc-950
            : const Color(0xFFFFFFFF), // Pure white
        border: Border(
          right: BorderSide(
            color: isDark
                ? const Color(0xFF27272A) // Zinc-800
                : const Color(0xFFE4E4E7), // Zinc-200
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(4, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListHeader(),
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
      backdropColor: isDark
          ? Colors.black.withValues(alpha: 0.7)
          : Colors.black.withValues(alpha: 0.4),
      controller: _drawer,
      animateChildDecoration: false, // Less animated, more Android-like
      rtlOpening: false,
      openScale: 0.95, // Subtle scale effect
      openRatio: 0.8,
      disabledGestures: false, // Enable gestures for Android-like behavior
      animationDuration:
          const Duration(milliseconds: 200), // Faster, Android-like
      animationCurve: Curves.easeOut,
      drawer: SafeArea(
        child: _listContainer(),
      ), // Clean easing
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A) // Near black
            : const Color(0xFFFFFFFF), // Pure white
        appBar: _appbar(),
        body: Container(child: _currentWidget),
      ),
    );
  }
}
