import std.stdio;
import dinodave;
import std.conv;
import std.bitmanip;
void main(string[] args) {
   enum string IP = "192.168.221.102";
   enum DB = 23;
   enum ADDR = 82;

   string ip = IP;
   if (args.length > 1) {
      ip = args[1];
   }

   try {
      writeln("use ip ", ip);

      IPlc s7 = new IsoTcp(ip);
      enum int SLOT = 0;
      s7.openConnection(SLOT);
      scope(exit) s7.closeConnection();

      float f = 19.64;
      ubyte[] bufferLE = [0xb8, 0x1e, 0x9d, 0x41];
      ubyte[] bufferBE = [0x41, 0x9d, 0x1e, 0xb8];


      s7.writeBytes(DB, ADDR, 4, bufferBE);

      ubyte[4] swappedF = nativeToBigEndian(64.19f);
      s7.writeBytes(DB, ADDR + 4 , 4, swappedF);
      s7.writeBytes(DB, ADDR + 8 , 4, 20.04f.nativeToBigEndian);

      s7.readBytes(DB, ADDR, 12);

      float f0 = s7.getFloat;
      assert(f0 == 19.64f);
      printFloat("f0", f0);

      float f1 = s7.getFloat;
      assert(f1 == 64.19f);
      printFloat("f1", f1);

      float f2 = s7.getFloat;
      assert(f2 == 20.04f);
      printFloat("f2", f2);


   } catch(Exception e) {
      writeln(e);
   }
}

void printFloat(string m, float f) {
   writefln("%s = %s", m, f);
}
