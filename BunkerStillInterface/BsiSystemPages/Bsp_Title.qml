import QtQuick 2.15
import Bunker 1.0

Rectangle {
    id: title_page

    implicitHeight: bunker_logo.height
    height: page_scrollview.height -4
    width: page_scrollview.width -4
    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    Image {
        id: bunker_logo
        source: "../images/BunkerLogo.png"
        anchors.centerIn: parent
    }
}
