import QtQuick 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0


RowLayout {
    id: bdo_text_labeled_field

    property alias label_text: label.text
    property alias label_width: label.minimumWidth
    property alias label_size: label.pointSize
    property alias label_bold: label.bold
    property string label_align: "left" // "left", "right", or "center"

    property alias input_text: input.text
    property alias input_width: input.minimumWidth
    property alias input_size: input.pointSize
    property alias input_bold: input.bold
    property string input_align: "left" // "left", "right", or "center"

    property int field_height: Globals.label_text_height
    property alias read_only: input.readOnly

    signal input_ready()

    Component.onCompleted: {
        input.editingFinished.connect(input_ready);
    }

    onLabel_alignChanged: {
        switch (label_align) {
        case "right": label.horizontalAlignment = TextInput.AlignRight; break;
        case "center": label.horizontalAlignment = TextInput.AlignHCenter; break;
        default: label.horizontalAlignment = TextInput.AlignLeft; break;
        }
    }
    onInput_alignChanged: {
        switch (input_align) {
        case "right": input.horizontalAlignment = TextInput.AlignRight; break;
        case "center": input.horizontalAlignment = TextInput.AlignHCenter; break;
        default: input.horizontalAlignment = TextInput.AlignLeft; break;
        }
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
