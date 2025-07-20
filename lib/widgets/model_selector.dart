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

  // Helper function to parse model name from full model string
  Map<String, String> _parseModelInfo(String modelString) {
    // Split by colon to separate model name from parameters
    final parts = modelString.split(':');

    if (parts.length < 2) {
      return {
        'name': _capitalizeModelName(modelString),
        'parameters': '',
      };
    }

    final modelName = _capitalizeModelName(parts[0]);
    final paramString = parts[1];
    final parameters = _formatParameters(paramString);

    return {
      'name': modelName,
      'parameters': parameters,
    };
  }

  // Helper function to capitalize model name properly
  String _capitalizeModelName(String name) {
    if (name.isEmpty) return name;

    // Handle common model names
    final lowerName = name.toLowerCase();
    switch (lowerName) {
      case 'gemma':
      case 'gemma2':
      case 'gemma3':
        return name.substring(0, 1).toUpperCase() + name.substring(1);
      case 'llama':
      case 'llama2':
      case 'llama3':
      case 'llama3.1':
      case 'llama3.2':
        return name.substring(0, 1).toUpperCase() + name.substring(1);
      case 'codellama':
        return 'CodeLlama';
      case 'mistral':
        return 'Mistral';
      case 'phi':
      case 'phi3':
        return name.substring(0, 1).toUpperCase() + name.substring(1);
      default:
        return name.substring(0, 1).toUpperCase() + name.substring(1);
    }
  }

  // Helper function to format parameter size
  String _formatParameters(String paramString) {
    if (paramString.isEmpty) return '';

    final lowerParam = paramString.toLowerCase();

    // Handle common parameter formats
    if (lowerParam.contains('b')) {
      final number = lowerParam.replaceAll('b', '');
      try {
        final value = double.parse(number);
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}T parameters';
        } else if (value >= 1) {
          return '${value.toStringAsFixed(0)}B parameters';
        } else {
          return '${(value * 1000).toStringAsFixed(0)}M parameters';
        }
      } catch (e) {
        return '$number billion parameters';
      }
    } else if (lowerParam.contains('m')) {
      final number = lowerParam.replaceAll('m', '');
      try {
        final value = double.parse(number);
        return '${value.toStringAsFixed(0)}M parameters';
      } catch (e) {
        return '$number million parameters';
      }
    } else {
      // Try to parse as number and assume billions
      try {
        final value = double.parse(lowerParam);
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}T parameters';
        } else {
          return '${value.toStringAsFixed(0)}B parameters';
        }
      } catch (e) {
        return paramString;
      }
    }
  }

  // Widget to display model info in a compact format
  Widget _buildModelDisplay(String modelString, bool isDark,
      {bool isSelected = false, bool isInDropdown = false}) {
    final modelInfo = _parseModelInfo(modelString);
    final modelName = modelInfo['name'] ?? '';
    final parameters = modelInfo['parameters'] ?? '';

    // For very constrained spaces, use a single line with inline parameters
    if (!isInDropdown && parameters.isNotEmpty) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: modelName,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF4F4F5) // Zinc-100
                    : const Color(0xFF09090B), // Zinc-950
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            TextSpan(
              text: ' • $parameters',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF71717A) // Zinc-500
                    : const Color(0xFF6B7280), // Gray-500
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
              ),
            ),
          ],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    // For dropdown items, use column layout with proper constraints
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            modelName,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFFF4F4F5) // Zinc-100
                  : const Color(0xFF09090B), // Zinc-950
              fontSize: isInDropdown ? 14 : 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.1,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(width: 10),
          if (parameters.isNotEmpty && isInDropdown) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                parameters,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF71717A) // Zinc-500
                      : const Color(0xFF6B7280), // Gray-500
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.05,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

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
                width: 250,
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
                          horizontal: 10, vertical: 4),
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
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: isDark
                                    ? const Color(0xFF22C55E) // Green-500
                                    : const Color(0xFF16A34A), // Green-600
                              ),
                            ),
                          Expanded(
                            child: _buildModelDisplay(
                              option,
                              isDark,
                              isSelected: provider.selectedModel == option,
                              isInDropdown: true,
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
                      const SizedBox(width: 32),
                      _buildModelDisplay(
                        displayModel,
                        isDark,
                        isSelected: true,
                        isInDropdown: false,
                      ),
                      const SizedBox(width: 8),
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
