import 'package:flutter/services.dart';
import 'package:simple_wake_on_lan/constants.dart';

class CustomSeparatorFormatter extends TextInputFormatter {
  final String? separator;
  final bool allowPasteWithoutFormatting;
  final RegExp allowedInput;
  final bool autoSeparate;

  CustomSeparatorFormatter(
      {this.separator,
      this.allowPasteWithoutFormatting = true,
      this.autoSeparate = true,
      required this.allowedInput});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    assert(autoSeparate == false || separator!.length == 1);
    final int currentLength = oldValue.text.length;
    final int inputLength = newValue.text.length;
    final String inputText = newValue.text;

    // if something longer than 1 char is pasted, just return it (allows copy paste)
    if (allowPasteWithoutFormatting && inputLength > currentLength + 1) {
      return newValue;
    }

    // user inputs one char
    if (inputLength == currentLength + 1) {
      // check if current input is valid
      if (!allowedInput.hasMatch(inputText)) {
        return oldValue;
      }

      // add separator automatically if necessary as next char
      if (autoSeparate && allowedInput.hasMatch('$inputText$separator')) {
        return TextEditingValue(
          text: '$inputText$separator',
          selection: TextSelection.collapsed(
            offset: newValue.selection.end + 1,
          ),
        );
      }
    }
    // user delete chars
    else if (inputLength == currentLength - 1) {
      // delete char before separator automatically if user deletes separator
      if (autoSeparate &&
          currentLength > 1 &&
          oldValue.text.substring(currentLength - 1) == separator) {
        final selectionIndex = newValue.selection.end - 1;
        return TextEditingValue(
          text: newValue.text.substring(0, newValue.text.length - 1),
          selection: TextSelection.collapsed(
            offset: selectionIndex,
          ),
        );
      }
    }

    // input is valid and no separator is needed or has to be removed
    return newValue;
  }
}

class MACAddressFormatter extends CustomSeparatorFormatter {
  MACAddressFormatter({bool allowPasteWithoutFormatting = true})
      : super(
          separator: ':',
          allowPasteWithoutFormatting: allowPasteWithoutFormatting,
          allowedInput: RegExp(AppConstants.macSubStringValidationRegex),
        );
}

class IPAddressFormatter extends CustomSeparatorFormatter {
  IPAddressFormatter({bool allowPasteWithoutFormatting = true})
      : super(
          allowPasteWithoutFormatting: allowPasteWithoutFormatting,
          allowedInput: RegExp(AppConstants.ipSubStringValidationRegex),
          autoSeparate: false,
        );
}

// class MacAddressFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     // if something longer than 1 char is pasted, just return it (allows copy paste)
//     if (newValue.text.length > oldValue.text.length + 1) {
//       return newValue;
//     }
//
//     // input can't be longer than 17 characters
//     if (newValue.text.length > 17) {
//       return oldValue;
//     }
//
//     // if user entered text (and didn't delete), add colon after every 2 characters
//     if (newValue.text.length > oldValue.text.length) {
//       // if courser is where a colon should be next, allow user to input it (can occur when a char was deleted)
//       if (newValue.text.length % 3 == 0 && newValue.text.substring(newValue.text.length - 1) == ':') {
//         return newValue;
//       }
//
//       // if new char isn't a hex char, return old value
//       if (!RegExp(r'[a-fA-F0-9]').hasMatch(newValue.text.substring(newValue.text.length - 1))) {
//         return oldValue;
//       }
//
//       if (newValue.text.length > 2 && newValue.text.length % 3 == 0 && newValue.text.length < 17) {
//         final selectionIndex = newValue.selection.end + 1;
//         return TextEditingValue(
//           text: '${oldValue.text}:${newValue.text.substring(newValue.text.length - 1, newValue.text.length)}',
//           selection: TextSelection.collapsed(
//             offset: selectionIndex,
//           ),
//         );
//       }
//
//       // Add colon after every 2 characters (except after the last one)
//       if (newValue.text.length % 3 == 2 && newValue.text.length < 17) {
//         final selectionIndex = newValue.selection.end + 1;
//         return TextEditingValue(
//           text: '${newValue.text}:',
//           selection: TextSelection.collapsed(
//             offset: selectionIndex,
//           ),
//         );
//       }
//     }
//     if (newValue.text.length < oldValue.text.length) {
//       if (newValue.text.length > 1 && newValue.text.length % 3 == 2 && newValue.text.length < 17) {
//         final selectionIndex = newValue.selection.end - 1;
//         return TextEditingValue(
//           text: newValue.text.substring(0, newValue.text.length - 1),
//           selection: TextSelection.collapsed(
//             offset: selectionIndex,
//           ),
//         );
//       }
//     }
//     return newValue;
//   }
// }
