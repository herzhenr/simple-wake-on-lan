import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_wake_on_lan/constants.dart';
import 'package:simple_wake_on_lan/screens/home/discover.dart';
import '../../widgets/layout_elements.dart';
import 'bottom_sheet_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/database.dart';
import '../../services/data.dart';
import '../../services/network.dart';
import '../../widgets/chip_cards.dart';
import '../../widgets/universal_ui_components.dart';

// This is the type used by the popup menu below.
enum SortingOrder { alphabetical, recently, type }

class HomePage extends StatefulWidget {
  HomePage(
      {super.key,
      required this.title,
      required this.onSelectedMenuChange,
      required this.selectedMenu,
      required this.onSelectedDeviceTypesChange,
      required this.deviceTypesValues});

  final String title;

  final ValueChanged<SortingOrder> onSelectedMenuChange;
  final SortingOrder selectedMenu;

  final ValueChanged<List<bool>> onSelectedDeviceTypesChange;
  final List<bool> deviceTypesValues;

  final chipsDeviceTypes = AppConstants().getChipsDeviceTypes();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _deviceStorage = DeviceStorage();
  List<StorageDevice> _devicesRaw = [];
  List<StorageDevice> _devices = [];
  bool _isLoading = false;

  late List<bool> deviceTypesValues = widget.deviceTypesValues;

  late SortingOrder selectedMenu = widget.selectedMenu;

  Timer? _pingDevicesTimer;

  @override
  void initState() {
    super.initState();
    _loadDevices().then((value) => {
          filterDevicesByType(),
          sortDevices(),
          _pingDevices(),
        });
  }

  @override
  void dispose() {
    _pingDevicesTimer?.cancel();
    super.dispose();
  }

  /// loads a list of devices from the device storage
  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final devices = await _deviceStorage.loadDevices();
      setState(() {
        _devicesRaw = devices;
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to load devices: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// sort Devices by chipsDeviceTypes selection
  void filterDevicesByType() {
    List<StorageDevice> sortedDevices = [];
    for (StorageDevice device in _devicesRaw) {
      if (device.deviceType == null) {
        sortedDevices.add(device);
      } else {
        for (int i = 0; i < widget.chipsDeviceTypes.length; i++) {
          if (deviceTypesValues[i] &&
              device.deviceType == widget.chipsDeviceTypes[i].value) {
            sortedDevices.add(device);
            break;
          }
        }
      }
    }
    setState(() {
      _devices = sortedDevices;
    });
  }

  /// sort devices by selectedMenu value. [alphabetical], [recently] and [type] are possible.
  void sortDevices() {
    switch (selectedMenu) {
      case SortingOrder.alphabetical:
        setState(() {
          _devices.sort((a, b) =>
              a.hostName.toLowerCase().compareTo(b.hostName.toLowerCase()));
        });
        break;
      case SortingOrder.recently:
        setState(() {
          _devices.sort((a, b) => b.modified.compareTo(a.modified));
        });
        break;
      case SortingOrder.type:
        setState(() {
          _devices.sort((a, b) => a.deviceType == null
              ? -1
              : a.deviceType!.compareTo(b.deviceType ?? ''));
        });
        break;
    }
  }

  /// ping devices periodically in the background to get the current status
  /// of the devices and update the ui accordingly
  void _pingDevices() {
    checkAllDevicesStatus();
    _pingDevicesTimer = Timer.periodic(
        const Duration(seconds: AppConstants.homePingInterval), (timer) {
      checkAllDevicesStatus();
    });
  }

  /// updates the status of all devices in [_devices]
  Future<void> checkAllDevicesStatus() async {
    for (StorageDevice device in _devices) {
      checkDeviceStatus(device);
    }
  }

  /// ping a device and update the ui accordingly
  /// [device] is the device to ping
  /// if the widget is not mounted anymore, the function will stop
  Future<void> checkDeviceStatus(StorageDevice device) async {
    bool isOnline = await pingDevice(ipAddress: device.ipAddress);
    if (mounted) {
      setState(() {
        device.isOnline = isOnline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: PopupMenuButton<SortingOrder>(
          icon: AppConstants.sort,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          // The menu should appear below the button. The offset is dependent of the selected menu item so the offset is calculated dependent of
          // the current selected menu item.
          offset: Offset(0,
              00 + 50.0 * (SortingOrder.values[selectedMenu.index].index + 1)),
          initialValue: selectedMenu,
          // Callback that sets the selected popup menu item.
          onSelected: (SortingOrder item) {
            setState(() {
              selectedMenu = item;
              widget.onSelectedMenuChange(item);
            });
            sortDevices();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SortingOrder>>[
            const PopupMenuItem<SortingOrder>(
              value: SortingOrder.alphabetical,
              child: Text('alphabetical'),
            ),
            const PopupMenuItem<SortingOrder>(
              value: SortingOrder.recently,
              child: Text('recently'),
            ),
            const PopupMenuItem<SortingOrder>(
              value: SortingOrder.type,
              child: Text('type'),
            ),
          ],
        ),
      ),
      floatingActionButton: ActionButton(
          onPressed: () async {
            final newDevice = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DiscoverPage(
                        updateDevicesList: updateDevicesList,
                        devices: _devices,
                      )),
            );
            if (newDevice != null) {
              setState(() {
                _devicesRaw.add(newDevice);
              });
            }
          },
          text: AppLocalizations.of(context)!.homeAddDeviceButton,
          icon: AppConstants.add),
      body: buildListview(),
    );
  }

  /// callback function for updating the list of devices
  /// [devices] is the list of devices
  /// [deviceId] is the changed device id. This devices gets pinged additionally to the background timer to get the current status.
  /// If it is set to null, no device gets pinged (e.g. if device gets deleted, this devices doesn't need to get pinged)
  updateDevicesList(List<StorageDevice> devices, String? deviceId) {
    setState(() {
      _devicesRaw = devices;
      filterDevicesByType();
      sortDevices();
      if (deviceId != null) {
        StorageDevice device =
            devices.firstWhere((element) => element.id == deviceId);
        // set online state to null because online state is not known yet
        device.isOnline = null;
        checkDeviceStatus(device);
      }
    });
  }

  Widget buildListview() {
    return RefreshIndicator(
      onRefresh: () async {
        _pingDevicesTimer?.cancel();
        // set online state for all devices to null because online state is not known yet
        for (StorageDevice device in _devices) {
          device.isOnline = null;
        }
        _pingDevices();
      },
      child: ListView(
        padding: AppConstants.screenPaddingScrollView,
        children: [
          TextTitle(
            title: AppLocalizations.of(context)!.homeFilterDevicesTitle,
            children: [
              SizedBox(
                height: 50,
                child: filterDevicesChipsV2(),
              ),
            ],
          ),
          TextTitle(
            title: AppLocalizations.of(context)!.homeDeviceListTitle,
            children: [buildDeviceList()],
          ),
        ],
      ),
    );
  }

  /// returns a List of Chips for filtering devices
  ListView filterDevicesChipsV2() {
    List<CustomChoiceChip<String>> chipsDeviceTypes =
        AppConstants().getChipsDeviceTypes(context: context);
    return ListView(
      primary: true,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: [
        Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(chipsDeviceTypes.length, (index) {
              String? label = chipsDeviceTypes[index].label;
              IconData? icon = chipsDeviceTypes[index].icon;
              return ActionChip(
                avatar: Icon(icon),
                label: Row(
                  children: [
                    if (label != null) Text(label),
                  ],
                ),
                backgroundColor: deviceTypesValues[index]
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: deviceTypesValues[index]
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
                // selected: mode == chipsTheme[index].value,
                onPressed: () {
                  setState(() {
                    deviceTypesValues[index] = !deviceTypesValues[index];
                    filterDevicesByType();
                  });
                },
              );
            })),
      ],
    );
  }

  /// returns a List of Chips for filtering devices
  ListView filterDevicesChipsV1() {
    List<CustomChoiceChip<String>> chipsDeviceTypes =
        AppConstants().getChipsDeviceTypes(context: context);
    return ListView(
      primary: true,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: [
        Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(chipsDeviceTypes.length, (index) {
              String? label = chipsDeviceTypes[index].label;
              IconData? icon = chipsDeviceTypes[index].icon;
              return ChoiceChip(
                label: IntrinsicWidth(
                  child: Row(
                    children: [
                      if (label != null) Text(label),
                      if (icon != null) const SizedBox(width: 10.0),
                      if (icon != null) Icon(icon),
                    ],
                  ),
                ),
                selected: deviceTypesValues[index],
                onSelected: (bool selected) {
                  setState(() {
                    deviceTypesValues[index] = selected;
                    filterDevicesByType();
                  });
                },
              );
            })),
      ],
    );
  }

  /// returns the list of devices
  Widget buildDeviceList() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _devices.isEmpty
            ? Text(AppLocalizations.of(context)!.homeNoDevices,
                style: Theme.of(context).textTheme.bodyMedium)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return buildDevice(device);
                },
              );
  }

  /// returns a single device card
  buildDevice(StorageDevice device) {
    String title;
    String? subtitle;
    if (device.hostName != "") {
      title = device.hostName;
      subtitle = device.ipAddress;
    } else {
      title = device.ipAddress;
    }
    return DeviceCard(
      isOnline: device.isOnline,
      title: title,
      subtitle: subtitle,
      deviceType: device.deviceType,
      onTap: () {
        showDeviceOptionsDialog(device: device);
      },
    );
  }

  /// shows the alert dialog for waking and editing the device
  showDeviceOptionsDialog({required StorageDevice device}) {
    String title = "", subtitle1 = "", subtitle2 = "";
    if (device.hostName != "") {
      title = device.hostName;
      subtitle1 = "${AppConstants.ipText}: ${device.ipAddress}";
      subtitle2 = "${AppConstants.macText}: ${device.macAddress}";
    } else if (device.macAddress != "") {
      title = device.ipAddress;
      subtitle1 = "${AppConstants.macText}: ${device.macAddress}";
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return deviceInfoDialog(
              device: device,
              title: title,
              subtitle1: subtitle1,
              subtitle2: subtitle2);
        });
  }

  /// returns the actual alert dialog for waking and editing the device
  Widget deviceInfoDialog(
      {required StorageDevice device,
      required String title,
      required String subtitle1,
      required String subtitle2}) {
    return customDualChoiceAlertdialog(
        title: title != "" ? title : null,
        child: (subtitle1 != "" || subtitle2 != "" || device.isOnline != null)
            ? Column(
                children: [
                  if (device.isOnline != null)
                    Text(
                        device.isOnline!
                            ? AppLocalizations.of(context)!.homeDeviceCardOnline
                            : AppLocalizations.of(context)!
                                .homeDeviceCardOffline,
                        style: TextStyle(
                            color: device.isOnline!
                                ? AppConstants.successMessageColor
                                : Theme.of(context).colorScheme.error)),
                  if (subtitle1 != "") Text(subtitle1),
                  if (subtitle2 != "") Text(subtitle2),
                ],
              )
            : null,
        icon: getIcon(device.deviceType),
        iconColor: device.isOnline != null
            ? device.isOnline!
                ? AppConstants.successMessageColor
                : Theme.of(context).colorScheme.error
            : null,
        leftText: AppLocalizations.of(context)!.homeDeviceCardWakeButton,
        rightText: AppLocalizations.of(context)!.homeDeviceCardEditButton,
        leftIcon: AppConstants.wakeUp,
        rightIcon: AppConstants.edit,
        leftOnPressed: () => {Navigator.pop(context), showWakeUpDialog(device)},
        rightOnPressed: () => {
              Navigator.of(context).pop(),
              showCustomBottomSheet(
                  context: context,
                  formPage: EditDeviceFormPage(
                      title: "Edit Device",
                      device: device,
                      devices: _devices,
                      onSubmitDeviceCallback: updateDevicesList))
            });
  }

  /// shows the Alert Dialog for waking the device.
  /// [device] is the device to wake.
  Future<dynamic> showWakeUpDialog(StorageDevice device) {
    return showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder<List<Message>>(
              stream: sendWolAndGetMessages(
                  context: context, device: device.toNetworkDevice()),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Message>> snapshot) {
                // set color, text and icon of dialog box according to the arrived messages
                Color? color;
                String rightText = AppLocalizations.of(context)!.cancel;
                IconData? rightIcon = AppConstants.denyIcon;
                if (snapshot.hasData &&
                    snapshot.data!.last.type == MsgType.online) {
                  color = AppConstants.successMessageColor;
                  rightText = AppLocalizations.of(context)!.done;
                  rightIcon = AppConstants.checkIcon;
                }

                if (snapshot.hasData &&
                    snapshot.data!.last.type == MsgType.error) {
                  color = Theme.of(context).colorScheme.error;
                  rightText = AppLocalizations.of(context)!.ok;
                  rightIcon = null;
                }

                return customDualChoiceAlertdialog(
                  title: AppLocalizations.of(context)!.homeWolCardTitle,
                  child: snapshot.hasData
                      ? SizedBox(
                          width: 200,
                          child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final Message message = snapshot.data![index];
                              return Text(
                                message.text,
                                style: TextStyle(
                                  color: (message.type == MsgType.error)
                                      ? Theme.of(context).colorScheme.error
                                      : (message.type == MsgType.check ||
                                              message.type == MsgType.online)
                                          ? AppConstants.successMessageColor
                                          : null,
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                  icon: AppConstants.wakeUp,
                  iconColor: color,
                  rightText: rightText,
                  rightIcon: rightIcon,
                  rightOnPressed: () => {Navigator.of(context).pop()},
                );
              });
        });
  }
}
