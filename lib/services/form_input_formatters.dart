import 'package:flutter/services.dart';
import 'package:simple_wake_on_lan/constants.dart';

class CustomSeparatorFormatter extends TextInputFormatter {
  final String separators;
  final bool allowPasteWithoutFormatting;
  final RegExp allowedInput;

  String preferredSeparator;

  final bool autoSeparate;

  CustomSeparatorFormatter(
      {this.separators = "",
      this.allowPasteWithoutFormatting = true,
      this.autoSeparate = true,
      required this.allowedInput,
      this.preferredSeparator = ""});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    //assert(autoSeparate == false || separator!.length == 1);
    final int currentLength = oldValue.text.length;
    final int inputLength = newValue.text.length;
    final String inputText = newValue.text;

    // // if an separator already exists in the input, set it as preferred separator
    // if (inputLength != 0) {
    //   for (int i = 0; i < separators.length; i++) {
    //     if (inputText.contains(separators.substring(i, i + 1))) {
    //       preferredSeparator = separators.substring(i, i + 1);
    //       break;
    //     }
    //   }
    // }

    // if something longer than 1 char is pasted, just return it (allows copy paste)
    if (allowPasteWithoutFormatting && inputLength > currentLength + 1) {
      return newValue;
    }

    // user inputs one char
    if (inputLength == currentLength + 1) {
      // if input is separator, set preferred separator to this separator and return old value
      if (separators.contains(inputText.substring(inputLength - 1))) {
        preferredSeparator = inputText.substring(inputLength - 1);
        // replace every occurrence of any separator with preferred separator
        final String newText = oldValue.text
            .replaceAll(RegExp('[$separators]'), preferredSeparator);
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: oldValue.selection.end,
          ),
        );
      }

      // check if current input is valid
      if (!allowedInput.hasMatch(inputText)) {
        return oldValue;
      }

      // add separator automatically if necessary as next char
      if (autoSeparate) {
        if (allowedInput.hasMatch('$inputText$preferredSeparator')) {
          return TextEditingValue(
            text: '$inputText$preferredSeparator',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
        for (int i = 0; i < separators.length; i++) {
          if (allowedInput
              .hasMatch('$inputText${separators.substring(i, i + 1)}')) {
            return TextEditingValue(
              text: '$inputText$separators',
              selection: TextSelection.collapsed(
                offset: newValue.selection.end + 1,
              ),
            );
          }
        }
      }
    }
    // user delete chars
    else if (inputLength == currentLength - 1) {
      // delete char before separator automatically if user deletes separator
      if (autoSeparate &&
          currentLength > 1 &&
          oldValue.text.substring(currentLength - 1) == preferredSeparator) {
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
          separators: ':-',
          preferredSeparator: ':',
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
