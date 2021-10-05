/**
 * Implements an output range that appends data to a buffer.
 */
module dinodave.bufferappender;


import std.array : Appender, appender;

/**
 * Appends byte to the managed array.
 */
Appender!(ubyte[]) put8(Appender!(ubyte[]) app, in ubyte value) {
   app.put(value);
   return app;
}
///
unittest {
   auto app = appender!(ubyte[]);
   app.put8(10);
   app.put8(11);
   app.put8(12);
   app.put8(13);
   assert(app.data.length == 4);
   assert(app.data == [10, 11, 12, 13]);
}

unittest {
   auto app = appender!(ubyte[]);
   // dfmt off
   app.put8(10)
      .put8(11)
      .put8(12)
      .put8(13);
   // dfmt on
   assert(app.data.length == 4);
   assert(app.data == [10, 11, 12, 13]);
}

/**
 * Converts short `value` into bytes and appends it to the managed array.
 */
Appender!(ubyte[]) put16(Appender!(ubyte[]) app, in int value) {
   import dinodave.helper : put16;

   ubyte[] buffer = new ubyte[](2);
   put16(buffer, value);
   app.put(buffer);
   return app;
}
///
unittest {
   auto app = appender!(ubyte[]);
   app.put16(42);
   app.put16(1964);
   app.put16(2018);
   app.put16(1971);
   assert(app.data.length == 8);
   assert(app.data == [0x00, 0x2a, 0x07, 0xac, 0x07, 0xe2, 0x07, 0xb3,]);
}
unittest {
   auto app = appender!(ubyte[]);
   app.put16(42);
   app.put16(1964).put16(2018);
   app.put16(1971);
   assert(app.data.length == 8);
   assert(app.data == [0x00, 0x2a, 0x07, 0xac, 0x07, 0xe2, 0x07, 0xb3]);
}

unittest {
   import core.bitop: bts;
   auto app = appender!(ubyte[]);
   size_t r = 0;
   size_t c = 0;
   bts(&r, 0);
   bts(&r, 1);
   bts(&r, 2);
   bts(&c, 0);

   app.put8(cast(ubyte)r);
   app.put8(cast(ubyte)c);
   assert(app.data == [0x07, 0x01]);
}
unittest {
   import core.bitop: bts;
   auto app = appender!(ubyte[]);
   size_t r = 0;
   bts(&r, 8);
   bts(&r, 9);
   bts(&r, 10);
   bts(&r, 0);

   app.put16(cast(int)r);
   assert(app.data == [0x07, 0x01]);
}

/**
 * Converts int `value` into bytes and appends it to the managed array.
 */
Appender!(ubyte[]) put32(Appender!(ubyte[]) app, in int value) {
   import dinodave.helper : put32;

   ubyte[] buffer = new ubyte[](4);
   put32(buffer, value);
   app.put(buffer);
   return app;
}

unittest {
   auto app = appender!(ubyte[]);
   app.put32(19641971);
   app.put32(19712004);
   app.put32(20072004);
   assert(app.data.length == 12);

   // dfmt off
   assert(app.data == [
         0x01, 0x2b, 0xb6, 0x73,
         0x01, 0x2c, 0xc8, 0x04,
         0x01, 0x32, 0x46, 0x44]);
   // dfmt on
}

/**
 * Converts float `value` into bytes and appends it to the managed array.
 */
Appender!(ubyte[]) putFloat(Appender!(ubyte[]) app, in float value) {
   import dinodave.helper : putFloat;

   ubyte[] buffer = new ubyte[](4);
   putFloat(buffer, value);
   app.put(buffer);
   return app;
}

unittest {
   auto app = appender!(ubyte[]);
   app.putFloat(42.);
   app.putFloat(1964.);
   app.putFloat(19.64);
   app.putFloat(3.1415);

   assert(app.data.length == 16);
   // dfmt off
   assert(app.data == [
         0x42, 0x28, 0x0, 0x0, //42
         0x44, 0xf5, 0x80, 0x0, //1964
         0x41, 0x9d, 0x1e, 0xb8, //19.64
         0x40, 0x49, 0x0e, 0x56, //3.1415
         ]);
   // dfmt on
}
