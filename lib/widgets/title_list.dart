import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../provider/main_provider.dart';
import '../helpers/event_bus.dart';

import 'dialogs.dart';

class TitleList extends StatefulWidget {
  const TitleList({super.key});

  @override
  createState() => _TitleListState();
}

class _TitleListState extends State<TitleList> {
  bool _showWait = false;
  List _titles = [];
  int _selectedIndex = 0;
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initEventConnector();
    _loadData(refresh: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  //--------------------------------------------------------------------------//
  void _initEventConnector() async {
    MyEventBus().on<RefreshMainListEvent>().listen((event) {
      _loadData();
    });
  }

  //--------------------------------------------------------------------------//
  Future<void> _loadData({bool refresh = false}) async {
    if (mounted) {
      _showWait = true;
      setState(() {});

      _titles = await context.read<MainProvider>().qdb.getTitles();
      if (refresh) {
        if (_titles.length > 0) _selectTitle(0);
      }

      _showWait = false;
      setState(() {});
    }
  }

  //--------------------------------------------------------------------------//
  void _deleteQuestion(String groupid) async {
    final provider = context.read<MainProvider>();
    final result = await AskDialog.show(context,
        title: tr("l_delete"), message: tr("l_delete_question"));
    if (result == true) {
      await provider.qdb.deleteQuestions(groupid);
      _loadData();
      _selectedIndex = 0;
      setState(() {});
    }
  }

  //--------------------------------------------------------------------------//
  Widget _titlePanel(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String title = _titles[index]["question"];
    if (title.length > 70) {
      title = "${title.substring(0, 70)}...";
      title = title.replaceAll("\n", " ");
      title = title.trimLeft();
    }

    return Container(
      decoration: BoxDecoration(
        color: _selectedIndex == index
            ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFFAFAFA)
                          : const Color(0xFF09090B),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _titles[index]["created"].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    _deleteQuestion(_titles[index]["groupid"]);
                  },
                  child: Icon(
                    Icons.delete_outline,
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
      ),
    );
  }

  //--------------------------------------------------------------------------//
  void _selectTitle(int index) {
    final provider = context.read<MainProvider>();

    _selectedIndex = index;
    provider.curGroupId = _titles[index]["groupid"];
    MyEventBus().fire(CloseDrawerEvent());
    MyEventBus().fire(LoadHistoryGroupListEvent());
    setState(() {});
  }

  //--------------------------------------------------------------------------//
  void _startSearch() async {
    _showWait = true;
    setState(() {});

    final provider = context.read<MainProvider>();
    if (_search.text != "") {
      _titles = await provider.qdb.searchKeywords(_search.text);
    }
    _showWait = false;
    setState(() {});
  }

  //--------------------------------------------------------------------------//
  Widget _searchPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDark ? const Color(0xFF09090B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              style: TextStyle(
                color:
                    isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF27272A) // Zinc-800
                        : const Color(0xFFF4F4F5), // Zinc-200
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF27272A) // Zinc-800
                        : const Color(0xFFF4F4F5), // Zinc-200
                    width: 1,
                  ),
                ),
                focusColor: isDark
                    ? const Color(0xFF18181B) // Zinc-900 (darker)
                    : const Color(0xFFE4E4E7), // Zinc-200
                filled: true,

                fillColor: isDark
                    ? const Color(0xFF18181B) // Zinc-900 (darker)
                    : const Color(0xFFE4E4E7), // Zinc-200
                hintText: tr("l_search"),
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF71717A),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              ),
              onChanged: (String value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                if (value.isEmpty) {
                  _loadData(refresh: true);
                } else {
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _startSearch();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------//
  Future<void> _onRefresh() async {
    return _loadData(refresh: true);
  }

  //--------------------------------------------------------------------------//
  Widget _buildList() {
    if (_showWait) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_titles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: [
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text(
                tr("l_no_items"),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF71717A),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _titles.length,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _selectTitle(index);
              },
              child: _titlePanel(index),
            ),
          );
        },
      ),
    );
  }

  //--------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF09090B) : Colors.white,
      child: Column(
        children: [
          _searchPanel(),
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
    );
  }
}
