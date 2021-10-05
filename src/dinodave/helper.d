/**
* Helper functions
*/
module dinodave.helper;

import dinodave.nodave;
import dinodave.plc : IPlc;
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
unittest {
    ubyte[] a = [1, 2, 3, 4];
   a.put8(50);
   assert(a == [50, 2, 3, 4]);
   a.put8(51);
   assert(a == [51, 2, 3, 4]);

   ubyte[] buf = [0, 2, 4];
   assert(buf[0] == 0);
   put8(buf, 10);
   assert(buf[0] == 10);
   assert(buf.length == 3);
   put8(buf, 0xFF);
}

/**
 * Put two bytes (a word) into buffer.
 *
 * Params:
 *  buffer = Buffer in which put the byte
 *  value = Word value
 */
void put16(ubyte[] buffer, in int value) {
   davePut16(buffer.ptr, value);
}
unittest {
   ubyte[] a = [0, 0];
   a.put16(1);
   assert(a == [0, 1]);
   a.put16(2);
   assert(a == [0, 2]);
   ubyte[] buf = new ubyte[](8);
   buf.put16(4);
   assert(buf == [0, 4, 0, 0, 0, 0, 0, 0]);
}

/**
 * Put four bytes (a double word) into buffer.
 *
 * `put32` always puts the int in the first four bytes of the buffer.
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
 * `putFloat` always puts the float in the first four bytes of the buffer
 *
 * Params:
 *  buffer = Buffer in which put bytes
 *  value = Float value
 */
void putFloat(ubyte[] buffer, in float value) {
   davePutFloat(buffer.ptr, value);
}
///
unittest {
   ubyte[] buf = new ubyte[](8);
   buf.putFloat(42.);
   buf.putFloat(1964.);
   assert(buf.length == 8);
   assert(buf == [
         0x44, 0xf5, 0x80, 0x0,  //1964
         0x0, 0x0, 0x0, 0x0]);  //0

}
/**
 * Put a byte (4 bytes) into buffer at fixed position.
 *
 *
 * Params:
 *  buffer = Buffer in which put bytes
 *  pos = Zero based position
 *  value = Byte value
 */

void put8At(ubyte[] buffer, in int pos, in int value) {
   enforce(pos < buffer.length && pos >= 0);
   davePut8At(buffer.ptr, pos, value);
}
///
unittest {
   import std.exception : assertThrown;
   import dinodave.nodave : davePut8At;

   ubyte[] a = [1, 2, 3, 4];
   a.put8At(0, 50);
   assert(a == [50, 2, 3, 4]);
   a.put8At(1, 51);
   assert(a == [50, 51, 3, 4]);
   assertThrown!Exception(a.put8At(19, 52));
   assertThrown!Exception(a.put8At(-19, 52));

   ubyte[] d = [1, 2, 3, 4];
   davePut8At(d.ptr, 0, 50);
   assert(d == [50, 2, 3, 4]);
   davePut8At(d.ptr, 1, 51);
   assert(d == [50, 51, 3, 4]);

   // Segmentation fault!!!!
   // davePut8At(a.ptr, 19, 52).shouldNotThrow!Exception;
   // davePut8At(a.ptr, -19, 52).shouldNotThrow!Exception;
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
unittest {
   ubyte[] buf = new ubyte[](16);
   buf.putFloatAt(0, 42.);
   buf.putFloatAt(4, 1964.);
   buf.putFloatAt(8, 19.64);
   buf.putFloatAt(12, 3.1415);
   assert(buf.length == 16);
   assert(buf == [0x42, 0x28, 0x0, 0x0, //42
         0x44, 0xf5, 0x80, 0x0, //1964
         0x41, 0x9d,
         0x1e, 0xb8, //19.64
         0x40, 0x49, 0x0e, 0x56, //3.1415
         ]);
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

unittest {
   assert((0x0).toBCD() == 0);
   assert((0x5).toBCD() == 5);
   assert((0xA).toBCD() == 16);
   assert((11).toBCD() == 17);
}


///
unittest {
   assert((cast(ubyte)0).toBCD == cast(ubyte)0);
   assert((cast(ubyte)10).toBCD == cast(ubyte)16);
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
   assert((cast(ushort)0).toBCD  == cast(ushort)0);
   assert((cast(ushort)10).toBCD == cast(ushort)16);
   assert((cast(ushort)127).toBCD == cast(ushort)295);
   assert((cast(ushort)9999).toBCD == cast(ushort)39321);
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
ushort fromBCD(ushort bcd) pure
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
   assert((cast(ushort)0).fromBCD == 0);
   assert((cast(ushort)16).fromBCD == 10);
   assert((cast(ushort)295).fromBCD == 127);
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
   assert(strerror(6) == "the CPU does not support reading a bit block of length<>1");

   assert(strerror(0x8000) == "function already occupied.");
   assert(strerror(0x8001) == "not allowed in current operating status.");
   assert(strerror(0x8101) == "hardware fault.");
   assert(strerror(0x8103) == "object access not allowed.");
   assert(strerror(0x8104) == "context is not supported. Step7 says:Function not implemented or error in telgram.");
   assert(strerror(0x8105) == "invalid address.");
   assert(strerror(0x8106) == "data type not supported.");
   assert(strerror(0x8107) == "data type not consistent.");
   assert(strerror(0x810A) == "object does not exist.");
   assert(strerror(0x8500) == "incorrect PDU size.");
   assert(strerror(0x8702) == "address invalid.");
   assert(strerror(0xd201) == "block name syntax error.");
   assert(strerror(0xd202) == "syntax error function parameter.");
   assert(strerror(0xd203) == "syntax error block type.");
   assert(strerror(0xd204) == "no linked block in storage medium.");
   assert(strerror(0xd205) == "object already exists.");
   assert(strerror(0xd206) == "object already exists.");
   assert(strerror(0xd207) == "block exists in EPROM.");
   assert(strerror(0xd209) == "block does not exist/could not be found.");
   assert(strerror(0xd20e) == "no block present.");
   assert(strerror(0xd210) == "block number too big.");
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
   assert([0x41, 0x42, 0x43, 0x0, 0x1B].getNTString == "ABC");
   assert([0x41, 0x42, 0x10, 0x43, 0x0, 0x1B].getNTString == "ABC");
   assert([0x41, 0x42, 0x0, 0x43, 0x0, 0x1B].getNTString == "AB");
   assert([0x41, 0x0, 0x0, 0x43, 0x0, 0x1B].getNTString == "A");
   assert([0x0, 0x41, 0x42, 0x43, 0x1B].getNTString == "");
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
   assert([0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(10) == "ABC");
   assert([0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(3) == "ABC");
   assert([0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(2) == "AB");
   assert([0x00, 0x41, 0x42, 0x43, 0x1B].getFixString(1) == "A");
   assert([0x00, 0x41, 0x1a, 0x42, 0x1B, 0x43, 0x1C].getFixString(3) == "ABC");
   assert([0x00, 0x41, 0x1a, 0x42, 0x1B, 0x43, 0x1C].getFixString(0) == "");
   assert([0x00, 0x1a, 0x1B, 0x1C].getFixString(5) == "");
}

/**
 * Takes a ubyte c and determines if it represents a printable char.
 */
bool isPrintable(in ubyte c) pure {
   enum SPACE = 0x20;
   enum DEL = 0x7F;

   return c >= SPACE && c < DEL;
}

///
unittest {
   assert((0x20).isPrintable);
   assert(!(0x00).isPrintable);
   assert((0x7E).isPrintable);
}

/**
 * Convert a string into buffer
 */
ubyte[] getBuffer(string s) {
   return cast(ubyte[])s;
}

unittest {
   ubyte[] r = "unogatto".getBuffer;
   assert(r.length == 8);
   assert(r == [0x75, 0x6e, 0x6f, 0x67, 0x61, 0x74, 0x74, 0x6f]);
   assert("".getBuffer.length == 0);
}

/**
 * Convert a string into a fixed length buffer
 */
ubyte[] getFixBuffer(string s, uint maxLength) {
   import std.range : take;
   import std.array : array;

   ubyte[] tmp;
   tmp.length = maxLength;
   return (s.getBuffer ~ tmp).take(maxLength).array;
}

///
unittest {
   ubyte[] r = "unogatto".getFixBuffer(3);
   assert(r.length == 3);
   assert(r == [0x75, 0x6e, 0x6f]);
   assert("".getFixBuffer(3).length == 3);

   r = "unogatto".getFixBuffer(10);
   assert(r.length == 10);
   assert(r == [0x75, 0x6e, 0x6f, 0x67, 0x61, 0x74, 0x74, 0x6f, 0x0, 0x0]);
}

/**
 * Convert a string into null terminated buffer
 */
ubyte[] getNTBuffer(string s) {
   return s.getBuffer ~ 0;
}

///
unittest {
   ubyte[] r = "unogatto".getNTBuffer;
   assert(r.length == 9);
   assert(r == [0x75, 0x6e, 0x6f, 0x67, 0x61, 0x74, 0x74, 0x6f, 0x0]);
   assert("".getNTBuffer.length == 1);
}

/**
 * Read an ubyte array from PLC.
 *
 * Params:
 *  plc = Physical plc
 *  length = Number of bytes to read
 */
ubyte[] getU8Array(IPlc plc, int length)
in (plc !is null && length > 0)
{
   ubyte[] buf;
   foreach (i; 0 .. length) {
      buf ~= plc.getU8;
   }
   return buf;
}
