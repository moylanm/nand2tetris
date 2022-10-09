import 'dart:io';

import 'package:vm_translator/constants.dart';
import 'package:vm_translator/parser.dart';
import 'package:vm_translator/code_writer.dart';

class VMTranslator {
  // ignore: unused_field
  final String _filePath;
  final Parser _parser;
  final CodeWriter _codeWriter;

  VMTranslator(this._filePath)
    : _parser = Parser(File(_filePath)),
      _codeWriter = CodeWriter(File('${_filePath.split('.vm')[0]}.asm'));

  void translate() {
    while (_parser.hasMoreLines()) {
      _parser.advance();

      final command = _parser.commandType();
      switch (command) {
        case C_ARITHMETIC:
          _codeWriter.writeArithmetic(_parser.currentCommand);
          break;
        case C_PUSH:
        case C_POP:
          _codeWriter.writePushPop(command, _parser.arg1(), _parser.arg2());
          break;
        default:
          throw Exception('Invalid command.');
      }
    }
  }
}