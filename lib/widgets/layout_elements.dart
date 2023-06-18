import 'package:flutter/material.dart';
import 'package:simple_wake_on_lan/widgets/universal_ui_components.dart';

import '../constants.dart';

///
class TextTitle extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const TextTitle({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    // add a sized box between each button
    for (int i = 1; i < children.length; i += 2) {
      children.insert(i, const SizedBox(height: 5));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        Padding(
            padding: const EdgeInsets.only(left: 5, top: 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children))
      ]),
    );
  }
}

///
class TextSubtitle extends StatelessWidget {
  final String title;
  final Widget child;

  const TextSubtitle({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        child
      ],
    );
  }
}

/// A TextBox in the form of a Material Card with text in it
class TextBox extends StatelessWidget {
  final String text;

  const TextBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color:
            Theme.of(context).colorScheme.secondaryContainer, //primaryContainer
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(child: Text(text))));
  }
}

/// TODO control, if the button is expanded or not
class IconTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const IconTextButton(
      {super.key, required this.text, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonal(
        onPressed: onPressed,
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 5),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final VoidCallback? onPressed;

  const ActionButton(
      {super.key, required this.text, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: text,
      label: Text(text),
      icon: icon,
      enableFeedback: true,
    );
  }
}

/// Creates multiple Widgets in a row with a sized box between each button. Recommended to use with 2 Elements
class SpacedRow extends StatelessWidget {
  final List<Widget> children;

  const SpacedRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // add a sized box between each button
    for (int i = 1; i < children.length; i += 2) {
      children.insert(i, const SizedBox(width: 15));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}

class CustomCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title, subtitle, deviceType;
  final Widget? trailing;

  const CustomCard(
      {super.key,
      this.onTap,
      this.title,
      this.subtitle,
      this.deviceType,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color:
            Theme.of(context).colorScheme.secondaryContainer, //primaryContainer
        child: InkWell(
          borderRadius: AppConstants.borderRadius,
          onTap: onTap,
          child: ListTile(
            title: title != null ? Text(title!) : null,
            subtitle: subtitle != null ? Text(subtitle!) : null,
            minLeadingWidth: 0,
            // ignore: sized_box_for_whitespace
            leading: deviceType != null && getIcon(deviceType!) != null
                ? SizedBox(
                    height: double.infinity,
                    child: Icon(
                      getIcon(deviceType!),
                    ))
                : null,
            trailing: trailing,
          ),
        ));
  }
}
