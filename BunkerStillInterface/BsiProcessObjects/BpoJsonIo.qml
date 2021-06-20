import QtQuick 2.15
import TextFile 1.0

QtObject {

    property int jsonError: 0
    property string jsonErrorMsg: ""

    property var jsonfile: TextFile {
        id: jsonfile

        onErrorChanged: {
            jsonErrorMsg = jsonfile.error_msg(errnum);
            jsonError = 1;
        }
    }

    function storeJson(path, object) {
        jsonError = 0;
        jsonfile.set_path(path);
        var text;
        try{
                text = JSON.stringify(object);
        } catch (e) {
            jsonErrorMsg = "Json object data type error: " + e.message +
                    " for '" + path + "'.";
            jsonError = 3;
            return;
        }

        jsonfile.write(text);
    }

    function loadJson(path) {
        var object;
        jsonError = 0;
        jsonfile.set_path(path);
        let text = jsonfile.read();
        try {
            object = JSON.parse(text);
        } catch(e) {
            // Report parse errors.
            jsonErrorMsg = "Json syntax error: " + e.message +
                    " at " + e.lineNumber + ":" + e.comumnNumber + " in '" + path + "'.";
            jsonError = 2;
        }
        return object;
    }
}
