import QtQuick 2.15
import TextFile 1.0

QtObject {

    property int jsonError: 0
    property string jsonErrorMsg: ""

//    property var jsonfile: TextFile {
//        id: jsonfile

//        onErrorChanged: {
//            jsonErrorMsg = jsonfile.error_msg(errnum);
//        }
//    }

    function storeJson(subpath, object) {
        jsonError = 0;
//        jsonfile.set_path(path);
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

//        jsonfile.write(text);
//        if (jsonfile.error) {
        fileUtil.put_writable_file(subpath, text);
        if (fileUtil.fileError) {
            jsonErrorMsg = "Json write: " + fileUtil.fileErrorMsg;
            jsonError = 1;
            return;
        }
    }

    function loadJson(subpath, file_optional) {
        var object;
        var e;
        jsonError = 0;

        let text = fileUtil.get_dualfile(subpath);  // where do we call loadJson???
//        jsonfile.set_path(path);
//        let text = jsonfile.read();
        if (fileUtil.fileError) {
            if (file_optional) {
                return {};
            } else {
                jsonErrorMsg = "Json read: " + fileUtil.fileErrorMsg;
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

    function removeJson(subpath) {
        jsonError = 0;
//        jsonfile.set_path(path);
//        if (!jsonfile.remove()) {
        if (fileUtil.remove_writable_file(subpath)) {
            jsonErrorMsg = "Json could not remove file " + path;
            jsonError = 4;
        }
    }
}
