module dinodave.bufferappender;

version (unittest) {
   import unit_threaded;
}

import std.array: Appender, appender;

/**
 * Appends byte to the managed array.
 */
Appender!(ubyte[]) put8(Appender!(ubyte[]) app, in ubyte value) {
   app.put(value);
   return app;
}

unittest {
   auto app = appender!(ubyte[]);
   app.put8(10);
   app.put8(11);
   app.put8(12);
   app.put8(13);
   app.data.length.shouldEqual(4);
   app.data.shouldEqual([10,11,12,13]);
}

unittest {
   auto app = appender!(ubyte[]);
   app.put8(10)
      .put8(11)
      .put8(12)
      .put8(13);

   app.data.length.shouldEqual(4);
   app.data.shouldEqual([10,11,12,13]);
}


/**
 * Converts int `value` into bytes and appends it to the managed array.
 */
Appender!(ubyte[]) put32(Appender!(ubyte[]) app, in int value) {
   import dinodave.helper: put32;
   ubyte[] buffer = new ubyte[](4);
   put32(buffer, value);
   app.put(buffer);
   return app;
}

unittest {
   auto app = appender!(ubyte[]);
   app.put32(42);
   app.put32(43);
   app.data.length.shouldEqual(8);
}

/**
 * Converts float `value` into bytes and appends it to the managed array.
 */
Appender!(ubyte[]) putFloat(Appender!(ubyte[]) app, in float value) {
   import dinodave.helper: putFloat;
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

   app.data.length.shouldEqual(16);
   app.data.shouldEqual([
         0x42, 0x28, 0x0 , 0x0,  //42
         0x44, 0xf5, 0x80, 0x0,  //1964
         0x41, 0x9d, 0x1e, 0xb8,  //19.64
         0x40, 0x49, 0x0e, 0x56,  //3.1415
   ]);
}
