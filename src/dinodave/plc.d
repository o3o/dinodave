/**
 * This module defines interfaces and classes that wrap nodave functios and procedures.
 */
module dinodave.plc;

import dinodave.helper;
import dinodave.nodave;
import std.conv;
import std.datetime;
import std.socket;
import std.stdio;
import std.string;
import std.experimental.logger;

/**
 * Representing the physical connection to a PLC.
 */
interface IPlc {
   void openConnection(int slot);
   void closeConnection();

   /**
    * Reads a sequence of bytes from PLC memory.
    * The buffers used by readBytes() and writeBytes() will contain a copy of the PLC memory area.
    *
    * Params:
    *  DB = The number of a data block
    *  start = The address of the first byte in the block.
    *  length = The number of bytes to read.
    */
   void readBytes(in int DB, in int start, in int length);

   /**
    * Reads a sequence of bytes from PLC memory.
    *
    * Params:
    *  DB = The number of a data block
    *  start = The address of the first byte in the block.
    *  length = The number of bytes to read.
    *
    * Returns:
    *  an ubyte array
    *
    * Throws: `NodaveException`
    */

   ubyte[] readManyBytes(in int DB, in int start, in int length);
   ///
   byte getS8();
   ///
   ubyte getU8();
   ///
   short getS16();
   ///
   ushort getU16();
   ///
   int getS32();
   ///
   uint getU32();
   ///
   float getFloat();

   ///
   byte getS8At(int position);
   ///
   ubyte getU8At(int position);
   ///
   short getS16At(int position);
   ///
   ushort getU16At(int position);
   ///
   int getS32At(int position);
   ///
   uint getU32At(int position);
   ///
   float getFloatAt(int position);

   /**
    * Simplified single bit set
    */
   void setBit(in int DB, in int byteAddress, in int bitAddress);

   /**
    * Simplified single bit clear
    */
   void clearBit(in int DB, in int byteAddress, in int bitAddress);

   ///
   void writeBytes(int DB, int start, int length, ubyte[] buffer);
   ///
   int readPLCTime();
}

class IsoTcp : IPlc {
   private immutable(string) ip;
   private immutable(int) port;
   this(in string ipAddress, in int port = 102) {
      assert(ipAddress.length > 0);
      ip = ipAddress;

      assert(port > 0);
      this.port = port;
   }

   private daveConnection* dc;
   private _daveOSserialType fds;
   private TcpSocket sock;
   void openConnection(int slot) {
      try {
         sock = new TcpSocket(new InternetAddress(ip, to!(ushort)(port)));

         fds.rfd = sock.handle;
         fds.wfd = fds.rfd;

         if (fds.rfd > 0) {
            daveInterface* di = daveNewInterface(fds, "IF1", 0, daveProtoISOTCP, daveSpeed9k);
            daveSetTimeout(di, 5_000_000);
            enum int MPI = 0; //The address of the PLC (only meaningful for MPI and PPI).
            enum int RACK = 0; // The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
            dc = daveNewConnection(di, MPI, RACK, slot);
            if (daveConnectPLC(dc) != 0) {
               throw new NodaveException("Couldn't connect to PLC with ip " ~ ip);
            }
         } else {
            throw new NodaveException(
                  "Couldn't open TCP port. Please make sure a CP is connected and the IP address is ok.");
         }
      } catch (Exception e) {
         throw new NodaveException("NoDave generic exception:" ~ e.msg);
      }
   }

   void closeConnection() {
      daveDisconnectPLC(dc);
      sock.close;
   }

   void readBytes(in int DB, in int start, in int length)
   in {
      assert(DB >= 0, "DB must be positive or zero");
      assert(start >= 0, "Start must be positive or zero");
      assert(length > 0, "Length must be positive");
   }
   do {
      const(int) err = daveReadBytes(dc, daveDB, DB, start, length, null);
      if (err != 0) {
         throw new NodaveReadException(err, DB, start, length);
      }
   }

  ubyte[] readManyBytes(in int DB, in int start, in int length)
   in {
      assert(DB >= 0, "DB must be positive or zero");
      assert(start >= 0, "Start must be positive or zero");
      assert(length > 0, "Length must be positive");
   }
   do {
      ubyte[] buffer = new ubyte[](1024);
      const(int) err = daveReadManyBytes(dc, daveDB, DB, start, length, buffer.ptr);
      if (err != 0) {
         throw new NodaveException(err);
      }

      return buffer[0 .. length];
   }

   byte getS8() {
      return to!byte(daveGetS8(dc));
   }

   ubyte getU8() {
      return to!ubyte(daveGetU8(dc));
   }

   short getS16() {
      return to!short(daveGetS16(dc));
   }

   ushort getU16() {
      return to!ushort(daveGetU16(dc));
   }

   int getS32() {
      return daveGetS32(dc);
   }

   uint getU32() {
      return daveGetU32(dc);
   }

   float getFloat() {
      return daveGetFloat(dc);
   }

   byte getS8At(int position) {
      return to!byte(daveGetS8At(dc, position));
   }

   ubyte getU8At(int position) {
      return to!ubyte(daveGetU8At(dc, position));
   }

   short getS16At(int position) {
      return to!short(daveGetS16At(dc, position));
   }

   ushort getU16At(int position) {
      return to!ushort(daveGetU16At(dc, position));
   }

   int getS32At(int position) {
      return daveGetS32At(dc, position);
   }

   uint getU32At(int position) {
      return to!uint(daveGetU32At(dc, position));
   }

   float getFloatAt(int position) {
      return daveGetFloatAt(dc, position);
   }

   void setBit(in int DB, in int byteAddress, in int bitAddress) {
      int res = daveSetBit(dc, daveDB, DB, byteAddress, bitAddress);
      if (res != 0) {
         throw new NodaveException(res);
      }
   }

   void clearBit(in int DB, in int byteAddress, in int bitAddress) {
      int res = daveClrBit(dc, daveDB, DB, byteAddress, bitAddress);
      if (res != 0) {
         throw new NodaveException(res);
      }
   }

   /**
    * Write a sequence of bytes from a buffer to PLC memory.
    *
    * Params:
    *  DB = The number of a data block
    *  start = The address of the first byte in the block.
    *  length = The number of bytes to write.
    *  buffer = Buffer to write.
    *
    * Throws: `NodaveException`
    */
   void writeBytes(int DB, int start, int length, ubyte[] buffer) {
      int res = daveWriteBytes(dc, daveDB, DB, start, length, buffer.ptr);
      if (res != 0) {
         throw new NodaveException(res);
      }
   }

   /**
    * Read PLC data time.
    */
   int readPLCTime() {
      return daveReadPLCTime(dc);
   }

   DateTime getPLCTime() {
      int res = readPLCTime();
      if (res != 0) {
         throw new NodaveException(res);
      }

      getU8(); //???
      immutable(int) year = getU8().fromBCD() * 100 + getU8().fromBCD();
      immutable(int) month = fromBCD(getU8());
      immutable(int) day = getU8().fromBCD;
      immutable(int) hour = getU8().fromBCD;
      immutable(int) minute = getU8().fromBCD;
      immutable(int) second = getU8().fromBCD;
      return DateTime(year, month, day, hour, minute, second);
   }

   int setPLCTimeToSystime() {
      return daveSetPLCTimeToSystime(dc);
   }
}

/**
 * NoDave exception
 */
class NodaveException : Exception {
   this(int errNo) {
      string message = strerror(errNo);
      _errNo = errNo;

      this(message);
   }

   this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
      super(message, file, line, next);
   }

   private int _errNo;
   int errNo() {
      return _errNo;
   }
}
/**
 * NoDave read exception
 */
class NodaveReadException : NodaveException {
   this(int errNo, in int DB, in int start, in int length) {
      _db = DB;
      _start = start;
      _len = length;
      super(errNo);
   }

   private int _db;
   int dataBlock() {
      return _db;
   }

   private int _start;
   int startAddr() {
      return _start;
   }

   private int _len;
   int length() {
      return _len;
   }

}

unittest {
   auto ex = new NodaveException(6);
   assert(ex.errNo == 6);
   assert(ex.msg == "the CPU does not support reading a bit block of length<>1");
}

/**
 * Creates new daveConnection.
 *
 * `daveConnection` representing the physical connection to a single PLC.
 * `daveConnection` stores all properties that are unique to a single PLC:
 * $(UL
 * $(LI The MPI address of this PLC)
 * $(LI The rack the PLC is in.)
 * $(LI The slot the PLC is in.)
 * )
 */
daveConnection* createConnection(in string ip, in int port = 102) {
   daveConnection* dc;
   try {
      auto sock = new TcpSocket(new InternetAddress(ip, to!(ushort)(port)));
      _daveOSserialType fds;
      fds.wfd = fds.rfd = sock.handle;

      if (fds.rfd > 0) {
         daveInterface* di = daveNewInterface(fds, "IF1", 0, daveProtoISOTCP, daveSpeed9k);
         daveSetTimeout(di, 5_000_000);
         enum int MPI = 0;
         enum int RACK = 0;
         enum int SLOT = 2;
         dc = daveNewConnection(di, MPI, RACK, SLOT);
         if (daveConnectPLC(dc) != 0) {
            throw new NodaveException("Couldn't connect to PLC with ip " ~ ip);
         }
         return dc;
      } else {
         throw new NodaveException(
               "Couldn't open TCP port. Please make sure a CP is connected and the IP address is ok.");
      }

   } catch (Exception e) {
      throw new NodaveException("Generic exception");
   }
}
