/**
 * This module contains bindings to types and functions from the nodave C header <nodavesimple.h>.
 */
module dinodave.nodave;

import std.stdio;
import core.stdc.stdio;
import core.stdc.stdlib;

enum daveProtoISOTCP = 122; /** ISO over TCP */

/** ProfiBus/MPI speed constants to be used with newInterface */
enum daveSpeed9k = 0;
enum daveSpeed19k = 1;
enum daveSpeed187k = 2;
enum daveSpeed500k = 3;
enum daveSpeed1500k = 4;
enum daveSpeed45k = 5;
enum daveSpeed93k = 6;

enum daveP = 0x80;
enum daveInputs = 0x81;
enum daveOutputs = 0x82;
enum daveFlags = 0x83;
enum daveDB = 0x84; /** Data blocks */
enum daveDI = 0x85; /** Instance data blocks */
enum daveLocal = 0x86; /* not tested */
enum daveV = 0x87; /* don't know what it is */
enum daveCounter = 28; /** S7 counters */
enum daveTimer = 29; /** S7 timers */
enum daveCounter200 = 30; /* IEC counters (200 family) */
enum daveTimer200 = 31; /* IEC timers (200 family) */

extern (C):

alias daveConnection = _daveConnection;
alias daveInterface = _daveInterface;

struct _daveOSserialType {
   int rfd;
   int wfd;
}

struct PDU {
   ubyte* header;
   ubyte* param;
   ubyte* data;
   ubyte* udata;
   int hlen;
   int plen;
   int dlen;
   int udlen;
}

/**
 * A structure representing the physical connection to a PLC or a network of PLCs (e.g. like MPI).
 * daveInterface stores all those properties that are common to a network of PLCs:
 * - The local address used by your computer.
 * - The speed used in this network.
 * - The protocol type used in this network.
 * - A name which is used when printing out debug messages.
 *
 * The structure daveInterface is created and initialized by daveNewInterface:
 *
 * --------------------
 * daveInterface* di;
 * di = daveNewInterface(fds, "IF1", localMPI, daveProtoXXX, daveSpeedYYY);
 * --------------------
 *
 * or in D
 * --------------------
 * auto sock = new TcpSocket(new InternetAddress(ip, to!(ushort)(port)));
 * fds.wfd = fds.rfd = sock.handle;
 * daveInterface* di = daveNewInterface(fds, "IF1", 0, daveProtoISOTCP, daveSpeed9k);
 * --------------------
 */
struct _daveInterface {
   int _timeout;
}

/**
 * A structure representing the physical connection to a single PLC.
 * daveConnection stores all properties that are unique to a single PLC:
 * - The MPI address of this PLC.
 * - The rack the PLC is in.
 * - The slot the PLC is in.
 */
struct _daveConnection {
   int AnswLen;
   ubyte* resultPointer;
   int maxPDUlength;
}

struct daveBlockTypeEntry {
   ubyte[2] type;
   ushort count;
}

struct daveBlockEntry {
   ushort number;
   ubyte[2] type;
}

struct daveResult {
   int error;
   int length;
   ubyte* bytes;
}

struct daveResultSet {
   int numResults;
   daveResult* results;
}

// helper
// ---------
int daveGetS8from(ubyte* b);
int daveGetU8from(ubyte* b);
int daveGetS16from(ubyte* b);
int daveGetU16from(ubyte* b);
int daveGetS32from(ubyte* b);
uint daveGetU32from(ubyte* b);
float daveGetFloatfrom(ubyte* b);

ubyte* davePut8(ubyte* b, int v);
ubyte* davePut16(ubyte* b, int v);
ubyte* davePut32(ubyte* b, int v);
ubyte* davePutFloat(ubyte* b, float v);
void davePut8At(ubyte* b, int pos, int v);
void davePut16At(ubyte* b, int pos, int v);
void davePut32At(ubyte* b, int pos, int v);
void davePutFloatAt(ubyte* b, int pos, float v);

ubyte daveToBCD(ubyte i);
ubyte daveFromBCD(ubyte i);

// plc
// ---------
int daveGetS8(daveConnection* dc);
int daveGetU8(daveConnection* dc);
int daveGetS16(daveConnection* dc);
int daveGetU16(daveConnection* dc);
int daveGetS32(daveConnection* dc);
uint daveGetU32(daveConnection* dc);
float daveGetFloat(daveConnection* dc);

int daveGetS8At(daveConnection* dc, int pos);
int daveGetU8At(daveConnection* dc, int pos);
int daveGetS16At(daveConnection* dc, int pos);
int daveGetU16At(daveConnection* dc, int pos);
int daveGetS32At(daveConnection* dc, int pos);
uint daveGetU32At(daveConnection* dc, int pos);
float daveGetFloatAt(daveConnection* dc, int pos);

int daveSetBit(daveConnection* dc, int area, int DB, int byteAdr, int bitAdr);
int daveClrBit(daveConnection* dc, int area, int DB, int byteAdr, int bitAdr);

/**
 * Read len bytes from the PLC.
 *
 * Params:
 *  dc = A daveConnection
 *  area = Denotes whether the data comes from FLAGS, DATA BLOCKS,
 *  DB = The number of the data block to be used. Set it to zero
 *  start = First byte.
 *  len = Number of bytes to read
 *  buffer = Pointer to a memory block provided by the calling program.
 *           If the pointer is not NULL, the result data will be copied thereto.
 *           Hence it must be big enough to take up the result.
 *
 */
int daveReadBytes(daveConnection* dc, int area, int DB, int start, int len, void* buffer);

/**
 * Write len bytes from `buffer` to the PLC.
 *
 * Params:
 *  dc = A daveConnection
 *  area = Denotes whether the data comes from FLAGS, DATA BLOCKS,  INPUTS or OUTPUTS. The writing of other data   like timers and counters is not supported.
 *  start = determines the first byte
 *  DB = The number of the data block to be used. Set it to zero   for other area types.
 *  len = Number of bytes to write
 *  buffer = Pointer to a memory block.
 */
int daveWriteBytes(daveConnection* dc, int area, int DB, int start, int len, void* buffer);

int daveReadPLCTime(daveConnection* dc);

/**
 * Get time in seconds from current read position
 */
float daveGetSeconds(daveConnection* dc);

/**
 * Get time in seconds from random position
 *
 * Params:
 *  dc = a daveConnection
 *  pos = Position in bytes
 *
 * Examples:
 * --------------------
 * // read 4 timers: each timer has 2 bytes
 * const(int) res = daveReadBytes(dc, daveTimer, 0, 0, 4, null);
 * // read second of timer 2
 * float d = daveGetSecondsAt(dc, 4);
 * // 4 because:
 * // | pos | timer   |
 * // | 0   | timer 0 |
 * // | 1   | timer 0 |
 * // | 2   | timer 1 |
 * // | 3   | timer 1 |
 * // | 4   | timer 2 | <----
 * // | 5   | timer 2 |
 * --------------------
 */
float daveGetSecondsAt(daveConnection* dc, int pos);
int daveGetCounterValue(daveConnection* dc);
int daveGetCounterValueAt(daveConnection* dc, int pos);
void _daveConstructUpload(PDU* p, char blockType, int blockNr);
void _daveConstructDoUpload(PDU* p, int uploadID);
void _daveConstructEndUpload(PDU* p, int uploadID);

int daveGetOrderCode(daveConnection* dc, char* buf);
int daveReadManyBytes(daveConnection* dc, int area, int DBnum, int start, int len, void* buffer);
int daveWriteManyBytes(daveConnection* dc, int area, int DB, int start, int len, void* buffer);
int daveReadBits(daveConnection* dc, int area, int DB, int start, int len, void* buffer);
int daveWriteBits(daveConnection* dc, int area, int DB, int start, int len, void* buffer);

int daveReadSZL(daveConnection* dc, int ID, int index, void* buf, int buflen);
int daveListBlocksOfType(daveConnection* dc, ubyte type, daveBlockEntry* buf);
int daveListBlocks(daveConnection* dc, daveBlockTypeEntry* buf);
int initUpload(daveConnection* dc, char blockType, int blockNr, int* uploadID);
int doUpload(daveConnection* dc, int* more, ubyte** buffer, int* len, int uploadID);
int endUpload(daveConnection* dc, int uploadID);
int daveGetProgramBlock(daveConnection* dc, int blockType, int number, char* buffer, int* length);
int daveStop(daveConnection* dc);
int daveStart(daveConnection* dc);
int daveCopyRAMtoROM(daveConnection* dc);
int daveForce200(daveConnection* dc, int area, int start, int val);
void davePrepareReadRequest(daveConnection* dc, PDU* p);
void daveAddVarToReadRequest(PDU* p, int area, int DBnum, int start, int bytes);
int daveExecReadRequest(daveConnection* dc, PDU* p, daveResultSet* rl);
int daveUseResult(daveConnection* dc, daveResultSet* rl, int n);
void daveFreeResults(daveResultSet* rl);
void daveAddBitVarToReadRequest(PDU* p, int area, int DBnum, int start, int byteCount);
void davePrepareWriteRequest(daveConnection* dc, PDU* p);
void daveAddVarToWriteRequest(PDU* p, int area, int DBnum, int start, int bytes, void* buffer);
void daveAddBitVarToWriteRequest(PDU* p, int area, int DBnum, int start,
      int byteCount, void* buffer);
int daveExecWriteRequest(daveConnection* dc, PDU* p, daveResultSet* rl);
int daveInitAdapter(daveInterface* di);
int daveConnectPLC(daveConnection* dc);
int daveDisconnectPLC(daveConnection* dc);
int daveDisconnectAdapter(daveInterface* di);
int daveListReachablePartners(daveInterface* di, char* buf);
void daveSetTimeout(daveInterface* di, int tmo);
int daveGetTimeout(daveInterface* di);
char* daveGetName(daveInterface* di);
int daveGetMPIAdr(daveConnection* dc);
int daveGetAnswLen(daveConnection* dc);
int daveGetMaxPDULen(daveConnection* dc);
//daveResultSet* daveNewResultSet(...);

// FIX: void daveFree(void* dc);

//PDU* daveNewPDU(...);
int daveGetErrorOfResult(daveResultSet*, int number);
int daveForceDisconnectIBH(daveInterface* di, int src, int dest, int mpi);
int daveResetIBH(daveInterface* di);
int daveGetProgramBlock(daveConnection* dc, int blockType, int number, char* buffer, int* length);

int daveSetPLCTime(daveConnection* dc, ubyte* ts);
int daveSetPLCTimeToSystime(daveConnection* dc);

char* daveStrerror(int code);
void daveStringCopy(char* intString, char* extString);
void daveSetDebug(int nDebug);
int daveGetDebug();

/**
 * Create a daveInterface structure.
 *
 * Params:
 *  nfd = A _daveOSserialType
 *  nname = Interface name
 *  localMPI = The address used by your computer/adapter (only meaningful for MPI and PPI)
 *  protocol = A constant specifying the protocol to be used on this interface
 *  speed = A constant specifying the speed to be used on this interface. (only meaningful for MPI and Profibus)
 */
daveInterface* daveNewInterface(_daveOSserialType nfd, const(char)* nname,
      int localMPI, int protocol, int speed);

/**
 * Setup a new connection structure using an initialized
 * daveInterface and PLC's MPI address.
 *
 * Params:
 *  di = A daveInterface
 *  MPI = The address of the PLC (only meaningful for MPI and PPI).
 *  rack = The rack the CPU is mounted in (normally 0, only meaningful for ISO over TCP).
 *  slot = The slot number the CPU is mounted in (normally 2, only meaningful for ISO over TCP)
 */
daveConnection* daveNewConnection(daveInterface* di, int MPI, int rack, int slot);
int daveGetResponse(daveConnection* dc);
int daveSendMessage(daveConnection* dc, PDU* p);
void _daveDumpPDU(PDU* p);
void _daveDump(char* name, ubyte* b, int len);
char* daveBlockName(ubyte bn);
char* daveAreaName(ubyte n);

short daveSwapIed_16(short ff);
int daveSwapIed_32(int ff);
float toPLCfloat(float ff);
int daveToPLCfloat(float ff);
