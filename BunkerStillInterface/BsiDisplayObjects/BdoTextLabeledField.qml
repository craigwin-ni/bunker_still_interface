import QtQuick 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0


RowLayout {
    id: bdo_text_labeled_field

    property alias label_text: label.text
    property alias label_width: label.minimumWidth
    property alias label_size: label.pointSize
    property alias label_bold: label.bold

    property alias input_text: input.text
    property alias input_width: input.minimumWidth
    property alias input_size: input.pointSize
    property alias input_bold: input.bold

    property int field_height: Globals.label_text_height
    property alias read_only: input.readOnly

    signal input_ready()

    Component.onCompleted: {
        input.editingFinished.connect(input_ready);
    }

    BdoTextField {
        id: label

        property int minimumWidth: 50
        property int pointSize: Globals.label_font.pointSize
        property bool bold: false

        readOnly: true
        font.pointSize: pointSize
        font.bold: bold
        implicitHeight: bdo_text_labeled_field.field_height
        Layout.minimumWidth: minimumWidth
    }
    BdoTextField {
        id: input

        property int minimumWidth: 50
        property int pointSize: Globals.data_font.pointSize
        property bool bold: false

        readOnly: false
        font.pointSize: pointSize
        font.bold: bold
        implicitHeight: bdo_text_labeled_field.field_height
        Layout.minimumWidth: minimumWidth
    }
}
