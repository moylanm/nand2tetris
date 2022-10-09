// ignore_for_file: constant_identifier_names

// Command types
const C_ARITHMETIC = 0;
const C_PUSH       = 1;
const C_POP        = 2;
const C_LABEL      = 3;
const C_GOTO       = 4;
const C_IF         = 5;
const C_FUNCTION   = 6;
const C_RETURN     = 7;
const C_CALL       = 8;   
const C_ERROR      = 9;

// Segment names
const S_LCL        = 'local';
const S_ARG        = 'argument';
const S_THIS       = 'this';
const S_THAT       = 'that';
const S_PTR        = 'pointer';
const S_TEMP       = 'temp';
const S_CONST      = 'constant';
const S_STATIC     = 'static';
const S_REG        = 'reg';

// Registers
const R_R0    = 0;
const R_SP    = 0;
const R_R1    = 0;
const R_LCL   = 1;
const R_R2    = 2;
const R_ARG   = 2;
const R_R3    = 3;
const R_THIS  = 3;
const R_PTR   = 3;
const R_R4    = 4;
const R_THAT  = 4;
const R_R5    = 5;
const R_TEMP  = 5;
const R_R6    = 6;
const R_R7    = 7;
const R_R8    = 8;
const R_R9    = 9;
const R_R10   = 10;
const R_R11   = 11;
const R_R12   = 12;
const R_R13   = 13;
const R_FRAME = 13;
const R_R14   = 14;
const R_RET   = 14;
const R_R15   = 15;
const R_COPY  = 15;