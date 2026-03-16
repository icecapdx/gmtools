package gmtools.io;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.io.File;

typedef GameData = {
    var fileBytes:Bytes;
    var chunks:Map<String, Bytes>;
    var gen8:Null<Bytes>;  // General info
    var strg:Null<Bytes>;  // Strings
    var room:Null<Bytes>;  // Rooms
    var sprt:Null<Bytes>;  // Sprites
    var objt:Null<Bytes>;  // Game objects
    var bgnd:Null<Bytes>;  // Backgrounds
    var sond:Null<Bytes>;  // Sounds
    var code:Null<Bytes>;  // Code
    var vari:Null<Bytes>;  // Variables
    var func:Null<Bytes>;  // Functions
    var tpag:Null<Bytes>;  // Texture page items
    var txtr:Null<Bytes>;  // Textures
    var audo:Null<Bytes>;  // Audio
}

class DataReader {

    public function new() {}

    public function read(filePath:String):Null<GameData> {
        var bytes:Bytes;
        try {
            bytes = File.getBytes(filePath);
        } catch (e:Dynamic) {
            trace('Failed to open data file: $filePath');
            return null;
        }

        var input = new BytesInput(bytes);
        input.bigEndian = false;

        var formName = readChunkName(input);
        if (formName != "FORM") {
            trace('Not a valid GameMaker data file (expected FORM, got "$formName")');
            return null;
        }

        var formLength = input.readInt32();
        var formEnd    = input.position + formLength;

        var chunks:Map<String, Bytes> = [];

        while (input.position < formEnd) {
            var chunkName   = readChunkName(input);
            var chunkLength = input.readInt32();

            if (chunkLength < 0) {
                trace('Invalid chunk length for "$chunkName"');
                return null;
            }

            var chunkData = input.read(chunkLength);
            chunks[chunkName] = chunkData;

            while (input.position < formEnd && input.position % 16 != 0) {
                var pad = input.readByte();
                if (pad != 0) {
                    input.position -= 1;
                    break;
                }
            }
        }

        return {
            fileBytes: bytes,
            chunks: chunks,
            gen8:   chunks["GEN8"],
            strg:   chunks["STRG"],
            room:   chunks["ROOM"],
            sprt:   chunks["SPRT"],
            objt:   chunks["OBJT"],
            bgnd:   chunks["BGND"],
            sond:   chunks["SOND"],
            code:   chunks["CODE"],
            vari:   chunks["VARI"],
            func:   chunks["FUNC"],
            tpag:   chunks["TPAG"],
            txtr:   chunks["TXTR"],
            audo:   chunks["AUDO"],
        };
    }

    private function readChunkName(input:BytesInput):String {
        return String.fromCharCode(input.readByte())
             + String.fromCharCode(input.readByte())
             + String.fromCharCode(input.readByte())
             + String.fromCharCode(input.readByte());
    }
}
