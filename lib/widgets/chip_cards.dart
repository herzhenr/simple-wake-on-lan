import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class CustomChoiceChip<T> {
  const CustomChoiceChip({this.label, this.icon, required this.value});

  final String? label;
  final IconData? icon;
  final T value;
}

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    List<CustomChoiceChip<AdaptiveThemeMode>> chipsTheme =
        AppConstants().getChipsTheme(context: context);
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, mode, child) {
        // update your UI
        return Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(chipsTheme.length, (index) {
              String? label = chipsTheme[index].label;
              IconData? icon = chipsTheme[index].icon;
              return ActionChip(
                avatar: Icon(icon),
                label: Row(
                  children: [
                    if (label != null) Text(label),
                  ],
                ),
                backgroundColor: mode == chipsTheme[index].value
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: mode == chipsTheme[index].value
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
                // selected: mode == chipsTheme[index].value,
                onPressed: () {
                  AdaptiveTheme.of(context)
                      .setThemeMode(chipsTheme[index].value);
                },
              );
            }));
      },
    );
  }
}

Widget getIconChip({name = String}) {
  return IntrinsicWidth(
    child: Row(
      children: [
        Text(name),
        const SizedBox(width: 10.0),
        const Icon(Icons.check_circle_outline)
      ],
    ),
  );
}
