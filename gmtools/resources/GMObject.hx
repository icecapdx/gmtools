package gmtools.resources;

import gmtools.data.ObjectData;
import gmtools.data.ObjectInstance;

import sys.io.File;

class GMObject {

    public function new() {}

    public function parseObjects(filePath:String):Null<ObjectData> {
        var content:String;
        try {
            content = File.getContent(filePath);
        } catch (e:Dynamic) {
            trace('Failed to load object file: $filePath');
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

        var instancesElement = roomElement.elementsNamed("instances").next();
        if (instancesElement == null) {
            trace("No instances element found in room file");
            return null;
        }

        var objectData:ObjectData = { instances: [] };

        for (instanceElement in instancesElement.elementsNamed("instance")) {
            var instance = parseInstance(instanceElement);
            if (instance != null) {
                objectData.instances.push(instance);
            }
        }

        return objectData;
    }

    private function parseInstance(instanceElement:Xml):Null<ObjectInstance> {
        var objName  = instanceElement.get("objName");
        var name     = instanceElement.get("name");
        var xStr     = instanceElement.get("x");
        var yStr     = instanceElement.get("y");

        if (objName == null || name == null || xStr == null || yStr == null) {
            trace("Missing required instance attributes");
            return null;
        }

        var code     = instanceElement.get("code");
        var scaleXStr = instanceElement.get("scaleX");
        var scaleYStr = instanceElement.get("scaleY");
        var colorStr  = instanceElement.get("colour");
        var rotStr    = instanceElement.get("rotation");
        var lockedStr = instanceElement.get("locked");

        return {
            objectName: objName,
            name:       name,
            x:          Std.parseInt(xStr),
            y:          Std.parseInt(yStr),
            code:       code != null ? code : "",
            scaleX:     scaleXStr != null ? Std.parseFloat(scaleXStr) : 1.0,
            scaleY:     scaleYStr != null ? Std.parseFloat(scaleYStr) : 1.0,
            color:      colorStr != null ? parseColor(colorStr) : 0xFFFFFFFF,
            rotation:   rotStr != null ? Std.parseFloat(rotStr) : 0.0,
            locked:     lockedStr != null ? (lockedStr == "1" || lockedStr == "-1") : false,
        };
    }

    private function parseColor(colorStr:String):Int {
        try {
            return Std.parseInt(colorStr);
        } catch (e:Dynamic) {
            trace('Failed to parse color value: $colorStr');
            return 0xFFFFFFFF;
        }
    }
}
