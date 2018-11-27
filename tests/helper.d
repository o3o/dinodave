module tests.helper;

import std.stdio;
import unit_threaded;

import dinodave;

@UnitTest void put8_should_set_byte() {
   ubyte[] a = [1, 2, 3, 4];
   a.put8(50);
   a.shouldEqual([50, 2, 3, 4]);
   a.put8(51);
   a.shouldEqual([51, 2, 3, 4]);
}

@UnitTest void put8at_should_set_byte_at_position() {
   ubyte[] a = [1, 2, 3, 4];
   a.put8At(0, 50);
   a.shouldEqual([50, 2, 3, 4]);
   a.put8At(1, 51);
   a.shouldEqual([50, 51, 3, 4]);

   a.put8At(19, 52).shouldThrow!Exception;
   a.put8At(-19, 52).shouldThrow!Exception;

   //ubyte* p = davePut8(a.ptr, 50);
   //ubyte[] b = (p)[0..2];
   //writeln(a);
   //writeln(b);
}

@UnitTest void daveput8at_should_set_byte_at_position() {
   ubyte[] a = [1, 2, 3, 4];
   davePut8At(a.ptr, 0, 50);
   a.shouldEqual([50, 2, 3, 4]);
   davePut8At(a.ptr, 1, 51);
   a.shouldEqual([50, 51, 3, 4]);

   // Segmentation fault!!!!
   //davePut8At(a.ptr, 19, 52).shouldNotThrow!Exception;
   // davePut8At(a.ptr, -19, 52).shouldNotThrow!Exception;
}

void testBcdToDec() {
   (0x0).toBCD().shouldEqual(0);
   (0x5).toBCD().shouldEqual(5);
   (0xA).toBCD().shouldEqual(16);
   (11).toBCD().shouldEqual(17);
}

void testStrerrr() {
   strerror(0x8000).shouldEqual("function already occupied.");

   strerror(0x8001).shouldEqual("not allowed in current operating status.");
   strerror(0x8101).shouldEqual("hardware fault.");
   strerror(0x8103).shouldEqual("object access not allowed.");
   strerror(0x8104).shouldEqual(
         "context is not supported. Step7 says:Function not implemented or error in telgram.");
   strerror(0x8105).shouldEqual("invalid address.");
   strerror(0x8106).shouldEqual("data type not supported.");
   strerror(0x8107).shouldEqual("data type not consistent.");
   strerror(0x810A).shouldEqual("object does not exist.");
   strerror(0x8500).shouldEqual("incorrect PDU size.");
   strerror(0x8702).shouldEqual("address invalid.");
   strerror(0xd201).shouldEqual("block name syntax error.");
   strerror(0xd202).shouldEqual("syntax error function parameter.");
   strerror(0xd203).shouldEqual("syntax error block type.");
   strerror(0xd204).shouldEqual("no linked block in storage medium.");
   strerror(0xd205).shouldEqual("object already exists.");
   strerror(0xd206).shouldEqual("object already exists.");
   strerror(0xd207).shouldEqual("block exists in EPROM.");
   strerror(0xd209).shouldEqual("block does not exist/could not be found.");
   strerror(0xd20e).shouldEqual("no block present.");
   strerror(0xd210).shouldEqual("block number too big.");
}

void testPut8() {
   ubyte[] buf = [0, 2, 4];
   buf[0].shouldEqual(0);
   put8(buf, 10);
   buf[0].shouldEqual(10);
   buf.length.shouldEqual(3);
   put8(buf, 0xFF);
   writeln("e", buf[0]);
}

void testGetU8Array() {
   auto m = mock!IPlc;
   m.returnValue!"getU8"(cast(ubyte)0x41, cast(ubyte)0x42, cast(ubyte)0x43);
   ubyte[] buf = getU8Array(m, 3);
   buf.shouldEqual([0x41, 0x42, 0x43]);
}
