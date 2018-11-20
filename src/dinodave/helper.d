/**
* Helper functions
*/
module dinodave.helper;

version (unittest) {
   import unit_threaded;
}

import dinodave.nodave;
import std.conv;
import std.exception;

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

/**
 * Put two bytes (a word) into buffer.
 *
 * Params:
 *  buffer = buffer in which put the byte
 *  value = Word value
 */
void put16(ubyte[] buffer, in int value) {
   davePut16(buffer.ptr, value);
}

/**
 * Put four bytes (a double word) into buffer.
 *
 * Params:
 *  buffer = Buffer in which put the byte
 *  value = Double word value
 */
void put32(ubyte[] buffer, in int value) {
   davePut32(buffer.ptr, value);
}

/**
 * Put a float (4 bytes) into buffer.
 *
 * Params:
 *  buffer = buffer in which put the byte
 *  value = Float value
 */
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

/**
 * Convert value to $(LINK2 https://en.wikipedia.org/wiki/Binary-coded_decimal, BCD)
 *
 * Params:
 *  value = Binary byte value
 *
 * Returns:
 *  Decimal value
 */
ubyte toBCD(ubyte value) {
   return daveToBCD(value);
}
///
unittest {
   (cast(ubyte)0).toBCD.shouldEqual(cast(ubyte)0);
   (cast(ubyte)10).toBCD.shouldEqual(cast(ubyte)16);
   //(cast(ubyte)127).toBCD.shouldEqual(cast(ubyte)295);
}

// ditto
ushort toBCD(ushort dec)
in {
   enum ushort MAX_VALUE = 9999;
   enum ushort MIN_VALUE = 0;
   assert(dec <= MAX_VALUE, "Argument out of range");
   assert(dec >= MIN_VALUE, "Argument out of range");
}
do {
   ushort bcd = 0;
   enum ushort NUM_BASE = 10;
   ushort i = 0;
   for (; dec > 0; dec /= NUM_BASE) {
      ushort rem = cast(ushort)(dec % NUM_BASE);
      bcd += cast(ushort)(rem << 4 * i++);
   }
   return bcd;
}

///
unittest {
   (cast(ushort)0).toBCD.shouldEqual(cast(ushort)0);
   (cast(ushort)10).toBCD.shouldEqual(cast(ushort)16);
   (cast(ushort)127).toBCD.shouldEqual(cast(ushort)295);
   (cast(ushort)9999).toBCD.shouldEqual(cast(ushort)39321);
}

/**
 * Convert value from $(LINK2 https://en.wikipedia.org/wiki/Binary-coded_decimal, BCD)
 *
 * Params:
 *  value = BCD byte value
 *
 * Returns:
 *  Decimal value
 */
ubyte fromBCD(ubyte value) {
   return daveFromBCD(value);
}

//ditto
ushort fromBCD(ushort bcd)
in {
   enum ushort MAX_VALUE = 0x9999;
   enum ushort MIN_VALUE = 0;
   assert(bcd <= MAX_VALUE, "Argument out of range");
   assert(bcd >= MIN_VALUE, "Argument out of range");
}
do {
   ushort dec = 0;
   ushort weight = 1;
   enum int NO_OF_DIGITS = 8;
   for (int j = 0; j < NO_OF_DIGITS; j++) {
      dec += cast(ushort)((bcd & 0x0F) * weight);
      bcd = cast(ushort)(bcd >> 4);
      weight *= 10;
   }
   return dec;
}

unittest {
   (cast(ushort)0).fromBCD.shouldEqual(0);
   (cast(ushort)16).fromBCD.shouldEqual(10);
   (cast(ushort)295).fromBCD.shouldEqual(127);
}

/**
 * Get error code description.
 *
 * Params:
 *  code = Error code
 *
 * Returns:
 *  Description of error.
 *  Generally, positive error codes represent errors reported by the PLC,
 *  while negative ones represent errors detected by LIBNODAVE, e.g. no response from the PLC.
 */
string strerror(int code) {
   return to!(string)(daveStrerror(code));
}

unittest {
   (6).strerror.shouldEqual("the CPU does not support reading a bit block of length<>1");
}

/**
 * Convert bytes from buffer to string.
 *
 * Params:
 *  buffer = Buffer that contains chars
 *
 * Returns:
 *  A string. Converts $(I printables) bytes from buffer to char until it finds a null char. (NT means NullTerminated)
 *
 * See_Also: `isPrintable`
 */
string getNTString(ubyte[] buffer) {
   import std.conv : to;
   import std.algorithm : filter, map, until;
   import std.range : take;
   import std.array : array;

   // dfmt off
   return buffer
      .until(0)
      .filter!(a => a.isPrintable)
      .map!(to!char)
      .array
      .to!string();
   // dfmt on
}

///
unittest {
   [0x41, 0x42, 0x43, 0x0, 0x1B].getNTString.shouldEqual("ABC");
   [0x41, 0x42, 0x10, 0x43, 0x0, 0x1B].getNTString.shouldEqual("ABC");
   [0x41, 0x42, 0x0, 0x43, 0x0, 0x1B].getNTString.shouldEqual("AB");
   [0x41, 0x0, 0x0, 0x43, 0x0, 0x1B].getNTString.shouldEqual("A");
   [0x0, 0x41, 0x42, 0x43, 0x1B].getNTString.shouldEqual("");
}

/**
 * Convert bytes from buffer to string.
 *
 * Params:
 *  buffer = Buffer that contains chars
 *  maxLength = Max length of string
 *
 * Returns:
 *  A string. Converts `maxLength` $(I printables) bytes to char.
 *
 * See_Also: `isPrintable`
 */
string getFixString(ubyte[] buffer, uint maxLength) {
   import std.conv : to;
   import std.algorithm : filter, map;
   import std.range : take;
   import std.array : array;

   // dfmt off
   return buffer
      .filter!(a => a.isPrintable)
      .take(maxLength)
      .map!(to!char)
      .array
      .to!string();
   // dfmt on
}

///
unittest {
   [0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(10).shouldEqual("ABC");
   [0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(3).shouldEqual("ABC");
   [0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(2).shouldEqual("AB");
   [0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(1).shouldEqual("A");
   [0x00, 0x41, 0x1a, 0x42, 0x1B, 0x43, 0x1C].getFixString(3).shouldEqual("ABC");
   [0x00, 0x41, 0x1a, 0x42, 0x1B, 0x43, 0x1C].getFixString(0).shouldEqual("");
   [0x00, 0x1a, 0x1B, 0x1C].getFixString(5).shouldEqual("");
}


/**
 * Takes a ubyte c and determines if it represents a printable char.
 */
bool isPrintable(ubyte c) {
   enum SPACE = 0x20;
   enum DEL = 0x7F;

   return c >= SPACE && c < DEL;
}

///
unittest {
   (0x20).isPrintable.shouldBeTrue;
   (0x00).isPrintable.shouldBeFalse;
   (0x7E).isPrintable.shouldBeTrue;
}
