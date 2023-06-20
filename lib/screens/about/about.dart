import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';
import '../../widgets/layout_elements.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.title, required this.packageInfo});
  final PackageInfo packageInfo;
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
          const SizedBox(height: 20),
          Column(
            children: [
              VersionText(text: widget.packageInfo.appName),
              VersionText(text: widget.packageInfo.packageName),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VersionText(text: widget.packageInfo.version),
                  const SizedBox(width: 10),
                  VersionText(text: "(${widget.packageInfo.buildNumber})"),
                ],
              ),
            ],
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// return text with Version styling
class VersionText extends StatelessWidget {
  const VersionText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }
}
