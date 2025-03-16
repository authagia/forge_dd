/+ dub.sdl:
name "d_playground"
+/

enum B64 = "xocAAOCwmuOQpOeNi+OZluK5jOGmmMy64rix5oGk5JK45qGR5Ju25q+s4bWY44K65rGs5oCG5JK45YCJ5p2Q4rmN5aeZ46a05pW04KOk45S"
         ~ "Y4amiE+K5geWnmeOmtOaVtOCjpOOUmOGpouGAk+KFoOGpm+OSvOaVruajsNeJzpvmgrDkuozhtZjjqLbmtanls5LihpXGkOGMg+KXhuSujB"
         ~ "rmmIrkk6jilrHhjJPimJfgvK7gsoLhoJjiuLHlsaTDpOGhiOSdluCwruWsm+OaudWw5bGk46OU4YaR4YOA5rmM5aiY46i05o2l5quo5peJ5"
         ~ "KCz4ouj4peG5LSM45yD55Gl5buu4reJ4KCL4oCTw4Dhr5zjiLfniaXmiIzkgrjipbHkjJPitqDhqZjCtzHYhOGWqOWti+WMkOSXhuCwjOGg"
         ~ "l+OEruaxoOCwnOCtg+abpuCyreSFm+GcmOK4sMmg4YCQ4K6g4pi24oaP5K6M4ZyY4rS05buQ4aeR5I2LwpfksK3lpJvjkLnmraHgq4rjo4T"
         ~ "nhoHNguSDoOGlm+OuuueJr+CrluOjhOeGgc2C5IGA4aOD44q555Gh5qOK4LaF4K+T5J2W4reu4LGB4aaX45yu5Jic4ZeJ4oyL5JmX5rCu5b"
         ~ "qY46qw5r205oiC4YCA44Co4pu24rOuGeOohuaVqeO7pOO3jeKOk+aal+azreCxgOGgl9SA5oOm4pax4a6j5oyQ4pilAOOMhOelrOWDruGWl"
         ~ "c2j5oCg5LGg5aWc46iw1aXlsazjo4DihpHhm5DktKzkgZsZAAo=";

import std.stdio;
import std.base64;
import std.utf;
import std.array;
import std.algorithm;

import std.container: SList;

void main(){
    writeln("Hello");
    auto d = Base64.decoder(B64);
    d.array[0..20].writeln;
    d.array[$-20..$].writeln;
    auto dlist = SList!ubyte(d.array);
    auto cp = stdin.byChunk(1024).joiner.map!(b=>cast(char)b).byUTF!dchar;
    auto size = cp.front;
    cp.popFront;
    size |= cp.front << 15;
    cp.popFront;
    (cast(int)size).writeln;

    // d.writeln;
    // auto dc = cast(char[])d.array;
    // auto codepoints = cast(ushort[])dc.byUTF!dchar.array;
    // decodeOptimized(cast(string)dc).writeln;

}

ubyte[] decodeOptimized(string d){
    auto codepoints = d.byUTF!dchar.array;
    auto size = codepoints[0] | (codepoints[1] << 15);
    writeln("decode size: ", size);
    ubyte[] packageData;
    int buf = 0;
    ubyte bitsInBuf = 0;
    foreach (c; codepoints[2..$]){
        while(bitsInBuf >= 8){
            packageData ~= cast(ubyte) buf;
            buf >>= 8;
            bitsInBuf -= 8;
        }

        buf |= (c & 0x7fff) << bitsInBuf;
        bitsInBuf += 15;
    }
    writefln("writing left over data: %032b,  %d", buf, bitsInBuf);
    while(packageData.length < size && bitsInBuf >= 8){
        packageData ~= cast(ubyte) buf;
        buf >>= 8;
        bitsInBuf -= 8;
    }
    writefln("coded size: %d, actual size: %d, unused bits: %d", size, packageData.length, bitsInBuf);
    writefln("Remaining data in the buffer: %x", buf);

    return packageData;
}