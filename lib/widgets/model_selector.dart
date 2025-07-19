import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:easy_localization/easy_localization.dart';

import '../provider/main_provider.dart';
import '../helpers/event_bus.dart';

class ModelSelector extends StatefulWidget {
  const ModelSelector({super.key});

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  final MenuController _menuController = MenuController();
  List<String> _models = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initEventConnector();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadModels();
    });
  }

  //--------------------------------------------------------------------------//
  void _initEventConnector() async {
    MyEventBus().on<ReloadModelEvent>().listen((event) {
      _loadModels();
    });
  }

  //--------------------------------------------------------------------------//
  void _loadModels() {
    setState(() => _isLoading = true);

    final provider = context.read<MainProvider>();
    if (provider.modelList != null && provider.modelList!.isNotEmpty) {
      _models = provider.modelList!
          .map((Model e) => e.model)
          .where((model) => model != null)
          .map((model) => model!)
          .toList();

      if (provider.selectedModel == null && _models.isNotEmpty) {
        Future.microtask(() {
          provider.setSelectedModel(_models.first);
        });
      }
    } else {
      _models = [];
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<MainProvider>(
      builder: (context, provider, child) {
        if (_isLoading) {
          return SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? const Color(0xFF71717A) // Zinc-500
                    : const Color(0xFF71717A), // Zinc-500
              ),
            ),
          );
        }

        if (_models.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF18181B) // Zinc-900
                  : const Color(0xFFFEF2F2), // Red-50
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF7F1D1D) // Red-900
                    : const Color(0xFFFECACA), // Red-200
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFFF87171) // Red-400
                      : const Color(0xDC2626), // Red-600
                ),
                const SizedBox(width: 6),
                Text(
                  tr("l_no_models"),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF87171) // Red-400
                        : const Color(0xDC2626), // Red-600
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final displayModel = provider.selectedModel ??
            (_models.isNotEmpty ? _models.first : tr("l_no_model"));

        return MenuAnchor(
          alignmentOffset: const Offset(0, 8),
          controller: _menuController,
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(
              isDark
                  ? const Color(0xFF09090B) // Zinc-950
                  : const Color(0xFFFFFFFF), // Pure white
            ),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(8),
            side: WidgetStateProperty.all(
              BorderSide(
                color: isDark
                    ? const Color(0xFF27272A) // Zinc-800
                    : const Color(0xFFE4E4E7), // Zinc-200
                width: 1,
              ),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          menuChildren: <Widget>[
            for (final String option in _models)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      provider.setSelectedModel(option);
                      _menuController.close();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: provider.selectedModel == option
                            ? (isDark
                                ? const Color(0xFF18181B) // Zinc-900
                                : const Color(0xFFF1F5F9)) // Slate-100
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (provider.selectedModel == option)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: isDark
                                    ? const Color(0xFF22C55E) // Green-500
                                    : const Color(0xFF16A34A), // Green-600
                              ),
                            ),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF4F4F5) // Zinc-100
                                    : const Color(0xFF09090B), // Zinc-950
                                fontSize: 14,
                                fontWeight: provider.selectedModel == option
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          builder: (context, controller, child) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayModel,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFF4F4F5) // Zinc-100
                              : const Color(0xFF09090B), // Zinc-950
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF71717A) // Zinc-500
                            : const Color(0xFF71717A), // Zinc-500
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
