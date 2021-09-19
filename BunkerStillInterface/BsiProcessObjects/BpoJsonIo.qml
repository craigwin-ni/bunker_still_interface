import QtQuick 2.15
import TextFile 1.0

QtObject {

    property int jsonError: 0
    property string jsonErrorMsg: ""

    property var jsonfile: TextFile {
        id: jsonfile

        onErrorChanged: {
            jsonErrorMsg = jsonfile.error_msg(errnum);
        }
    }

    function storeJson(path, object) {
        jsonError = 0;
        jsonfile.set_path(path);
        var e;
        var text;
        try {
            text = JSON.stringify(object, 0, 2);
        } catch (e) {
            jsonErrorMsg = "Json data type: '" + path + "' @" +
                    e.lineNumber + ":" + e.comumnNumber + " " + e.message;
            jsonError = 3;
            return;
        }

        jsonfile.write(text);
        if (jsonfile.error) {
            jsonErrorMsg = "Json write: " + jsonErrorMsg;
            jsonError = 1;
            return;
        }
    }

    function loadJson(path, file_optional) {
        var object;
        var e;
        jsonError = 0;
        jsonfile.set_path(path);
        let text = jsonfile.read();
        if (jsonfile.error) {
            if (file_optional) {
                return {};
            } else {
                jsonErrorMsg = "Json read: " + jsonErrorMsg;
                jsonError = 1;
                return;
            }
        }

        try {
            object = JSON.parse(text);
        } catch(e) {
            // Report parse errors.
            jsonErrorMsg = "Json parse '" + path + "' @" +
                    e.lineNumber + ":" + e.comumnNumber + " " + e.message;
            jsonError = 2;
            return;
        }
        return object;
    }

    function removeJson(path) {
        jsonError = 0;
        jsonfile.set_path(path);
        if (!jsonfile.remove()) {
            jsonErrorMsg = "Json could not remove file " + path;
            jsonError = 4;
        }
    }
}
