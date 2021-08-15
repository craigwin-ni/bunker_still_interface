import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

Rectangle {
    property alias text: bulk_text.text
    property alias text_width: bulk_text.width

    function scroll_to_bottom() {
        text_scroll.contentItem.contentY = bulk_text.height - height;
    }

    color: Globals.bulkTextBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    ScrollView {
        id: text_scroll

        clip: true
        anchors.fill: parent
        contentWidth: availableWidth

        Text {
            id: bulk_text

            width: parent.width
            wrapMode: Text.Wrap
            color: Globals.bulkTextColor
            padding: 3
            font: Globals.label_font
        }
    }
}

