import std.stdio;
import std.utf;
import std.array;
import std.range;
import std.algorithm;
import std.json;

import datadrawer: DataDrawer;

void main() {
    auto dataPackage = decodeOptimized(stdin);
    auto drawer = DataDrawer(dataPackage);

    auto mods = getMods(drawer);
    JSONValue json;
    foreach (key, value; mods) {
        json[key] = value;
    }
    json.toString.write;
}

ubyte[] decodeOptimized(File f){
    auto codepoints = f.byChunk(1024)
                        .joiner
                        .map!(b=>cast(char)b)
                        .byUTF!dchar;

    int size = codepoints.front;
    codepoints.popFront;
    size |= codepoints.front << 15;
    codepoints.popFront;

    ubyte[] packageData;
    int buf = 0;
    ubyte bitsInBuf = 0;
    foreach (c; codepoints){
        while(bitsInBuf >= 8){
            packageData ~= cast(ubyte) buf;
            buf >>= 8;
            bitsInBuf -= 8;
        }

        buf |= (c & 0x7fff) << bitsInBuf;
        bitsInBuf += 15;
    }

    while(packageData.length < size){
        packageData ~= cast(ubyte) buf;
        buf >>= 8;
        bitsInBuf -= 8;
    }

    return packageData;
}

string[string] getMods(DataDrawer dd){

    dd.readNextBool;
    auto modsSize = dd.readNextUShort;

    string[string] mods;
    foreach (_; 0..modsSize){
        auto channelSizeAndVersionFlag = dd.readNextVarInt;
        auto channelSize = channelSizeAndVersionFlag >> 1;
        auto ignoreServerOnly = (channelSizeAndVersionFlag & 0b1) != 0; // check lsb

        auto modId = dd.readNextString;
        auto modVersion = "IGNORED";
        if(!ignoreServerOnly) modVersion = dd.readNextString;
        foreach (__; 0..channelSize){
            dd.readNextString; // channelName
            dd.readNextString; // channelVersion
            dd.readNextBool;   // requiredOnClient
        }
        mods[modId] = modVersion;
    }

    return mods;
}