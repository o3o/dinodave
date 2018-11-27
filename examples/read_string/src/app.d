import std.stdio;
import dinodave;

void main(string[] args) {
   import std.conv : to;
   enum string IP = "192.168.128.1";
   string ip = IP;
   enum int SLOT = 0;
   int slot = SLOT;

   if (args.length > 1) {
      ip = args[1];
   }
   if (args.length > 2) {
      slot = args[2].to!int;
   }

   try {
      writeln("use ip:", ip);
      writeln("use slot:", slot);
      auto s7 = new IsoTcp(IP);
      s7.openConnection(slot);
      writeln("opened");

      scope(exit) s7.closeConnection();
      write(s7);
      read(s7);

   } catch(Exception e) {
      writeln(e);
   }
}

enum DB = 100;
private void write(IPlc s7) {
   ubyte[] buffer = [
      0x41, 0x42,
      0x43, 0x44,
      0x45, 0x46,
      0x47, 0x48
   ];
   s7.writeBytes(DB, 104, 8, buffer);
}
private void read(IPlc s7) {
   try {
      ubyte[] buffer = s7.readManyBytes(DB, 104, 8);
      writefln("buf len %s", buffer.length);
      writefln("%( 0x%x %)", buffer);
      writefln("%s", buffer.getFixString(8));

      s7.readBytes(DB, 104, 8);
      ubyte[] buf = s7.getU8Array(8);
      writefln("%s", buffer.getFixString(8));
   } catch (NodaveException e) {
      writefln("err: %s  %s", e.errNo, e.msg);
   } catch (Exception e) {
      writeln(e.msg);
   }
}
