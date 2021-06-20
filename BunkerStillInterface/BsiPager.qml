import QtQuick 2.0
import QtQuick.Controls 2.15

import "javascript/page_creator.js" as PageCreator

Rectangle {
    id: pager

    property string displayed_page: ""
    property var pages: ({})

    color: global.mainBgColor
    border.color: global.bulkTextBorderColor
    border.width: 2

    ScrollView {
        clip: true
        anchors.fill: parent
        objectName: "pager-scrollveiw"

        Item {
            id: page_display
            objectName: "pager-item"
            // Pages added here so that ScrollView has only one child
        }
    }

    Connections {
        target: status_banner
        function onCurrent_page_fileChanged() {
            console.log("Pager sees new page '"+status_banner.current_page_file[0]+"'");
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

                console.log("page entry: "+JSON.stringify(page_entry));
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
