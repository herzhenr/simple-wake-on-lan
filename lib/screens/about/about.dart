import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
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

  String? _wifiAddress;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initWifiAddress();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = <String, dynamic>{
          'Error:': 'Web platform isn\'t supported'
        };
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            deviceData =
                _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
            break;
          case TargetPlatform.iOS:
            deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
            break;
          case TargetPlatform.fuchsia:
            deviceData = <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            };
            break;
          case TargetPlatform.linux:
            deviceData = <String, dynamic>{
              'Error:': 'Linux platform isn\'t supported'
            };
            break;
          case TargetPlatform.macOS:
            deviceData = <String, dynamic>{
              'Error:': 'MacOS platform isn\'t supported'
            };
            break;
          case TargetPlatform.windows:
            deviceData = <String, dynamic>{
              'Error:': 'Windows platform isn\'t supported'
            };
            break;
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  Future<void> initWifiAddress() async {
    String? wifiAddress = await NetworkInfo().getWifiIP();

    if (!mounted) return;

    setState(() {
      _wifiAddress = wifiAddress;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'model': build.model,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'utsname.nodename': data.utsname.nodename,
    };
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
            title: AppLocalizations.of(context)!.aboutDevice,
            children: [
              getDeviceInfoCard(),
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
                  const VersionText(text: "Version "),
                  VersionText(text: widget.packageInfo.version),
                  VersionText(text: " (${widget.packageInfo.buildNumber})"),
                ],
              ),
            ],
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// return card with device info
  Widget getDeviceInfoCard() {
    return Card(
        elevation: 0,
        color:
            Theme.of(context).colorScheme.secondaryContainer, //primaryContainer
        child: InkWell(
            borderRadius: AppConstants.borderRadius,
            child: ListTile(
              // title: const Text("iPhone XR"),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _deviceData.keys.map((String property) {
                  return Text('${_deviceData[property]}');
                }).toList(), // Text("IP: $_wifiAddress \nMAC: 12:12:12:12:12")
              ),
              subtitle: Text(
                "IP: $_wifiAddress",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              minLeadingWidth: 0,
              // ignore: sized_box_for_whitespace
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(
                  Icons.phone_iphone,
                ),
              ),
            )));
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
