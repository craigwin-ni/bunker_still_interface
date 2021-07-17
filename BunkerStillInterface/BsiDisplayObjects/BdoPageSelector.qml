import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import Bunker 1.0

import "../javascript/page_util.js" as Putiljs

ComboBox {
    id: pageSelector

    property string requested_page: ""
    property string current_page: ""
    property var current_page_file: (["", null])  //page filename and modify date

    property var page_folder: FolderListModel {
        id: page_folder

        folder: Putiljs.page_baseurl
        showDirs: false
        showOnlyReadable: true
        sortField: FolderListModel.Name
        nameFilters: ["NoFileMatchesThis"]  // filter is set when a still is selected
    }

    Component.onCompleted: {
        load_selector_choices();
    }

    onActivated: {
        requested_page = editText;
    }

    onRequested_pageChanged: {
        if (!requested_page || requested_page === "") return;  // Allow to clear without processing
        let list = get_page_list();

        if (Putiljs.is_private_page(requested_page)) {
            current_page = requested_page;
            current_page_file = [Putiljs.system_page_url_from_name(current_page),
                                 null]
            return;
        }

        let index = list.indexOf(requested_page);
        if (index < 0) {
            requested_page = "";  // Clear
            log.addMessage("Error: requested page \"" + requested_page + "\" not available");
            return;
        }
        currentIndex = index;
        current_page = requested_page;

        index -= 1;  // Skip "Page" so that index matches index of page_folder contents.
        if (index < 0) {
            // the null "Page" selection
            current_page_file = [Putiljs.system_default_page_url,
                                 null];

        } else if (index >= page_folder.count) {
            // one of the system pages
            current_page_file = [Putiljs.system_page_url_from_name(current_page),
                                 null];

        } else {
            // a dynamic page generated into the file system
            current_page_file = [Putiljs.page_baseurl + page_folder.get(index, "fileName"),
                                 page_folder.get(index, "fileModified")];
        }
    }

    function get_page_list() {
        var page_list = ["Pages"];
        let page_count = page_folder.count;
        for (let i_page=0; i_page<page_count; i_page++) {
            let basename = page_folder.get(i_page, "fileBaseName");
            page_list.push(basename.substring(basename.lastIndexOf("_")+1));
        }
        page_list.push("Edit Connections");
        page_list.push("Edit Pages");
        page_list.push("Show Files");
        return page_list;
    }

    function load_selector_choices() {
        let list = get_page_list();
        let index = list.indexOf(current_page);
        model = list
        if (index < 0) {
            // The current page is no longer in the page folder
            currentIndex = 0;
            current_page = editText;
            current_page_file = [Putiljs.system_default_page_url,
                                 null];
        } else {
            currentIndex = index;
            if (index < page_folder.count) {
                // The current page is from the page folder.
                // Post the file modified date in case it changed.
                current_page_file = [Putiljs.page_baseurl + page_folder.get(index, "fileName"),
                                     page_folder.get(index, "fileModified")];
            } else {
                // The current page is one of the system editors.
                // There is nothing to update.
            }
        }
    }

    implicitHeight: 26
    implicitWidth: 180
    font.bold: true
    font.pointSize: 11
    font.family: "Arial"
    background: Rectangle {
        color: pageSelector.currentIndex===0? "lightgray" : Globals.textBgColor
        border.width: 2
        border.color: "grey"
        radius: 5
    }

    Connections {
        target: page_folder
        function onStatusChanged() {
            if (page_folder.status === FolderListModel.Ready) {
                load_selector_choices();
            }
        }
    }

    Connections {
        target: status_banner
        function onConnected_stillChanged() {
            page_folder.nameFilters = [Putiljs.page_file_from_name("*")]
            load_selector_choices();
            console.log("page_folder: folder " + page_folder.folder);
            console.log("page_folder: filter " + page_folder.nameFilters + ", count " + page_folder.count);
        }
    }
}

