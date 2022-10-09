import 'dart:io';

import 'package:vm_translator/constants.dart';

class CodeWriter {
  final File _outputFile;
  int _labelNumber;

  CodeWriter(this._outputFile)
    : _labelNumber = 0;

  void writeArithmetic(String command) {
    switch (command) {
      case 'add':
        _binary('D+A');
        break;
      case 'sub':
        _binary('A-D');
        break;
      case 'neg':
        _unary('-D');
        break;
      case 'eq':
        _compare('JEQ');
        break;
      case 'gt':
        _compare('JGT');
        break;
      case 'lt':
        _compare('JLT');
        break;
      case 'and':
        _binary('D&A');
        break;
      case 'or':
        _binary('D|A');
        break;
      case 'not':
        _binary('!D');
        break;
      default:
        throw Exception('Invalid command.');
    }
  }

  void writePushPop(int command, String segment, int index) {
    if (command == C_PUSH) {
      _push(segment, index);
    }
    if (command == C_POP) {
      _pop(segment, index);
    }
  }

  void _unary(String comp) {
    _decrementSP();
    _stackToDest('D');
    _cCommand(comp, dest: 'D');
    _compToStack('D');
    _incrementSP();
  }

  void _binary(String comp) {
    _decrementSP();
    _stackToDest('D');
    _decrementSP();
    _stackToDest('A');
    _cCommand(comp, dest: 'D');
    _compToStack('D');
    _incrementSP();
  }

  void _compare(String jump) {
    _decrementSP();
    _stackToDest('D');
    _decrementSP();
    _stackToDest('A');
    _cCommand('A-D', dest: 'D');
    final String eqLabel = _jump('D', jump);
    _compToStack('0');
    final String neLabel = _jump('0', 'JMP');
    _lCommand(eqLabel);
    _compToStack('-1');
    _lCommand(neLabel);
    _incrementSP();
  }

  void _push(String segment, int index) {
    if (_isConstantSegment(segment)) {
      _valueToStack(index.toString());
    }
    else if (_isMemorySegment(segment)) {
      _memoryToStack(_asmMemorySegment(segment), index);
    }
    else if (_isRegisterSegment(segment)) {
      _registerToStack(segment, index);
    }
    else if (_isStaticSegment(segment)) {
      _staticToStack(segment, index);
    }

    _incrementSP();
  }

  void _pop(String segment, int index) {
    _decrementSP();

    if (_isMemorySegment(segment)) {
      _stackToMemory(_asmMemorySegment(segment), index);
    }
    else if (_isRegisterSegment(segment)) {
      _stackToRegister(segment, index);
    }
    else if (_isStaticSegment(segment)) {
      _stackToStatic(segment, index);
    }
  }

  void _popToDest(String dest) {
    _decrementSP();
    _stackToDest(dest);
  }

  bool _isMemorySegment(String segment) => [S_LCL, S_ARG, S_THIS, S_THAT].contains(segment);

  bool _isRegisterSegment(String segment) => [S_REG, S_PTR, S_TEMP].contains(segment);

  bool _isStaticSegment(String segment) => S_STATIC == segment;

  bool _isConstantSegment(String segment) => S_CONST == segment;

  void _incrementSP() {
    _aCommand('SP');
    _cCommand('M+1', dest: 'M');
  }

  void _decrementSP() {
    _aCommand('SP');
    _cCommand('M-1', dest: 'M');
  }

  void _loadSP() {
    _aCommand('SP');
    _cCommand('M', dest: 'A');
  }

  void _valueToStack(String value) {
    _aCommand(value);
    _cCommand('A', dest: 'D');
    _compToStack('D');
  }

  void _registerToStack(String segment, int index) {
    _registerToDest('D', _registerNumber(segment, index));
    _compToStack('D');
  }

  void _memoryToStack(String segment, int index, {bool indir = true}) {
    _loadSegment(segment, index, indir: indir);
    _cCommand('M', dest: 'D');
    _compToStack('D');
  }

  void _staticToStack(String segment, int index) {
    _aCommand(_staticName(index));
    _cCommand('M', dest: 'D');
    _compToStack('D');
  }

  void _compToStack(String comp) {
    _loadSP();
    _cCommand(comp, dest: 'M');
  }

  void _stackToRegister(String segment, int index) {
    _stackToDest('D');
    _compToRegister(_registerNumber(segment, index), 'D');
  }

  void _stackToMemory(String segment, int index, {bool indir = true}) {
    _loadSegment(segment, index, indir: indir);
    _compToRegister(R_COPY, 'D');
    _stackToDest('D');
    _registerToDest('A', R_COPY);
    _cCommand('D', dest: 'M');
  }

  void _stackToStatic(String segment, int index) {
    _stackToDest('D');
    _aCommand(_staticName(index));
    _cCommand('D', dest: 'M');
  }

  void _stackToDest(String dest) {
    _loadSP();
    _cCommand('M', dest: dest);
  }

  void _loadSegment(String segment, int index, {bool indir = true}) {
    if (index == 0) {
      _loadSegmentNoIndex(segment, indir);
    } else {
      _loadSegmentIndex(segment, index, indir);
    }
  }

  void _loadSegmentNoIndex(String segment, bool indir) {
    _aCommand(segment);
    if (indir) {
      _indir(dest: 'AD');
    }
  }

  void _loadSegmentIndex(String segment, int index, bool indir) {
    String comp = 'D+A';

    if (index < 0) {
      index = -index;
      comp = 'A-D';
    }

    _aCommand(index.toString());
    _cCommand('A', dest: 'D');
    _aCommand(segment);

    if (indir) {
      _indir();
    }

    _cCommand(comp, dest: 'AD');
  }

  void _registerToDest(String dest, int register) {
    _aCommand(_asmRegister(register));
    _cCommand('M', dest: dest);
  }

  void _compToRegister(int register, String comp) {
    _aCommand(_asmRegister(register));
    _cCommand(comp, dest: 'M');
  }

  void _registerToRegister(int dest, int src) {
    _registerToDest('D', src);
    _compToRegister(dest, 'D');
  }

  void _indir({String dest = 'A'}) => _cCommand('M', dest: dest);

  int _registerNumber(String segment, int index) => _registerBase(segment) + index;

  int _registerBase(String segment) => {'reg': R_R0, 'pointer': R_PTR, 'temp': R_TEMP}[segment]!;

  String _staticName(int index) => '${_outputFile.uri.pathSegments.last}.${index.toString()}';

  String _asmMemorySegment(String segment) => {S_LCL: 'LCL', S_ARG: 'ARG', S_THIS: 'THIS', S_THAT: 'THAT'}[segment]!;

  String _asmRegister(int registerNumber) => 'R${registerNumber.toString()}';

  String _jump(String comp, String jump) {
    final String label = _newLabel();
    _aCommand(label);
    _cCommand(comp, jump: jump);
    return label;
  }

  String _newLabel() {
    _labelNumber++;
    return 'LABEL$_labelNumber';
  }

  void _aCommand(String address) => _outputFile.writeAsStringSync('@$address\n', mode: FileMode.append);

  void _cCommand(String comp, {String dest = '', String jump = ''}) {
    String command = '';
    
    if (dest != '') {
      command = command + '$dest=';
    }
    command = command + comp;
    if (jump != '') {
      command = command + ';$jump';
    }

    _outputFile.writeAsStringSync('$command\n', mode: FileMode.append);
  }

  void _lCommand(String label) => _outputFile.writeAsStringSync('($label)\n', mode: FileMode.append);
}