package gmtools.resources;

import gmtools.data.RoomData;
import sys.io.File;
import haxe.io.Path;

class GMRoom {

    public function new() {}

    public function parseRoom(filePath:String):Null<RoomData> {
        var filename = Path.withoutDirectory(filePath);

        var name:String;
        if (filename.length >= 9 && filename.substr(filename.length - 9) == ".room.gmx") {
            name = filename.substr(0, filename.length - 9);
        } else {
            name = Path.withoutExtension(filename);
        }

        var content:String;
        try {
            content = File.getContent(filePath);
        } catch (e:Dynamic) {
            trace('Failed to load room file: $filePath');
            return null;
        }

        var xml:Xml;
        try {
            xml = Xml.parse(content);
        } catch (e:Dynamic) {
            trace('Failed to parse XML in file: $filePath');
            return null;
        }

        var roomElement = xml.firstElement();
        if (roomElement == null || roomElement.nodeName != "room") {
            trace('No room element found in file: $filePath');
            return null;
        }

        var roomData:RoomData = {
            name:       name,
            width:      0,
            height:     0,
            speed:      0,
            background: "",
            playerX:    0,
            playerY:    0,
            hasPlayer:  false
        };

        if (!parseRoomProperties(roomElement, roomData)) {
            return null;
        }

        var backgroundsElement = roomElement.elementsNamed("backgrounds").next();
        if (backgroundsElement != null) {
            parseBackgrounds(backgroundsElement, roomData);
        }

        var instancesElement = roomElement.elementsNamed("instances").next();
        if (instancesElement != null) {
            parseInstances(instancesElement, roomData);
        }

        return roomData;
    }

    private function parseRoomProperties(roomElement:Xml, roomData:RoomData):Bool {
        var widthEl  = roomElement.elementsNamed("width").next();
        var heightEl = roomElement.elementsNamed("height").next();
        var speedEl  = roomElement.elementsNamed("speed").next();

        if (widthEl == null || heightEl == null || speedEl == null) {
            trace("Missing required room properties (width, height, speed)");
            return false;
        }

        roomData.width  = Std.parseInt(widthEl.firstChild().nodeValue);
        roomData.height = Std.parseInt(heightEl.firstChild().nodeValue);
        roomData.speed  = Std.parseInt(speedEl.firstChild().nodeValue);

        return true;
    }

    private function parseBackgrounds(backgroundsElement:Xml, roomData:RoomData):Bool {
        for (bgElement in backgroundsElement.elementsNamed("background")) {
            var visible = bgElement.get("visible");
            var name    = bgElement.get("name");

            if (visible == "-1" && name != null) {
                roomData.background = convertBackgroundPath(name);
                break;
            }
        }

        return true;
    }

    private function parseInstances(instancesElement:Xml, roomData:RoomData):Bool {
        for (instanceElement in instancesElement.elementsNamed("instance")) {
            var objName = instanceElement.get("objName");
            var xStr    = instanceElement.get("x");
            var yStr    = instanceElement.get("y");

            if (objName != null && xStr != null && yStr != null) {
                if (objName == "obj_mainchara") {
                    roomData.playerX   = Std.parseInt(xStr);
                    roomData.playerY   = Std.parseInt(yStr);
                    roomData.hasPlayer = true;
                    break;
                }
            }
        }

        return true;
    }

    private function convertBackgroundPath(gmxBackground:String):String {
        return "assets/sprites/backgrounds/" + gmxBackground + ".png";
    }
}
