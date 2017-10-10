import std.stdio;
import std.conv;
import std.bitmanip;
import std.getopt;

import dinodave;

void main(string[] args) {
   string ip = "192.168.0.150";
   int db = 100;
   int start = 12;
   int len = 12;
   int slot = 2;

   auto opt = getopt(args,
         "ip", "IP", &ip,
         "slot", "slot", &slot,
         "d", "DB num", &db,
         "s", "start address", &start,
         "l", "length in short", &len
         );
   if (opt.helpWanted) {
      defaultGetoptPrinter("Read short frm Siemens S7",
            opt.options);
   } else {
      try {
         writefln("ip:%s slot:%s DB:%s start:%s len:%s", ip, slot, db, start, len);
         writeln();

         auto s7 = new IsoTcp(ip);
         s7.openConnection(slot);
         scope(exit) s7.closeConnection();
         enum BYTES_PER_SHORT = 2;
         s7.readBytes(db, start, len * BYTES_PER_SHORT);
         for (int i = 0; i < len; ++i) {
            print(db, start + i * BYTES_PER_SHORT, s7.getS16);
         }
      } catch(Exception e) {
         writeln(e);
      }
   }
}

void print(int db, int addr, short i0) {
   writefln("db%s.%s %s", db, addr, i0);
}
