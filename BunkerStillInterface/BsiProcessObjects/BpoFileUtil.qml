import QtQuick 2.0
import Qt.labs.folderlistmodel 2.15
import Qt.labs.platform 1.1
import TextFile 1.0
import "../javascript/path_util.js" as Pathjs

QtObject {
    id: file_util

    property bool writable_folder_ok: true
    property bool pages_ok: true
    property bool page_units_ok: true
    property bool annotations_ok: true
    property bool connections_file_ok: true

    property int fileError: 0
    property string fileErrorMsg: ""

    signal pagesUpdated(string subpath)
    signal pageUnitsUpdated(string subpath)

    property var the_folder: FolderListModel {
        id: the_folder

        property var onReady: null
        property string default_folder: "./no-such-folder"

        property var onReady_timer: Timer{
            interval: 50;
            onTriggered: if (the_folder.onReady) the_folder.onReady();
        }

        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                if (folder != default_folder) {
                    if (onReady) onReady_timer.running = true;
                }
            }
        }

        folder: "./no-such-folder"
        nameFilters: ["*"]
        showDirs: true
        showOnlyReadable: false
        sortField: FolderListModel.Name
    }

    property var writable_file: TextFile {
        id: writable_file

        onErrorChanged: {
            fileErrorMsg = writable_file.error_msg(errnum);
        }
    }

//    property var jsonIo: BpoJsonIo {id: jsonIo}

    /////////////////////////////////////////
    // This section checks the existance of writable file directories.
    // It is used at the start of execution and logs any problems.

    function check_writable_dir() {
        // Check if writable directory exists; writable_dir_count set in main.cpp.
        if (writable_dir_count == 0) {
            log.addMessage("(C) Directory " + Pathjs.writable_basepath
                           + " does not exist."
                           + "\nYou may need to create it manually.");
            return;
        }
        log.addMessage("Writable data directory (" + writable_dir_count + "): "
                       + Pathjs.writable_basepath);

        the_folder.nameFilters = ["*"];
        the_folder.showDirs = true;
        the_folder.showOnlyReadable = false;
        the_folder.sortField = FolderListModel.Name;

        the_folder.onReady = _check_contents;
        the_folder.folder = Pathjs.writable_baseurl;
    }

    function _check_contents() {
        for (let i = 0; i<the_folder.count; i++) log.addMessage("Writable: " + the_folder.get(i, "filePath"));
        // check subdirectories
        file_util.pages_ok = _check_dir("pages");
        file_util.page_units_ok = _check_dir("page_units");
        file_util.annotations_ok = _check_dir("annotations");

//        // check connections file; if does not exist, put in an empty file.
//        let connections_file = Pathjs.connections_file_path;
//        let i_connections = the_folder.indexOf(Pathjs.connections_file_url);
//        if (i_connections < 0) {
//            the_folder.onReady = null;
//            the_folder.folder = the_folder.default_folder;
//            jsonIo.storeJson(connections_file, {});
//            if (jsonIo.fileError) {
//                file_util.connections_file_ok = false;
//                log.addMessage("(E) File " + connections_file
//                               + " does not exist and could not be created."
//                               + "\n    error: " + jsonIo.fileErrorMsg);
//            } else {
//                log.addMessage("(W) File " + connections_file
//                               + " does not exist; empty json object created.");
//            }
//        } else if (the_folder.isFolder(i_connections)) {
//                file_util.connections_file_ok = false;
//                log.addMessage("(E) File " + connections_file
//                               + " is a directory, not a writable file.");
//        }

        the_folder.onReady = null;
        the_folder.folder = the_folder.default_folder;

        log.addMessage("Status: pages: " + (pages_ok? "OK" : "ERR")
                       + ", page_units: " + (page_units_ok? "OK" : "ERR")
                       + ", annotations: " + (annotations_ok? "OK" : "ERR")
                       + ", connections file: " + (connections_file_ok? "OK" : "ERR")
                       );
    }

    function _check_dir(dirnm) {
        let dir_ok = true;
        let i_ = the_folder.indexOf(Pathjs.writable_baseurl + dirnm);
        if (i_ < 0) {
            dir_ok = false;
            log.addMessage("(E) Directory " + Pathjs.writable_basepath + dirnm
                           + " does not exist.");
        } else if (!the_folder.isFolder(i_)) {
            dir_ok = false;
            log.addMessage("(E) File " + Pathjs.writable_basepath + dirnm
                           + " is not a directory.");
        }
        log.addMessage("Dir "+dirnm+" is "+(dir_ok? "OK" : "ERR"));
        return dir_ok;
    }

    //////////////////////////////////////////
    // This sections contains general file check, list, access and delete routines.
    // Dualfiles are file sets that deploy in the readonly_file recource collection
    // and may be updated or extended by the user with new files stored in the writable
    // file folder.  The current dualfiles are "connections.json", "page_units/*.json",
    // "pages/*.qml" and "annotations/*.json".
    // The readonly url is "qrc:/readonly/[subpath/]<file name>".  Readonly files are
    // accessed using XMLHttpRequest.
    // The writable url is "file:<system determined writable location>/[subpath/]<file name>".
    // The subpath should not begin with, but should end with a "/".
    //
    // As an addition, "get_dualfile" will support reading qml files from the deployed
    // system.  These are detected by a subpath beginning "Bsi", usually "BsiBaseUnits"
    // or "BsiSystemPages".
    //

    function get_filelist(url, filter, callback) {
        the_folder.onReady = function()
        {
            the_folder.onReady = null;
            let files = [];
            for (let i=0; i<the_folder.count; i++) files.push(the_folder.get(i, "fileName"));
            the_folder.folder = the_folder.default_folder;
            callback(files);
        }

        the_folder.showDirs = false;
        the_folder.showOnlyReadable = true;
        the_folder.sortField = FolderListModel.Name;
        the_folder.nameFilters = filter;
        the_folder.folder = url;
    }

    function get_dualfile_list(subpath, filter, callback) {
        let readonly_url = Pathjs.readonly_baseurl + subpath;
        let writable_url = Pathjs.writable_baseurl + subpath;
        var readonly_list, writable_list;
        get_filelist(readonly_url, filter, function(list) {
            readonly_list = list;
            if (subpath.startsWith("Bsi")) {
                readonly_list.sort();
                callback(readonly_list);
                return;
            }

            get_filelist(writable_url, filter, function(list) {
                writable_list = list;
                let merged_list = writable_list.concat(
                        readonly_list.filter((item)=> writable_list.indexOf(item) < 0));
                merged_list.sort();
                callback(merged_list);
                            });
        });
    }

    function get_dualfile(subpath) {
        var text;
        if (subpath.startsWith("Bsi")) {
            // This is a system qml file.
            // The system files are not writable (not dual).
            text = get_qml_file(subpath);
        } else {
            // This is a potentially dynamic file.  It can be updated
            // within the interface.  When that happens the updated
            // file is stored in the writable directory.
            // We check for a writable file first because it represents an
            // update or addition to deployed readonly files.
            text = get_writable_file(subpath);
            if (text === null) text = get_readonly_file(subpath);
        }

        let sample = text.substr(0,20).replace(/\n/g, "");
        console.log("FileUtil.get_dualfile subpath=" + subpath + " text length=" + text.length + " start=" + sample);
        return text;
    }

    function get_qml_file(subpath) {
        let url = "qrc:/" + subpath;
        return get_resource_file(url);
    }

    function get_readonly_file(subpath) {
        let url = Pathjs.readonly_baseurl + subpath;
        return get_resource_file(url);
    }

    function get_resource_file(url) {
        fileError = 0;
        fileErrorMsg = "";
        var xhr = new XMLHttpRequest;
        try {
            xhr.open("GET", url, /*async*/false);
            xhr.send();
        } catch (e) {
            fileErrorMsg = "Readonly file '"+url+"' access error: " + e.message;
            fileError = -1;
            return null;
        }

        if (xhr.status === 200) {
            return xhr.responseText;
        } else {
            fileError = xhr.status;
            fileErrorMsg = "Readonly file '"+url+"' request error " + xhr.status
                    + ".  See https://developer.mozilla.org/en-US/docs/Web/HTTP/Status";
            return null;
        }
    }

    function get_writable_file(subpath) {
        fileError = 0;
        fileErrorMsg = "";
        let path = Pathjs.writable_basepath + subpath;
        writable_file.set_path(path);
        let text = writable_file.read();
        if (writable_file.error) {
            fileErrorMsg = "Writable file '"+subpath+ "' read: " + fileErrorMsg;
            fileError = 1;
            return null;
        }
        return text;
    }

    function put_writable_file(subpath, text) {
        fileError = 0;
        fileErrorMsg = "";
        let path = Pathjs.writable_basepath + subpath;
        writable_file.set_path(path);
        writable_file.write(text);
        if (writable_file.error) {
            fileErrorMsg = "Writable file '"+subpath+"' write: " + fileErrorMsg;
            fileError = 1;
            return;
        }
        signal_change(subpath);
    }

    function remove_writable_file(subpath) {
        fileError = 0;
        fileErrorMsg = "";
        let path = Pathjs.writable_basepath + subpath;
        writable_file.set_path(path);
        if (!writable_file.remove()) {
            fileErrorMsg = "Writable file '"+subpath+"' could not be removed";
            fileError = 4;
            return 1;
        }
        signal_change(subpath);
        return 0;
    }

    function signal_change(subpath) {
        if (subpath.startsWith(Pathjs.page_basesubpath)) pagesUpdated(subpath);
        if (subpath.startsWith(Pathjs.page_unit_basesubpath)) pageUnitsUpdated(subpath);
    }
}
