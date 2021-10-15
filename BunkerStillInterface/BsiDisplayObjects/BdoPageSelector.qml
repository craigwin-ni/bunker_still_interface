import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import Qt.labs.platform 1.1
import Bunker 1.0

import "../javascript/path_util.js" as Pathjs

ComboBox {
    id: pageSelector

    property var dynamic_page_list: []
    property string requested_page: ""
    property string current_page: ""
    property var current_page_file: (["", null])  //page filename and file modify date

//    property var page_folder: FolderListModel {
//        id: page_folder

//        property var onReady: null

//        folder: Pathjs.page_baseurl
//        showDirs: false
//        showOnlyReadable: true
//        sortField: FolderListModel.Name
//        nameFilters: ["NoFileMatchesThis"]  // filter is set when a still is selected

//        function refresh() {
//            // This forces page_folder to reload the files without affection list content.
//            // We do this to get the current file modified dates for Pager.
//            showDirs = !showDirs;
//        }
//    }

    Component.onCompleted: {
        load_selector_choices();
    }

    onActivated: {
        requested_page = editText;
    }

    onRequested_pageChanged: {
        if (!requested_page || requested_page === "") return;  // Allow to clear without processing
        let list = get_page_list();

        if (Pathjs.is_private_page(requested_page)) {
            current_page = requested_page;
            current_page_file = [Pathjs.system_page_subpath_from_name(current_page),
                                 null]
            return;
        }

        let index = list.indexOf(requested_page);
        if (index < 0) {
            log.addMessage("(E) requested page \"" + requested_page + "\" not available");
            requested_page = "";  // Clear
            return;
        }
        currentIndex = index;
        current_page = requested_page;

//        index -= 1;  // Skip "Page" so that index matches index of page_folder contents.
        if (index === 0) {
            // the null "Page" selection, show Title page.
            current_page_file = [Pathjs.system_default_page_subpath,
                                 null];

        } else if (index >= dynamic_page_list.length+1) {  // page_folder.count
            // one of the system pages
            current_page_file = [Pathjs.system_page_subpath_from_name(current_page),
                                 null];

        } else {
            // a dynamic page generated into the file
            current_page_file = [Pathjs.page_basesubpath + Pathjs.page_file_from_name(requested_page), // page_folder.get(index, "fileName"),
                                 null];// page_folder.get(index, "fileModified")
//            page_folder.onReady = function() {
//                // Create the current_page_file value after we have latest file modified date.
//                if (page_folder.count) {
//                    current_page_file = [Pathjs.page_basesubpath + page_folder.get(index, "fileName"),
//                                         page_folder.get(index, "fileModified")];
//                    page_folder.onReady = null;
//                }
//            }
//            page_folder.refresh();
        }
    }

    function get_page_list() {
        var page_list = ["Pages"].concat(dynamic_page_list);
//        let page_count = page_folder.count;
//        for (let i_page=0; i_page<page_count; i_page++) {
//            let basename = page_folder.get(i_page, "fileBaseName");
//            page_list.push(basename.substring(basename.indexOf("_")+1));
//        }
        page_list.push("Data Viewer");
        page_list.push("Edit Pages");
        page_list.push("Edit Connections");
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
            requested_page = editText;
        } else {
            currentIndex = index;
            if (index === 0 || index > dynamic_page_list.length+1) {  // page_folder.count
                // The current page is one of the system pages.
                // There is nothing to update.
            } else {
                // Index between 1 and 1+dynamic_page_list.length.  //page_folder.count.
                // The current page is from the page folder.
                // Post the file modified date in case it changed.
                // Increment index to account for position 0 filled with system default page.
                current_page_file = [Pathjs.page_basesubpath + Pathjs.page_file_from_name(current_page), // page_folder.get(index, "fileName"),
                                     null];
//                current_page_file = [Pathjs.page_basesubpath + page_folder.get(index+1, "fileName"),
//                                     page_folder.get(index+1, "fileModified")];
            }
        }
    }

    function update_dynamic_page_list() {
        fileUtil.get_dualfile_list(Pathjs.page_basesubpath,
                                   Pathjs.page_file_from_name("*"),
                                   function(list) {
                                       dynamic_page_list = list.map(file => Pathjs.page_name_from_file(file));
                                       load_selector_choices();
                                       if (model.indexOf("Index")>=0) requested_page = "Index";
                                   });
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

//    Connections {
//        target: page_folder
//        function onStatusChanged() {
//            if (page_folder.status === FolderListModel.Ready) {
//                if (page_folder.onReady) {
//                    page_folder.onReady();
//                } else {
//                    load_selector_choices();
//                }
//            }
//        }
//    }

    Connections {
        target: status_banner
        function onConnected_stillChanged() {
            update_dynamic_page_list();
        }
    }

    Connections {
        target: fileUtil
        function onPagesUpdated() {
            update_dynamic_page_list();
        }
    }

//            page_folder.onReady = function() {
//                load_selector_choices();
//                if (model.indexOf("Index")>=0) requested_page = "Index";
//            }
//            page_folder.nameFilters = [Pathjs.page_file_from_name("*")];
//        }
}

