import std.stdio;
import std.conv;
import std.bitmanip;
import std.getopt;

import dinodave;

void main(string[] args) {
   string ip = "172.20.0.10";
   int db = 610;
   int start = 2;
   int len = 2;
   int slot = 0;

   auto opt = getopt(args,
         "ip", "Ip (172.20.0.10)", &ip,
         "slot", "Slot (default 0)", &slot,
         "d", "DB num (default 610)", &db,
         "s", "Start address (default 2)", &start,
         "l", "Length in int (default 2)", &len
         );
   if (opt.helpWanted) {
      defaultGetoptPrinter("Read int (4 bytes) from Siemens S7",
            opt.options);
   } else {
      try {
         writefln("ip:%s slot:%s DB:%s start:%s len:%s", ip, slot, db, start, len);
         writeln();

         auto s7 = new IsoTcp(ip);
         s7.openConnection(slot);
         scope(exit) s7.closeConnection();
         enum BYTES_PER_INT = 4;
         s7.readBytes(db, start, len * BYTES_PER_INT);
         for (int i = 0; i < len; ++i) {
            print(db, start + i * BYTES_PER_INT, s7.getU32);
         }
      } catch(Exception e) {
         writeln(e);
      }
   }
}

void print(int db, int addr, uint i0) {
   writefln("db%s.%s %s", db, addr, i0);
}
