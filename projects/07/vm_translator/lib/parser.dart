import 'dart:io';

import 'package:vm_translator/constants.dart';

class Parser {
  // ignore: unused_field
  final File _inputFile;
  final List<String> _lines;
  String _currentCommand;
  int _currentLine;

  Parser(this._inputFile)
    : _lines = _inputFile.readAsLinesSync(),
      _currentCommand = '',
      _currentLine = 0;

  get currentCommand => _currentCommand;

  bool hasMoreLines() => _lines.length > _currentLine;

  void advance() {
    while (true) {
      if (_lines[_currentLine].startsWith('//') || _lines[_currentLine] == '') {
        _currentLine++;
        continue;
      }

      break;
    }

    _currentCommand = _lines[_currentLine];
    _currentLine++;
  }

  int commandType() {
    switch (_currentCommand.split(' ')[0]) {
      case 'add':
      case 'sub':
      case 'neg':
      case 'eq':
      case 'gt':
      case 'lt':
      case 'and':
      case 'or':
      case 'not':
        return C_ARITHMETIC;
      case 'push':
        return C_PUSH;
      case 'pop':
        return C_POP;
      default:
        throw Exception('Invalid command.');
    }
  }

  String arg1() => _currentCommand.split(' ')[1];

  int arg2() => int.parse(_currentCommand.split(' ')[2]);
}