// get from simplified/testISO_TCP

import std.stdio;
import dinodave;

enum DB = 11;
void main(string[] args) {
   enum string IP = "192.168.221.64";
   writeln("use ip:", IP);
   try {
      auto s7 = new IsoTcp(IP);
      s7.openConnection(0);
      writeln("opened");

      scope(exit) s7.closeConnection();
      read(s7);

      writeRead(s7);
   } catch(Exception e) {
      writeln(e);
   }
}

private void read(IPlc s7) {
   int start = 160;
   int length = 2;
   s7.readBytes(DB, start, length);

   int a = s7.getU16();
   writeln("db11.160: ", a);
}

private void writeRead(IPlc s7) {
   int start = 160;
   int length = 2;
   ubyte[] buffer = [0x00, 0x05];
   s7.writeBytes(DB, start, length, buffer);

   s7.readBytes(DB, start, length);
   int b = s7.getU16();
   int a0 = s7.getU8At(0);
   int a1 = s7.getU8At(1);
   writefln("0:%X 1:%X", a0, a1);

   writefln("as direct: %X", b);
   int le  = daveSwapIed_16(cast(short)b);
   writefln("as swapped: %X", le);
}
