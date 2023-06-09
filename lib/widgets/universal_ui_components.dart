import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/home/bottom_sheet_form.dart';
import 'chip_cards.dart';

void showCustomBottomSheet(
    {required BuildContext context, required ModularBottomFormPage formPage}) {
  showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    // only expand the bottom sheet to 85% of the screen height
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => formPage,
  );
}

Widget customDualChoiceAlertdialog(
    {String? title,
    Widget? child,
    IconData? icon,
    Color? iconColor,
    String? leftText,
    String? rightText,
    Color? leftColor,
    Color? rightColor,
    IconData? leftIcon,
    IconData? rightIcon,
    Function()? leftOnPressed,
    Function()? rightOnPressed}) {
  return customAlertdialog(
    title: title,
    child: child,
    icon: icon,
    iconColor: iconColor,
    actions: (leftIcon != null ||
            rightIcon != null ||
            leftText != null ||
            rightText != null)
        ? [
            TextButton(
              onPressed: leftOnPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leftIcon != null) Icon(leftIcon),
                  const SizedBox(width: 5),
                  if (leftText != null)
                    Text(leftText, style: TextStyle(color: leftColor)),
                ],
              ),
            ),
            TextButton(
              onPressed: rightOnPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rightIcon != null) Icon(rightIcon),
                  const SizedBox(width: 5),
                  if (rightText != null)
                    Text(
                      rightText,
                      style: TextStyle(color: rightColor),
                    ),
                ],
              ),
            ),
          ]
        : null,
  );
}

Widget customAlertdialog(
    {String? title,
    Widget? child,
    IconData? icon,
    Color? iconColor,
    List<Widget>? actions}) {
  return AlertDialog(
    title: title != null ? Text(title) : null,
    icon: icon != null
        ? Icon(
            icon,
            size: 80,
            color: iconColor,
          )
        : null,
    content: SingleChildScrollView(
      child: child,
    ),
    actions: actions,
  );
}

/// get the icon for a specific [deviceType]. If the device type is not found, return null
/// uses the AppConstants().getChipsDeviceTypes() list and searches for the device type matching the given deviceType
/// orElse in the firstWhere function is needed if the deviceType is not found in the list so no state error is thrown
IconData? getIcon(String? deviceType) {
  return AppConstants()
      .getChipsDeviceTypes()
      .firstWhere((element) => element.value == deviceType,
          orElse: () => const CustomChoiceChip(value: ''))
      .icon;
}
