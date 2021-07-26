import QtQuick 2.15
import Bunker 1.0

Rectangle {
    id: title_page

    implicitHeight: bunker_logo.height
    height: page_scrollview.height
    width: page_scrollview.width
    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    Image {
        id: bunker_logo
        source: "../images/BunkerLogo.png"
        anchors.centerIn: parent
    }
}
