module datadrawer;

import std.stdio;

import std.container: SList;
import std.range: take;
import std.array: array;

struct DataDrawer{
    private SList!ubyte _queue;
    this(ubyte[] value){
        _queue = SList!ubyte(value);
        //reversed, so we can use it like queue;
    }
    this(SList!ubyte dls){
        _queue = dls;
    }

    bool readNextBool(){
        return _queue.removeAny != 0x00;
    }
    ushort readNextUShort(){
        ushort us = (_queue.removeAny << 8) | _queue.removeAny;
        return us;
    }
    ulong readNextVarInt(){
        ulong i = 0, j = 0;
        ubyte b;
        do{
            b = _queue.removeAny;
            i |= cast(ulong)(b & 0b0111_1111) << j++ * 7;
            if(j > 8)throw new Exception("cannot decode VarInt over 64 bits, ulong size");
        }while(b >> 7 != 0);

        return i;
    }
    ubyte[] readData(int size){
        auto data = _queue[].take(size);
        _queue.linearRemove(data);
        return data.array;
    }
    string readNextString(){
        auto len = cast(int)this.readNextVarInt;//文字数がそんなに長いわけないだろ！(慢心)
        if(len < 1)return "";
        return cast(string)this.readData(len);
    }
}