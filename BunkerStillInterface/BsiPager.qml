import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0

import "javascript/page_creator.js" as PageCreator

Rectangle {
    id: pager

    property string displayed_page: ""
    property var pages: ({})

    // pager stores page units for page editor
    // to make it available to sub-pages of editor.
    property string page_unit_name: ""
    property var page_unit_model: null

    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    ScrollView {
        clip: true
        anchors.fill: parent
        objectName: "pager-scrollview"
        padding: 2

        RowLayout {
            id: page_display
            objectName: "pager-item"
            // Pages added here so that ScrollView has only one child
        }
    }

    Connections {
        target: status_banner
        function onCurrent_page_fileChanged() {
            log.addMessage("Pager loading '"+status_banner.current_page_file[0]+"'");
            let page_file = status_banner.current_page_file[0];
            let page_timestamp = status_banner.current_page_file[1];
            if (!page_file) return;

            let page_entry = pages[page_file];
            if (!page_entry) {
                page_entry = pages[page_file] = {"file": page_file, "date": page_timestamp, "page": null};
            }
            if (!page_entry.page || page_entry.date && page_entry.date !== page_timestamp) {
                // need to generate a new page
                page_entry.date = page_timestamp;
                if (page_entry.page) {
                    page_entry.page.destroy();
                    page_entry.page = null;
                }

                let prior_page = displayed_page? pages[displayed_page].page : null;
                PageCreator.createPageObject(page_entry, prior_page);
            } else {
                // show the existing page
                pages[displayed_page].page.visible = false;
                page_entry.page.visible = true;
                displayed_page = page_entry.file;
            }
        }
    }
}
