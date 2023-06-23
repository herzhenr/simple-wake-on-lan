import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_wake_on_lan/constants.dart';
import 'package:simple_wake_on_lan/screens/home/discover.dart';
import 'package:simple_wake_on_lan/screens/home/home.dart';
import 'package:simple_wake_on_lan/services/data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_wake_on_lan/widgets/layout_elements.dart';
import '../../services/database.dart';
import '../../services/form_input_formatters.dart';
import '../../widgets/chip_cards.dart';
import '../../widgets/universal_ui_components.dart';

abstract class ModularBottomFormPage extends StatefulWidget {
  final String title;
  final Device device;
  final Function(List<StorageDevice>) onSubmitDeviceCallback;
  final bool deleteButton;

  ModularBottomFormPage(
      {Key? key,
      required this.device,
      required this.title,
      required this.onSubmitDeviceCallback,
      this.deleteButton = false})
      : super(key: key);

  // text controllers for the text input fields
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerIp = TextEditingController();
  final TextEditingController controllerMac = TextEditingController();
  final TextEditingController controllerPort = TextEditingController();
  final TextEditingController controllerIcon = TextEditingController();

  final formKeyIp = GlobalKey<FormState>();
  final formKeyMac = GlobalKey<FormState>();
  final formKeyName = GlobalKey<FormState>();
  final formKeyPort = GlobalKey<FormState>();

  final chipDeviceTypes = AppConstants().getChipsDeviceTypes();
  final chipWolPorts = AppConstants().getChipsWolPorts();

  /// creates a [NetworkDevice] or [StorageDevice] class out of the currently stored inputs in the TextEditingControllers
  Device get getDevice {
    final wolPort =
        controllerPort.text.isEmpty ? null : int.parse(controllerPort.text);
    final deviceType = controllerIcon.text.isEmpty ? null : controllerIcon.text;
    if (device is StorageDevice) {
      final storageDevice = device as StorageDevice;
      return StorageDevice(
          id: storageDevice.id,
          hostName: controllerName.text,
          ipAddress: controllerIp.text,
          macAddress: controllerMac.text,
          modified: DateTime.now(),
          wolPort: wolPort,
          deviceType: deviceType);
    } else {
      return NetworkDevice(
        hostName: controllerName.text,
        ipAddress: controllerIp.text,
        macAddress: controllerMac.text,
        wolPort: wolPort,
        deviceType: deviceType,
      );
    }
  }

  // DeviceStorage object to save the device to the json file
  final deviceStorage = DeviceStorage();

  /// dataOperationOnSave() is an abstract method that is implemented in the child classes and is called when the submitButton is pressed
  /// it saves the device to the json file and returns the updated [StorageDevice] list
  Future<List<StorageDevice>> dataOperationOnSave();

  /// dataOperationOnDelete() is triggered when the delete button is pressed and delete a device from the json file and returns the updated [StorageDevice] list
  Future<List<StorageDevice>> dataOperationOnDelete() async {
    StorageDevice device = getDevice as StorageDevice;
    List<StorageDevice> devices = await deviceStorage.deleteDevice(
      device.id,
    );
    return devices;
  }

  // Future<List<StorageDevice>> dataOperationOnDelete();

  @override
  State<ModularBottomFormPage> createState() => _ModularBottomFormPageState();
}

class _ModularBottomFormPageState extends State<ModularBottomFormPage> {
  // set label of chipsWolPorts to the translated string
  late List<CustomChoiceChip<int>> chipsWolPorts =
      AppConstants().getChipsWolPorts(context: context);

  // variables for the chip selectors and initial port value
  int? indexWolSelector;
  int? indexIconSelector;

  @override
  void initState() {
    super.initState();
    // initialize the text controllers
    widget.controllerName.text = widget.device.hostName;
    widget.controllerIp.text = widget.device.ipAddress;
    widget.controllerMac.text = widget.device.macAddress;

    // initialize the port text controller and the chip selector. AppConstants().chipsWolPorts
    final wolElement = widget.chipWolPorts
        .where((element) => element.value == widget.device.wolPort);
    if (wolElement.isNotEmpty) {
      indexWolSelector = widget.chipWolPorts.indexOf(wolElement.first);
    }
    if (widget.device.wolPort != null) {
      widget.controllerPort.text = widget.device.wolPort.toString();
    }

    // initialize the icon selector
    final deviceType = widget.chipDeviceTypes
        .where((element) => element.value == widget.device.deviceType);
    if (deviceType.isNotEmpty) {
      indexIconSelector = widget.chipDeviceTypes.indexOf(deviceType.first);
    }
    if (widget.device.deviceType != null) {
      widget.controllerIcon.text = widget.device.deviceType.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // GestureDetector is required to close the keyboard when the user taps outside of the text input fields
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 15, 20, MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          primary: true,
          shrinkWrap: true,
          children: [
            dragIndicator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                buildSaveButton(context),
              ],
            ),
            getCustomTextFormField(
              label: AppLocalizations.of(context)!.formNameHint,
              formKey: widget.formKeyName,
              controller: widget.controllerName,
              validator: createValidator(AppConstants.nameValidationRegex,
                  AppLocalizations.of(context)!.formNameError),
            ),
            getCustomTextFormField(
              label: AppLocalizations.of(context)!.formIpHint,
              formKey: widget.formKeyIp,
              controller: widget.controllerIp,
              validator: createValidator(AppConstants.ipValidationRegex,
                  AppLocalizations.of(context)!.formIpError),
              // inputFormatters: [IPAddressFormatter()]
            ),
            getCustomTextFormField(
                label: AppLocalizations.of(context)!.formMacHint,
                formKey: widget.formKeyMac,
                controller: widget.controllerMac,
                validator: createValidator(AppConstants.macValidationRegex,
                    AppLocalizations.of(context)!.formMacError),
                inputFormatters: [MACAddressFormatter()]),
            const SizedBox(
              height: 20,
            ),
            buildPortSelector(textTheme),
            buildIconSelector(textTheme),
            if (widget.deleteButton) buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  /// return a button for saving the user input on the form to the device storage
  Padding buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Transform.translate(
        offset: const Offset(0, 0),
        child: ActionButton(
            onPressed: () => {
                  validateFormFields(onSubmitDeviceCallback: () async {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    List<StorageDevice> device =
                        await widget.dataOperationOnSave();
                    // sent device to callback function in order to update the UI
                    widget.onSubmitDeviceCallback(device);
                  })
                },
            text: AppLocalizations.of(context)!.formApplyButtonText,
            icon: const Icon(AppConstants.formIcon)),
      ),
    );
  }

  /// validates the user input on the form and calls the [onSubmitDeviceCallback] if the input is valid
  /// otherwise it shows an error dialog which lists the invalid fields
  /// the user has the option to save the device anyway and the [onSubmitDeviceCallback] is called again or to cancel the operation
  /// [onSubmitDeviceCallback] the callback function that is called when the user decides to save the device
  void validateFormFields({Function()? onSubmitDeviceCallback}) {
    List<String> errorMessage = [];

    if (!widget.formKeyName.currentState!.validate()) {
      errorMessage.add(AppLocalizations.of(context)!.formErrorMessageName);
    }
    if (!widget.formKeyIp.currentState!.validate()) {
      errorMessage.add(AppLocalizations.of(context)!.formErrorMessageIp);
    }
    if (!widget.formKeyMac.currentState!.validate()) {
      errorMessage.add(AppLocalizations.of(context)!.formErrorMessageMac);
    }
    if (!widget.formKeyPort.currentState!.validate()) {
      errorMessage.add(AppLocalizations.of(context)!.formErrorMessagePort);
    }
    if (indexIconSelector == null) {
      errorMessage.add(AppLocalizations.of(context)!.formErrorMessageType);
    }

    if (errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return customDualChoiceAlertdialog(
            title: AppLocalizations.of(context)!.formIconErrorTitle,
            icon: AppConstants.formWrongFormatIcon,
            iconColor: Theme.of(context).colorScheme.error,
            child: Column(
              children: errorMessage
                  .map((error) => Row(children: [
                        Icon(
                          AppConstants.formInvalidArgument,
                          size: 15,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 5),
                        Text(error)
                      ]))
                  .toList(),
            ),
            leftText: AppLocalizations.of(context)!.back,
            leftOnPressed: () {
              Navigator.of(context).pop();
            },
            rightText: AppLocalizations.of(context)!.saveWithError,
            rightColor: Theme.of(context).colorScheme.error,
            rightOnPressed: onSubmitDeviceCallback,
          );
        },
      );
    } else if (onSubmitDeviceCallback != null) {
      onSubmitDeviceCallback();
    }
  }

  /// Pill shaped container which tries to indicate that the bottom sheet can be dragged
  Center dragIndicator() {
    return Center(
      child: Container(
          height: 5.0,
          width: 40.0,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(Radius.circular(8.0)))),
    );
  }

  /// returns a custom text form field
  /// * [label] the label of the text form field
  /// * [controller] the TextEditingController of the text form field
  /// * [validator] a validator function which can be created with [createValidator]
  /// * [onSaved] the onSaved function called when the form is saved
  Widget getCustomTextFormField(
      {String? label,
      required TextEditingController controller,
      required GlobalKey<FormState> formKey,
      String? Function(String?)? validator,
      String? Function(String?)? onSaved,
      List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Form(
        key: formKey,
        child: TextFormField(
          inputFormatters: inputFormatters,
          autovalidateMode: AutovalidateMode.always,
          validator: validator,
          controller: controller,
          onSaved: onSaved,
          cursorColor: Theme.of(context).colorScheme.primaryContainer,
          decoration: InputDecoration(
            isDense: true,
            labelText: label,
            errorStyle: const TextStyle(height: 0.1),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
          ),
        ),
      ),
    );
  }

  /// returns a custom selector and text input field for the port
  /// * [textTheme] the text theme of the current context
  Row buildPortSelector(TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.formPortLabel,
                style: textTheme.labelLarge),
            SizedBox(
              height: 45,
              child: Wrap(
                  spacing: 5.0,
                  children:
                      List<Widget>.generate(chipsWolPorts.length, (index) {
                    String? label = chipsWolPorts[index].label;
                    IconData? icon = chipsWolPorts[index].icon;
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
                      side: widget.formKeyPort.currentState?.validate() == false
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            )
                          : null,
                      selected: indexWolSelector == index,
                      onSelected: (bool selected) {
                        setState(() {
                          indexWolSelector = selected ? index : null;
                          (selected)
                              ? widget.controllerPort.text =
                                  chipsWolPorts[index].value.toString()
                              : widget.controllerPort.text = '';
                        });
                      },
                    );
                  })),
            ),
          ],
        ),
        SizedBox(
          width: 90,
          child: getCustomTextFormField(
            label: AppLocalizations.of(context)!.formPortHint,
            formKey: widget.formKeyPort,
            controller: widget.controllerPort,
            validator: createValidator(AppConstants.portValidationRegex,
                AppLocalizations.of(context)!.formPortError),
            onSaved: (String? value) {
              // TODO ugly
              setState(() {
                if (value == '9') {
                  indexWolSelector = 1;
                } else if (value == '7') {
                  indexWolSelector = 0;
                } else {
                  indexWolSelector = null;
                }
              });
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// returns a custom selector for the icon of the device
  /// * [textTheme] the text theme of the current context
  Column buildIconSelector(TextTheme textTheme) {
    List<CustomChoiceChip<String>> chipsDeviceTypes =
        AppConstants().getChipsDeviceTypes(context: context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(AppLocalizations.of(context)!.formIconLabel,
            style: textTheme.labelLarge),
        const SizedBox(height: 3.0),
        SizedBox(
          height: 45,
          child: ListView(
            primary: true,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              Wrap(
                  spacing: 5.0,
                  runSpacing: 0.0,
                  children:
                      List<Widget>.generate(chipsDeviceTypes.length, (index) {
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
                      side: indexIconSelector == null
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            )
                          : null,
                      selected: indexIconSelector == index,
                      onSelected: (bool selected) {
                        setState(() {
                          indexIconSelector = selected ? index : null;
                          if (selected) {
                            widget.controllerIcon.text =
                                chipsDeviceTypes[index].value.toString();
                          } else {
                            widget.controllerIcon.text = '';
                          }
                        });
                      },
                    );
                  }).toList()),
            ],
          ),
        ),
        // error text
        if (indexIconSelector == null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              AppLocalizations.of(context)!.formIconError,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }

  /// return a button to delete the device
  /// * [textTheme] the text theme of the current context
  Widget buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        onPressed: () {
          showDeleteDialog();
        },
        child: Text(AppLocalizations.of(context)!.formDeleteAlertTitle,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDualChoiceAlertdialog(
          title: AppLocalizations.of(context)!.formDeleteAlertTitle,
          icon: Icons.delete_outlined,
          iconColor: Theme.of(context).colorScheme.error,
          child: Text.rich(TextSpan(
            children: <TextSpan>[
              TextSpan(text: AppLocalizations.of(context)!.formDeleteAlertText),
              if (widget.controllerName.text.isNotEmpty)
                TextSpan(
                    text: " ${widget.controllerName.text}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '?'),
            ],
          )),
          leftText: AppLocalizations.of(context)!.cancel,
          leftOnPressed: () {
            Navigator.of(context).pop();
          },
          rightText: AppLocalizations.of(context)!.formDeleteAlertDelete,
          rightColor: Theme.of(context).colorScheme.error,
          rightOnPressed: () async {
            Navigator.popUntil(context, (route) => route.isFirst);
            List<StorageDevice> device = await widget.dataOperationOnDelete();
            // sent device to callback function in order to update the UI
            widget.onSubmitDeviceCallback(device);
          },
        );
      },
    );
  }

  /// returns a custom choice chip with the given text and icon
  /// * [updateValue] the value which is updated when the chip is selected
  /// * [text] the text of the chip
  /// * [icon] the icon of the chip
  Row buildChoiceChipContent(int? updateValue, String text, {IconData? icon}) {
    return Row(
      children: [
        Text(text),
        if (icon != null) const SizedBox(width: 10.0),
        if (icon != null) Icon(icon),
      ],
    );
  }
}

/// An implementation of the [ModularBottomFormPage] for adding a new [NetworkDevice] from the [DiscoverPage]
class NetworkDeviceFormPage extends ModularBottomFormPage {
  NetworkDeviceFormPage(
      {super.key,
      required super.device,
      required super.title,
      required super.onSubmitDeviceCallback});

  @override
  Future<List<StorageDevice>> dataOperationOnSave() async {
    List<StorageDevice> devices = await deviceStorage.addDevice(
      getDevice as NetworkDevice,
    );
    return devices;
  }
}

/// An implementation of the [ModularBottomFormPage] for editing an already existing [StorageDevice] from the [HomePage]
class EditDeviceFormPage extends ModularBottomFormPage {
  EditDeviceFormPage(
      {super.key,
      required super.device,
      required super.title,
      required super.onSubmitDeviceCallback})
      : super(deleteButton: true);

  @override
  Future<List<StorageDevice>> dataOperationOnSave() async {
    List<StorageDevice> devices = await deviceStorage.updateDevice(
      getDevice as StorageDevice,
    );
    return devices;
  }
}

/// return a validator function which can be passed to a [TextFormField] in order to validate the Input.
/// [regEx] is the RegEx to be evaluated, [msg] ist the error message being shown, if the input doesn't satisfy the RegEx
String? Function(String?) createValidator(String regEx, String msg) =>
    (String? value) => !RegExp(regEx).hasMatch(value!) ? msg : null;
