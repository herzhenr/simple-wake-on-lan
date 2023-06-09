import 'dart:convert';
// import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:simple_wake_on_lan/constants.dart';
import 'dart:io';
import '../../services/database.dart';
import '../../services/data.dart';
import '../../widgets/chip_cards.dart';
import '../../widgets/layout_elements.dart';
import '../../widgets/universal_ui_components.dart';
import 'data_ops.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? themeValue = 1;
  bool colors = true;

  DeviceStorage deviceStorage = DeviceStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: AppConstants.screenPadding,
        children: [
          TextTitle(
            title: AppLocalizations.of(context)!.settingsAppearanceTitle,
            children: [
              // TextSubtitle can't be used as it is a Stateless widget and getThemeSelector() is Stateful when the theme changes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.settingsThemeSelectorTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  const ThemeSwitcher() //getThemeSelector()
                ],
              ),

              /// TODO Switch to toggle between system colors and app colors (Also define section to choose app colors)
              // TextSubtitle(
              //     title: AppLocalizations.of(context)!.settingsSystemColorsText,
              //     child: Switch(
              //       thumbIcon: thumbIcon,
              //       value: colors,
              //       onChanged: (bool value) {
              //         setState(() {
              //           colors = value;
              //         });
              //       },
              //     ))
            ],
          ),
          TextTitle(
              title: AppLocalizations.of(context)!.settingsAppDataTitle,
              children: [
                SpacedRow(
                  children: [
                    IconTextButton(
                      text: AppLocalizations.of(context)!.settingsExport,
                      icon: Icons.arrow_upward_outlined,
                      onPressed: shareJsonFile,
                    ),
                    IconTextButton(
                      text: AppLocalizations.of(context)!.settingsImport,
                      icon: Icons.arrow_downward_outlined,
                      onPressed: importJsonFile,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconTextButton(
                        text: AppLocalizations.of(context)!.settingsReset,
                        icon: Icons.delete_forever_outlined,
                        onPressed: () {
                          buildResetDialog(context);
                        }),
                  ],
                ),
              ]),
        ],
      ),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }

  Future<dynamic> buildResetDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return customDualChoiceAlertdialog(
              title: AppLocalizations.of(context)!.settingsReset,
              icon: AppConstants.warningIcon,
              iconColor: Theme.of(context).colorScheme.error,
              child:
                  Text(AppLocalizations.of(context)!.settingsResetDialogText),
              leftText: AppLocalizations.of(context)!.cancel,
              leftOnPressed: () => Navigator.pop(context),
              rightText:
                  AppLocalizations.of(context)!.settingsResetDialogButton,
              rightOnPressed: () => {
                    Navigator.pop(context),
                    deviceStorage.deleteAllDevices(),
                  },
              rightColor: Theme.of(context).colorScheme.error);
        });
  }

  // get the file form the user and show an alert dialog
  Future<void> importJsonFile() async {
    File? file = await getJsonFile();
    List<StorageDevice> importedDevices = [];
    if (file != null) {
      String fileExt = file.path.split('.').last;
      if (fileExt != 'json' && context.mounted) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return customDualChoiceAlertdialog(
                title: AppLocalizations.of(context)!
                    .settingsResetDialogWrongFormatTitle,
                iconColor: Theme.of(context).colorScheme.error,
                child: Text(AppLocalizations.of(context)!
                    .settingsResetDialogWrongFormatText(fileExt)),
                icon: AppConstants.warningIcon,
                rightText: AppLocalizations.of(context)!.ok,
                rightOnPressed: () => Navigator.pop(context),
              );
            });
        return;
      }
      try {
        final fileContents = await file.readAsString();
        final jsonData = json.decode(fileContents) as List<dynamic>;
        importedDevices =
            jsonData.map((item) => StorageDevice.fromJson(item)).toList();
      } on FileSystemException {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return customDualChoiceAlertdialog(
                  title: AppLocalizations.of(context)!
                      .settingsResetDialogWrongJsonFormatTitle,
                  iconColor: Theme.of(context).colorScheme.error,
                  child: Text(AppLocalizations.of(context)!
                      .settingsResetDialogWrongJsonFormatText),
                  icon: AppConstants.warningIcon,
                  rightText: AppLocalizations.of(context)!.ok,
                  rightOnPressed: () => Navigator.pop(context),
                );
              });
        }
        return;
      }
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return customDualChoiceAlertdialog(
                title: AppLocalizations.of(context)!.genericWarning,
                icon: AppConstants.warningIcon,
                iconColor: Theme.of(context).colorScheme.error,
                child: Text(AppLocalizations.of(context)!
                    .settingsResetDialogConfirmText),
                leftText: AppLocalizations.of(context)!.cancel,
                leftOnPressed: () => Navigator.pop(context),
                rightText: AppLocalizations.of(context)!
                    .settingsResetDialogConfirmButton,
                rightOnPressed: () => {
                  deviceStorage.deleteAllDevices(),
                  deviceStorage.saveDevices(importedDevices),
                  Navigator.pop(context),
                },
              );
            });
      }
    }
  }

  // Widget getThemeSelector() {
  //   List<CustomChoiceChip<AdaptiveThemeMode>> chipsTheme =
  //       AppConstants().getChipsTheme(context: context);
  //
  //   return ValueListenableBuilder(
  //     valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
  //     builder: (_, mode, child) {
  //       // update your UI
  //       return Wrap(
  //           spacing: 5.0,
  //           children: List<Widget>.generate(chipsTheme.length, (index) {
  //             String? label = chipsTheme[index].label;
  //             return ChoiceChip(
  //               label: Row(
  //                 children: [
  //                   if (label != null) Text(label),
  //                   //if (icon != null) const SizedBox(width: 10.0),
  //                   //if (icon != null) Icon(icon),
  //                 ],
  //               ),
  //               selected: mode == chipsTheme[index].value,
  //               onSelected: (bool selected) {
  //                 // setState(() {
  //                 //   themeValue = index; //selected ? index : null;
  //                 // });
  //                 AdaptiveTheme.of(context)
  //                     .setThemeMode(chipsTheme[index].value);
  //               },
  //             );
  //           }));
  //     },
  //   );
  // }

  // final MaterialStateProperty<Icon?> thumbIcon =
  //     MaterialStateProperty.resolveWith<Icon?>(
  //   (Set<MaterialState> states) {
  //     // Thumb icon when the switch is selected.
  //     if (states.contains(MaterialState.selected)) {
  //       return const Icon(AppConstants.checkIcon);
  //     }
  //     return const Icon(AppConstants.denyIcon);
  //   },
  // );
}
