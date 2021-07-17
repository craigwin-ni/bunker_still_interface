import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

TextField {
    id: bdo_text_field

    property int borderwidth: 0
    property int field_height: Globals.label_text_height
    property bool read_only: false

    implicitHeight: field_height
    readOnly: read_only
    verticalAlignment: Text.AlignVCenter

    leftPadding: 5
    color: Globals.textColor
    font: Globals.label_font  // (readOnly? Globals.label_font : Globals.data_font)

    background: Rectangle {
        color: readOnly? "transparent" : Globals.textInputBgColor
        border.color: Globals.textBorderColor
        border.width: borderwidth
    }
}
