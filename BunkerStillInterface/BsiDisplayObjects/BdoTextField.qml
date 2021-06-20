import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: bdsTextField

    property int borderwidth: 0

    implicitHeight: global.textHeight
    verticalAlignment: Text.AlignVCenter

    leftPadding: 5
    font.pointSize: 10
    font.family: "Veranda"
    color: global.textColor

    background: Rectangle {
        color: global.textBgColor
        border.color: global.textBorderColor
        border.width: borderwidth
    }

    onReadOnlyChanged: function(ro) {
        if (ro) {
            background.color = "transparent";
            background.border.color = "transparent";
        } else {
            background.color = global.textBgColor;
            background.border.color = global.textBorderColor;
        }
    }
}
