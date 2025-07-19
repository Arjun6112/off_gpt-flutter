import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';

import 'views/drawer.dart';
import 'views/desktop_view.dart';
import 'provider/main_provider.dart';
import 'provider/theme_provider.dart';
import 'utils/platform_utils.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MainProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ko', 'KR'),
          Locale('ja', 'JP')
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: const OffGPT()),
  ));
}

class OffGPT extends StatelessWidget {
  const OffGPT({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          theme: AppTheme.lightTheme.copyWith(
            textTheme:
                GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            textTheme: GoogleFonts.interTextTheme(AppTheme.darkTheme.textTheme),
          ),
          themeMode: themeProvider.themeMode,
          home: const InitializationWrapper(),
        );
      },
    );
  }
}

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InitializationWrapperState createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setLocale(context);
      _initializeApp();
    });
  }

  Future<void> setLocale(BuildContext context) async {
    String currentLocale = Intl.getCurrentLocale();
    List<String> parts = currentLocale.split('_');

    switch (parts[0]) {
      case 'ko':
        context.setLocale(const Locale('ko', 'KR'));
        break;
      case 'ja':
        context.setLocale(const Locale('ja', 'JP'));
        break;
      default:
        context.setLocale(const Locale('en', 'US'));
        break;
    }
  }

  Future<void> _initializeApp() async {
    final provider = Provider.of<MainProvider>(context, listen: false);
    await provider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(),
                  const SizedBox(height: 20),
                  const Text('Initializing...').tr(),
                ],
              ),
            ),
          );
        }

        return isDesktopOrTablet() ? const DesktopView() : const MyDrawer();
      },
    );
  }
}
