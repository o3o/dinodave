module tests.plc;

import std.stdio;
import unit_threaded;

import dinodave;

/*
   S7 should be connected at 192.168.221.102o

   Run with:
   ./libdinodave-test -d tests.plc.set_bit_should_work
*/
@UnitTest
@HiddenTest
void set_bit_should_work() {
   enum string IP = "192.168.221.64";
   enum DB = 23;
   enum ADDR = 200;
   try {
      auto s7 = new IsoTcp(IP);
      s7.openConnection(0);
      writeln("opened");
      scope(exit) s7.closeConnection();
      ubyte[] buf = [0, 0];
      s7.writeBytes(DB, ADDR, 1, buf);
      s7.setBit(DB, ADDR, 1);
      s7.setBit(DB, ADDR, 2);
      s7.readBytes(DB, ADDR,  1);
      int v = s7.getU8();
      writeln("set ", v);
      v.shouldEqual(6);
      s7.clearBit(DB, ADDR, 1);

      s7.readBytes(DB, ADDR, 1);
      v = s7.getU8();
      writeln("reset ", v);

      v.shouldEqual(4);

   } catch(Exception e) {
      writeln(e);
   }

}
import std.conv;
@HiddenTest
void testReadPLCTime() {
   enum string IP = "192.168.221.102";
   enum DB = 23;
   enum ADDR = 200;
   try {
      auto s7 = new IsoTcp(IP);
      s7.openConnection(0);
      scope(exit) s7.closeConnection();

      int v = s7.readPLCTime();
      for (size_t i = 0; i < 10; ++i) {
         int a = fromBCD(to!ubyte(s7.getU8()));
         writefln("%d: %d ", i, a);
      }

   } catch(Exception e) {
      writeln(e);
   }
}
