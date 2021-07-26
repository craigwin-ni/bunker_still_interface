import QtQuick 2.15
import Bunker 1.0

Flow {
    property var data_component
    property int precision: 4
    property alias label_field_text: label_field.text

    onData_componentChanged: {
        data_component.onValueChanged.connect(update_value);
    }

    function update_value() {
        if (data_component) {
            data_field.text = data_component.getValueText(precision);
        }
    }

    spacing: 5
    padding: 2

    Text {
        id: label_field

        height: data_field.height
        verticalAlignment: Text.AlignVCenter
        text: "unset property"
        font: Globals.label_font
    }
    Text {
        id: data_field

        verticalAlignment: Text.AlignVCenter
        text: "unset data"
        font: Globals.data_font
    }

}
