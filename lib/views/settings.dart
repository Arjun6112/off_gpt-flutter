import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../utils/platform_utils.dart';
import '../widgets/text_fields.dart';
import '../provider/main_provider.dart';
import '../provider/theme_provider.dart';
import '../widgets/dialogs.dart';
import '../helpers/event_bus.dart';

class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  final server_address = TextEditingController();
  final instruction = TextEditingController();
  final temperature = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //--------------------------------------------------------------------------//
  void _loadPreferences() {
    final provider = context.read<MainProvider>();
    provider.loadPreferences();

    server_address.text = provider.baseUrl;
    instruction.text = provider.instruction;
    temperature.text = provider.temperature.toString();
  }

  //--------------------------------------------------------------------------//
  void _deleteAllRecords() async {
    final provider = context.read<MainProvider>();
    final result = await AskDialog.show(context,
        title: 'Delete all data', message: 'Are you sure?');
    if (result == true) {
      await provider.qdb.deleteAllRecords();
      MyEventBus().fire(NewChatBeginEvent());
      MyEventBus().fire(RefreshMainListEvent());
    }
  }

  //--------------------------------------------------------------------------//
  Widget ActionCardPanel(IconData leadIcon, String title, String? subtitle,
      IconData trailIcon, Function action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: action as void Function()?,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  leadIcon,
                  color: isDark
                      ? const Color(0xFF10B981)
                      : const Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 12),
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
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  trailIcon,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF71717A),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------//
  bool _isValidUrl(String url) {
    final urlPattern = RegExp(
      r'^(http|https):\/\/([\w-]+\.)+[\w-]+(:\d+)?(\/[\w- .\/?%&=]*)?$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlPattern.hasMatch(url);
  }

  //--------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<MainProvider>();
    final isDesktop = isDesktopOrTablet();

    final widgets = [
      // Section Header
      Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Text(
          tr("l_ollama_setting"),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Server Address Section
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: QTextField(tr("l_server_address"), server_address, (_) {}),
            ),
            const SizedBox(width: 16),
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_isValidUrl(server_address.text)) {
                    final reached =
                        await provider.setBaseUrl(server_address.text);
                    if (reached) {
                      MyEventBus().fire(ReloadModelEvent());
                      showToast(
                        tr("l_success"),
                        context: context,
                        position: StyledToastPosition.center,
                        backgroundColor: const Color(0xFF10B981), // Emerald-500
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        duration: const Duration(seconds: 2),
                        animation: StyledToastAnimation.slideFromBottom,
                        reverseAnimation: StyledToastAnimation.slideToBottom,
                        animDuration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        reverseCurve: Curves.easeIn,
                      );
                    } else {
                      showToast(
                        tr("l_error_url"),
                        context: context,
                        position: StyledToastPosition.center,
                        backgroundColor: const Color(0xFFEF4444), // Red-500
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        duration: const Duration(seconds: 3),
                        animation: StyledToastAnimation.slideFromBottom,
                        reverseAnimation: StyledToastAnimation.slideToBottom,
                        animDuration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        reverseCurve: Curves.easeIn,
                      );
                    }
                  } else {
                    AskDialog.show(context,
                        title: tr("l_error"), message: tr("l_invalid_url"));
                  }
                },
                icon: Icon(
                  Icons.network_check,
                  size: 16,
                  color: isDark ? const Color(0xFF09090B) : Colors.white,
                ),
                label: Text(
                  "Test",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF09090B) : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFFAFAFA)
                      : const Color(0xFF09090B),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      QTextField(tr("l_instructions"), instruction, (String value) {
        provider.setInstruction(value);
      }, maxLines: 5),

      QTextField(tr("l_temp"), temperature, (String value) {
        provider.setTemperature(double.parse(value));
      }),

      // Theme Section
      Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final isDark = themeProvider.themeMode == ThemeMode.dark;
            return ActionCardPanel(
              isDark ? Icons.light_mode : Icons.dark_mode,
              "Theme Mode",
              isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
              Icons.arrow_forward_ios,
              () {
                themeProvider.toggleTheme();
              },
            );
          },
        ),
      ),

      ActionCardPanel(Icons.delete_forever_outlined, tr("l_delete"),
          tr("l_delete_all"), Icons.arrow_forward_ios, () {
        _deleteAllRecords();
      }),

      ActionCardPanel(Icons.settings_applications_outlined, tr("l_app_info"),
          null, Icons.arrow_forward_ios, () {
        AppSettings.openAppSettings();
      }),
    ];

    final content = Container(
      padding: const EdgeInsets.all(24),
      child: Material(
        color: isDark ? const Color(0xFF09090B) : Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => widgets[index],
                childCount: widgets.length,
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return content;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
        elevation: 0,
        title: Text(
          tr("l_settings"),
          style: TextStyle(
            color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _loadPreferences();
            },
            icon: Icon(
              Icons.refresh,
              color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: content,
      ),
    );
  }
}
