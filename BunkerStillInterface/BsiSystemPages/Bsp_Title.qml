import QtQuick 2.0

Rectangle {
    id: title_page

    height: parent.parent.height
    width: parent.parent.width
    color: global.mainBgColor
    border.color: global.bulkTextBorderColor
    border.width: 2

    Image {
        source: "../images/BunkerLogo.png"
        anchors.centerIn: parent
    }
}
