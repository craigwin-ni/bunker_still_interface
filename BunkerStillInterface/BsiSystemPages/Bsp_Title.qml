import QtQuick 2.0
import Bunker 1.0

Rectangle {
    id: title_page

    height: parent.parent.height
    width: parent.parent.width
    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    Image {
        source: "../images/BunkerLogo.png"
        anchors.centerIn: parent
    }
}
