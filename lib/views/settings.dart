import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../utils/platform_utils.dart';
import '../widgets/text_fields.dart';
import '../widgets/modern_components.dart';
import '../provider/main_provider.dart';
import '../provider/theme_provider.dart';
import '../widgets/dialogs.dart';
import '../helpers/event_bus.dart';
import '../theme/app_theme.dart';

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
    return ModernCard(
      margin:
          const EdgeInsets.symmetric(horizontal: 0, vertical: AppSpacing.xs),
      child: ModernListTile(
        leading: Icon(leadIcon, color: AppColors.accent(isDark)),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: subtitle != null
            ? Text(subtitle, style: Theme.of(context).textTheme.bodyMedium)
            : null,
        trailing: Icon(trailIcon, color: AppColors.textTertiary(isDark)),
        onTap: action as void Function()?,
        showBorder: false,
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
    final version =
        provider.version + ' (' + provider.buildNumber.toString() + ')';
    final isDesktop = isDesktopOrTablet(); // Use the new function

    final widgets = [
      ListTile(
          title: Text(tr("l_ollama_setting"),
              style: Theme.of(context).textTheme.headlineSmall)),
      Row(
        children: [
          Expanded(
              child:
                  QTextField(tr("l_server_address"), server_address, (_) {})),
          const SizedBox(width: AppSpacing.md),
          ModernButton(
            text: "Test",
            icon: Icons.network_check,
            onPressed: () async {
              if (_isValidUrl(server_address.text)) {
                final reached = await provider.setBaseUrl(server_address.text);
                if (reached) {
                  MyEventBus().fire(ReloadModelEvent());
                  showToast(tr("l_success"),
                      context: context, position: StyledToastPosition.center);
                } else {
                  showToast(tr("l_error_url"),
                      context: context, position: StyledToastPosition.center);
                }
              } else {
                AskDialog.show(context,
                    title: tr("l_error"), message: tr("l_invalid_url"));
              }
            },
          ),
        ],
      ),
      QTextField(tr("l_instructions"), instruction, (String value) {
        provider.setInstruction(value);
      }, maxLines: 5),
      QTextField(tr("l_temp"), temperature, (String value) {
        provider.setTemperature(double.parse(value));
      }),
      Consumer<ThemeProvider>(
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
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
      appBar: AppBar(
        title: Row(
          children: [
            Text(tr("l_settings"),
                style: TextStyle(
                    color: AppColors.surface(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.bold))
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                _loadPreferences();
              },
              icon: Icon(Icons.refresh, color: AppColors.surface(isDark))),
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
