/**
* Helper functions
*/
module dinodave.helper;

import std.conv;
import std.exception;

import dinodave.nodave;

/**
 * Put one byte into buffer.
 *
 * Params:
 *  buffer = buffer in which put the byte
 *  value = Byte value
 */
void put8(ubyte[] buffer, in int value) {
   davePut8(buffer.ptr, value);
}

void put16(ubyte[] buffer, in int value) {
   davePut16(buffer.ptr, value);
}

void put32(ubyte[] buffer, in int value) {
   davePut32(buffer.ptr, value);
}

void putFloat(ubyte[] buffer, in float value) {
   davePutFloat(buffer.ptr, value);
}

void put8At(ubyte[] buffer, in int pos, in int value) {
   enforce(pos < buffer.length && pos >= 0);
   davePut8At(buffer.ptr, pos, value);
}

void put16At(ubyte[] buffer, int pos, in int value) {
   enforce(pos < (buffer.length - 1) && pos >= 0);
   davePut16At(buffer.ptr, pos, value);
}

void put32At(ubyte[] buffer, in int pos, in int value) {
   enforce(pos < (buffer.length - 3) && pos >= 0);
   davePut32At(buffer.ptr, pos, value);
}

void putFloatAt(ubyte[] buffer, in int pos, in float value) {
   enforce(pos < (buffer.length - 3) && pos >= 0);
   davePutFloatAt(buffer.ptr, pos, value);
}

ubyte toBCD(ubyte i) {
   return daveToBCD(i);
}

ubyte fromBCD(ubyte i) {
   return daveFromBCD(i);
}

/**
* Get error code description.
*
* Params:
*  code = error code
*
*
* Returns: description of error
* Generally, positive error codes represent errors reported by the PLC,
* while negative ones represent errors detected by LIBNODAVE, e.g. no response from the PLC.
*/
string strerror(int code) {
   return to!(string)(daveStrerror(code));
}
