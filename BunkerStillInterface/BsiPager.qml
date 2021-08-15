import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import TextFile 1.0
import Bunker 1.0

import "javascript/page_creator.js" as PageCreator
import "javascript/page_util.js" as Putiljs

Rectangle {
    id: pager

    property string displayed_page: ""
    property var pages: ({})
    property var banner_page: null
    property var current_page: null

    // pager stores page units for page editor
    // to make it available to sub-pages of editor.
    property string page_unit_name: ""
    property var page_unit_model: null

    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    ScrollView {
        id: page_scrollview

        clip: true
        anchors.fill: parent
        objectName: "pager-scrollview"
        padding: 2

        contentWidth: current_page? Math.max(pager.width-4, current_page.implicitWidth) : pager.width-4;
        contentHeight: current_page? Math.max(pager.height-4, current_page.implicitHeight) : pager.height-4;

        Item {
            id: page_display
            // Pages added here so that ScrollView has only one child
//            width: current_page.width
//            height: current_page.height
        }
    }

    TextFile {
        id: pagefile

        onErrorChanged: {
            if (error) {
                let msg = error_msg(errnum);
                log.addMessage("(E) Error reading page file '" + path + "': " + msg);
            }
        }
    }

//    onCurrent_pageChanged: {
//        if (current_page) {
//            console.log("Pager.onCurrent_pageChanged: current page width="+current_page.width
//                        +" implicit="+current_page.implicitWidth);
//            set_page_width();
//            set_page_height();
//            current_page.onWidthChanged.connect(set_page_width);
//            current_page.onHeightChanged.connect(set_page_height);
//            current_page.onImplicitWidthChanged.connect(set_page_width);
//            current_page.onImplicitHeightChanged.connect(set_page_height);
//        }
//    }

//    function set_page_width() {
//        if (current_page) {
//            page_scrollview.contentWidth = Math.max(pager.width-4, current_page.width, current_page.implicitWidth);
//        } else if (pager) {
//            page_scrollview.contentWidth = pager.width-4;
//        }
//    }
//    function set_page_height() {
//        if (current_page) {
//            page_scrollview.contentHeight = Math.max(pager.height-4, current_page.height, current_page.implicitHeight);
//        } else if (pager) {
//            page_scrollview.contentHeight = pager.height-4;
//        }
//    }

    Connections {
        target: status_banner
        function onStatus_page_nameChanged() {
            if (status_banner.status_page_name) {
                // create a page for the status banner to display
                if (banner_page) banner_page.destroy();
                let file_path = Putiljs.page_path_from_name(status_banner.status_page_name);
                let page_entry = {"file": file_path, "date": null, "page": null};
                PageCreator.createPageFromQml(page_entry, "", pagefile, status_banner.status_page_parent);
                banner_page = page_entry.page;
                status_banner.status_page = banner_page;
            } else {
                banner_page.destroy();
                banner_page = null;
                status_banner.status_page = null;
            }
        }

        function onCurrent_page_fileChanged() {
            log.addMessage("Pager showing '"+status_banner.current_page_file[0]+"'");
            let page_file = status_banner.current_page_file[0];
            let page_timestamp = status_banner.current_page_file[1];
            if (!page_file) return;

            let page_entry = pages[page_file];
            if (!page_entry) {
                page_entry = pages[page_file] = {"file": page_file, "date": page_timestamp, "page": null};
            }
            if (!page_entry.page || (page_entry.date && ""+page_entry.date != ""+page_timestamp)) {
                // need to create a new page
                log.addMessage("Pager creating page from file "+page_entry.file);
                page_entry.date = page_timestamp;
                if (page_entry.page) {
                    page_entry.page.destroy();
                    page_entry.page = null;
                }

                let prior_page = displayed_page? pages[displayed_page].page : null;
                if (page_entry.file.startsWith("qrc:")) {
                    PageCreator.createPageObject(page_entry, prior_page);
                } else {
                    PageCreator.createPageFromQml(page_entry, prior_page, pagefile);
                }
                current_page = page_entry.page;
            } else {
                // show the existing page
                if (displayed_page) pages[displayed_page].page.visible = false;
                page_entry.page.visible = true;
                displayed_page = page_entry.file;
                current_page = page_entry.page;
            }
        }
    }
}
