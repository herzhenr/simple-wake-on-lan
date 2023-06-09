import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';
import '../../widgets/layout_elements.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.title});

  final String title;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Uri _url = Uri.parse(AppConstants.sourceCodeLink);

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      log('Could not launch $url');
    }
  }

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
            title: AppLocalizations.of(context)!.aboutInfoTitle,
            children: [
              TextBox(text: AppLocalizations.of(context)!.aboutInfoText),
            ],
          ),
          TextTitle(
            title: AppLocalizations.of(context)!.aboutOpenSourceTitle,
            children: [
              SpacedRow(
                children: [
                  IconTextButton(
                    text:
                        AppLocalizations.of(context)!.aboutOpenSourceCodeButton,
                    icon: AppConstants.sourceCodeIcon,
                    onPressed: () async {
                      await _launchUrl(_url);
                    },
                  ),
                  IconTextButton(
                    text: AppLocalizations.of(context)!
                        .aboutOpenSourceLicenseButton,
                    icon: AppConstants.licenseIcon,
                    onPressed: () => {showLicensePage(context: context)},
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
