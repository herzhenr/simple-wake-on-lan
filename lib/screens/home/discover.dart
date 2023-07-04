import 'dart:async';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_wake_on_lan/constants.dart';
import 'bottom_sheet_form.dart';
import '../../services/data.dart';
import '../../services/network.dart';
import '../../widgets/layout_elements.dart';
import '../../widgets/universal_ui_components.dart';

class DiscoverPage extends StatefulWidget {
  final Function(List<StorageDevice>) updateDevicesList;

  const DiscoverPage({Key? key, required this.updateDevicesList})
      : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  void initState() {
    super.initState();
    initSubnet();
    _deviceDiscovery();
  }

  String? _subnet;

  Future<void> initSubnet() async {
    String? subnet = await NetworkInfo()
        .getWifiIP()
        .then((value) => value?.substring(0, value.lastIndexOf('.')));

    if (!mounted) return;

    setState(() {
      _subnet = subnet;
    });
  }

  // variables for discovering network devices and showing the progress in the ui
  StreamSubscription<NetworkDevice>? _subscription;
  final List<NetworkDevice> _devices = [];
  double _progress = 0.0;

  // method to discover devices on the network
  Future<void> _deviceDiscovery() async {
    setState(() {
      _devices.clear();
      _progress = 0.0;
    });

    // wait until _subnet is initialized
    while (_subnet == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final stream = findDevicesInNetwork(_subnet!, (progress) {
      if (!mounted) {
        // Exit the loop if the widget is no longer mounted.
        return;
      }
      setState(() {
        _progress = progress;
      });
    });

    _subscription = stream.listen((device) {
      if (!mounted) {
        // Exit the loop if the widget is no longer mounted.
        _subscription = null;
        return;
      }
      setState(() {
        _devices.add(device);
        //_devices.sort();
        _devices.sort((NetworkDevice a, NetworkDevice b) => -a.compareTo(b));
      });
    }, onDone: () {
      setState(() {
        _subscription = null;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.discoverTitle),
      ),
      floatingActionButton: ActionButton(
          onPressed: () => showCustomBottomSheet(
              context: context,
              formPage: NetworkDeviceFormPage(
                  title:
                      AppLocalizations.of(context)!.discoverAddDeviceAlertTitle,
                  device: NetworkDevice(),
                  onSubmitDeviceCallback: widget.updateDevicesList)),
          text: AppLocalizations.of(context)!.discoverAddCustomDeviceButton,
          icon: const Icon(Icons.add)),
      body: buildListview(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildListview() {
    return RefreshIndicator(
      // on refresh call network method and update the list
      onRefresh: () async {
        // on refresh should just be called when a scan of the network is done
        if (_subscription == null) {
          initSubnet();
          _deviceDiscovery();
        }
      },
      child: Column(
        children: [
          Visibility(
              visible: _subscription != null,
              child: LinearProgressIndicator(value: _progress)),
          Expanded(
            child: ListView(
              padding: AppConstants.screenPaddingScrollView,
              children: [
                TextTitle(
                  children: [
                    getSubnetInfo(),
                  ],
                ),
                TextTitle(
                  title:
                      AppLocalizations.of(context)!.discoverNetworkDevicesTitle,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_devices.isNotEmpty)
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              String? title, subtitle;
                              if (_devices[index].hostName != "") {
                                title = _devices[index].hostName;
                                subtitle = _devices[index].ipAddress;
                              } else {
                                title = _devices[index].ipAddress;
                              }
                              return DeviceCard(
                                title: title,
                                subtitle: subtitle,
                                onTap: () => showCustomBottomSheet(
                                    context: context,
                                    formPage: NetworkDeviceFormPage(
                                        title: AppLocalizations.of(context)!
                                            .discoverAddDeviceAlertTitle,
                                        device: _devices[index]
                                            .copyWith(wolPort: 9),
                                        onSubmitDeviceCallback:
                                            widget.updateDevicesList)),
                              );
                            },
                          ),
                        // if (_subscription == null)
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSubnetInfo() {
    String subnet =
        _subnet ?? AppLocalizations.of(context)!.discoverCardSubnetNoNetwork;
    return Card(
        elevation: 0,
        color:
            Theme.of(context).colorScheme.secondaryContainer, //primaryContainer
        child: InkWell(
            borderRadius: AppConstants.borderRadius,
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.discoverCardTitle),
              subtitle: Text(
                  "${AppLocalizations.of(context)!.discoverCardSubnet} $subnet"),
              minLeadingWidth: 0,
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(
                  Icons.wifi,
                ),
              ),
            )));
  }

  void showBottomSheet(
      {required String title, required NetworkDevice device, int? port}) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      // only expand the bottom sheet to 85% of the screen height
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => NetworkDeviceFormPage(
          title: title,
          device: device.copyWith(wolPort: port),
          onSubmitDeviceCallback: widget.updateDevicesList),
    );
  }
}
