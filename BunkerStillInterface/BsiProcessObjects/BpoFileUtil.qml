import QtQuick 2.0
import Qt.labs.folderlistmodel 2.15
import Qt.labs.platform 1.1
import "../javascript/page_util.js" as Putiljs

QtObject {
    id: file_util

    property bool writable_folder_ok: true
    property bool pages_ok: true
    property bool page_units_ok: true
    property bool connections_file_ok: true

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

    property var jsonIo: BpoJsonIo {id: jsonIo}

    function check_writable_dir() {
        // Check if writable directory exists
        if (writable_dir_count == 0) {
            log.addMessage("(C) Directory " + Putiljs.writable_basepath
                           + " does not exist."
                           + "\nYou may need to create it manually.");
            return;
        }
        log.addMessage("Writable data directories (" + writable_dir_count + "): "
                       + Putiljs.writable_basepath);

        the_folder.onReady = _check_contents;
        the_folder.folder = Putiljs.writable_baseurl;
    }

    function _check_contents() {
        // check subdirectories
        let i_pages = the_folder.indexOf(Putiljs.writable_baseurl + "pages");
        if (i_pages < 0) {
            file_util.pages_ok = false;
            log.addMessage("(E) Directory " + Putiljs.writable_baseurl + "pages"
                           + " does not exist.");
        } else if (!the_folder.isFolder(i_pages)) {
            file_util.pages_ok = false;
            log.addMessage("(E) File " + Putiljs.writable_baseurl + "pages"
                           + " is not a directory.");
        }

        let i_page_units = the_folder.indexOf(Putiljs.writable_baseurl + "page_units");
        if (i_page_units < 0) {
            file_util.page_units_ok = false;
            log.addMessage("(E) Directory " + Putiljs.writable_baseurl + "page_units"
                           + " does not exist.");
        } else if (!the_folder.isFolder(i_page_units)) {
            file_util.page_units_ok = false;
            log.addMessage("(E) File " + Putiljs.writable_baseurl + "page_units"
                           + " is not a directory.");
        }

        // check connections file; if does not exist, put in an empty file.
        let i_connections = the_folder.indexOf(Putiljs.connections_file_url);
        if (i_connections < 0) {
            the_folder.onReady = null;
            the_folder.folder = the_folder.default_folder;
            jsonIo.storeJson(Putiljs.connections_file_path, {});
            if (jsonIo.jsonError) {
                file_util.connections_file_ok = false;
                log.addMessage("(E) File " + Putiljs.connections_file_path
                               + " does not exist and could not be created."
                               + "\n    error: " + jsonIo.jsonErrorMsg);
            } else {
                log.addMessage("(W) File " + Putiljs.connections_file_path
                               + " does not exist; empty json object created.");
            }
        } else if (the_folder.isFolder(i_connections)) {
                file_util.connections_file_ok = false;
                log.addMessage("(E) File " + Putiljs.connections_file_path
                               + " is a directory, not a writable file.");
        }

        the_folder.onReady = null;
        the_folder.folder = the_folder.default_folder;
    }
}
