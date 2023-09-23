import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:simple_wake_on_lan/widgets/chip_cards.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppConstants {
  /// Navigation Bar Icons
  static const homeIcon = Icons.home;
  static const settingsIcon = Icons.settings;
  static const aboutIcon = Icons.info;

  /// HomePage Elements
  static const wakeUp = Icons.power_settings_new_outlined;
  static const edit = Icons.mode_edit_outline_outlined;
  static const macText = 'MAC';
  static const ipText = 'IP';
  static const add = Icon(Icons.add);
  static const sort = Icon(Icons.sort);

  // Home Ping Timeouts and Intervals for scanning
  static const homePingTimeout = 1;
  static const homePingInterval = 12;

  // Wake Up Dialog Elements
  static const errorMessageColor = Colors.red;
  static const successMessageColor = Colors.green;
  static const infoMessageColor = Colors.black;

  // Discover Page Elements
  static const addCustomDeviceType = 'desktop';

  // Form Elements
  static const formIcon = Icons.done_rounded;
  static const nameValidationRegex = r'^.{1,100}$';
  static const ipValidationRegex =
      r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$';
  static const ipSubStringValidationRegex =
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]{1,2})\.){0,3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]{1,2}))?$';
  static const macValidationRegex =
      r'^(?:[0-9A-Fa-f]{2}([-:]))(?:[0-9A-Fa-f]{2}\1){4}[0-9A-Fa-f]{2}$';
  static const macSubStringValidationRegex =
      r'^(?:[0-9A-Fa-f]{2}(?:([-:])|$)){0,5}[0-9A-Fa-f]{0,2}$';
  static const portValidationRegex =
      r'^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$';
  static const formWrongFormatIcon = Icons.assignment_outlined;
  static const formInvalidArgument = Icons.cancel_outlined;

  // replacement patterns for the rich text controllers of mac and ip address
  Map<RegExp, TextStyle> macPattern = {
    RegExp(r"[:-]"):
        const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
  };

  Map<RegExp, TextStyle> ipPattern = {
    RegExp(r"\."):
        const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
  };

  // WOL Port Chips
  List<CustomChoiceChip<int>> getChipsWolPorts({BuildContext? context}) {
    final List<CustomChoiceChip<int>> chipsWolPorts = <CustomChoiceChip<int>>[
      const CustomChoiceChip(value: 7),
      const CustomChoiceChip(value: 9),
    ];
    if (context != null) {
      return chipsWolPorts
          .map((e) => CustomChoiceChip<int>(
              label: AppLocalizations.of(context)!.formPort(e.value),
              value: e.value))
          .toList();
    } else {
      return chipsWolPorts;
    }
  }

  // Icon chips
  List<CustomChoiceChip<String>> getChipsDeviceTypes({BuildContext? context}) {
    return <CustomChoiceChip<String>>[
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceServer
              : null,
          icon: Icons.storage_rounded,
          value: 'server'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceDesktop
              : null,
          icon: Icons.desktop_mac_rounded,
          value: 'desktop'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceLaptop
              : null,
          icon: Icons.laptop_mac,
          value: 'laptop'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoicePrinter
              : null,
          icon: Icons.print_rounded,
          value: 'printer'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceNetwork
              : null,
          icon: Icons.lan_rounded,
          value: 'network'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceIOT
              : null,
          icon: Icons.smart_toy,
          value: 'iot'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceTv
              : null,
          icon: Icons.tv_rounded,
          value: 'tv'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceMobile
              : null,
          icon: Icons.phone_iphone,
          value: 'mobile'),
      CustomChoiceChip(
          label: context != null
              ? AppLocalizations.of(context)!.deviceChoiceOther
              : null,
          icon: Icons.tune_rounded,
          value: 'other'),
    ];
  }

  // Theme Chips
  List<CustomChoiceChip<AdaptiveThemeMode>> getChipsTheme(
      {required BuildContext context}) {
    return <CustomChoiceChip<AdaptiveThemeMode>>[
      CustomChoiceChip(
          label: AppLocalizations.of(context)!.settingsThemeSelectorSystem,
          icon: Icons.brightness_4_rounded,
          value: AdaptiveThemeMode.system),
      CustomChoiceChip(
          label: AppLocalizations.of(context)!.settingsThemeSelectorLight,
          icon: Icons.brightness_5_rounded,
          value: AdaptiveThemeMode.light),
      CustomChoiceChip(
          label: AppLocalizations.of(context)!.settingsThemeSelectorDark,
          icon: Icons.brightness_2_rounded,
          value: AdaptiveThemeMode.dark)
    ];
  }

  /// SettingsPage Elements
  static const warningIcon = Icons.warning;
  static const checkIcon = Icons.check;
  static const denyIcon = Icons.close;

  /// AboutPage Elements
  static const sourceCodeIcon = Icons.code;
  static const licenseIcon = Icons.article;
  static const sourceCodeLink =
      'https://github.com/herzhenr/simple-wake-on-lan';

  /// Other
  static const screenPadding =
      EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0);
  static const screenPaddingScrollView =
      EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 80);
  static BorderRadius borderRadius = BorderRadius.circular(10);
}
