import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: global.bulkTextBgColor
    border.color: global.bulkTextBorderColor
    border.width: 2

    property alias text: bulk_text.text

    function scroll_to_bottom() {
        text_scroll.contentItem.contentY = bulk_text.height - height;
    }

    ScrollView {
        id: text_scroll

        clip: true
        anchors.fill: parent

        contentWidth: availableWidth

        Text {
            id: bulk_text

            wrapMode: Text.Wrap
            color: global.bulkTextColor
            padding: 3
            font.pixelSize: 12
            font.family: "Verdana"
        }
    }
}

