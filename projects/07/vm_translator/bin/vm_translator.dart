import 'dart:io';

import 'package:vm_translator/vm_translator.dart';

void main(List<String> arguments) async {

  if (arguments.length != 1 || !arguments[0].endsWith('.vm')) {
    print('Usage: vm_translator.dart FILE_PATH.vm');
    return;
  }

  if (!await File(arguments[0]).exists()) {
    print('Error: ${arguments[0]} does not exist.');
    return;
  }

  final translator = VMTranslator(arguments[0]);
  translator.translate();
}
