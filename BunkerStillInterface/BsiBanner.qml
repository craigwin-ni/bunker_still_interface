import QtQuick 2.15
import QtQuick.Controls 2.15
import "./BsiDisplayObjects"
import Bunker 1.0

Rectangle {
    id: banner

    readonly property alias connected_still: connectionSelector.connected_still
             property alias requested_page: pageSelector.requested_page
    readonly property alias current_page: pageSelector.current_page
    readonly property alias current_page_file: pageSelector.current_page_file

    property string status_page_name: ""
    property var status_page_parent: status_data_slot  // used as parent for status_data_page
    property var status_page

    implicitHeight: 54
    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    Connections {
        target: mqtt
        function onConnectedChanged(connected) {
            if (mqtt.connected) {
                status_page_name = "status_row";
            } else {
                status_page_name = "";
            }
        }
    }

    onStatus_pageChanged: {
        if (status_page) {
            status_page.x = selector_column.x + selector_column.width + 5;
            status_page.height = banner.implicitHeight;
            status_page.width = banner.implicitWidth = status_page.x;
        }
    }

    Row {
        id: status_banner_row

        padding: 2

        Column {
            id: selector_column
            BdoConnectionSelector {
                id: connectionSelector
                height: 25
            }
            BdoPageSelector {
                id: pageSelector
                height: 25
            }
        }

        Item {
            id: status_data_slot
        }
    }
}
