import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:simple_wake_on_lan/constants.dart';
import 'package:simple_wake_on_lan/screens/about/about.dart';
import 'package:simple_wake_on_lan/screens/home/home.dart';
import 'package:simple_wake_on_lan/screens/settings/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  // Register dart_ping_ios with dart_ping
  DartPingIOS.register();
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (ThemeData light, ThemeData dark) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        theme: light,
        darkTheme: dark,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // current selected navigation index
  int selectedNavigationIndex = 0;

  // values from homePage which should be stored in memory while the app is running
  SortingOrder selectedMenu = SortingOrder.alphabetical;
  late List<bool> deviceTypesValues = List<bool>.filled(
      AppConstants().getChipsDeviceTypes().length, true,
      growable: false);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(
          title: AppLocalizations.of(context)!.homePageTitle,
          onSelectedMenuChange: (SortingOrder order) {
            setState(() {
              selectedMenu = order;
            });
          },
          selectedMenu: selectedMenu,
          onSelectedDeviceTypesChange: (List<bool> values) {
            setState(() {
              deviceTypesValues = values;
            });
          },
          deviceTypesValues: deviceTypesValues),
      SettingsPage(title: AppLocalizations.of(context)!.settingsPageTitle),
      AboutPage(title: AppLocalizations.of(context)!.aboutPageTitle),
    ];
    return Scaffold(
      body: screens[selectedNavigationIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedNavigationIndex = index;
          });
        },
        selectedIndex: selectedNavigationIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
              icon: const Icon(AppConstants.homeIcon),
              label: AppLocalizations.of(context)!.homePageLabel),
          NavigationDestination(
              icon: const Icon(
                AppConstants.settingsIcon,
              ),
              label: AppLocalizations.of(context)!.settingsPageTitle),
          NavigationDestination(
              icon: const Icon(
                AppConstants.aboutIcon,
              ),
              label: AppLocalizations.of(context)!.aboutPageTitle),
        ],
      ),
    );
  }
}
