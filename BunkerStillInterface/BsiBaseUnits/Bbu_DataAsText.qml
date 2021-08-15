import QtQuick 2.15
import Bunker 1.0

Flow {
    property var data_component
    property int precision: 4
    property int label_width: 50
    property bool stacked: false
    property alias label_field_text: label_field.text
    property string label_align: "left"  // "left", "right", "center"
    property string data_align: "left"  // "left", "right", "center"

    onData_componentChanged: {
        if (data_component) {
            data_component.onValueChanged.connect(update_value);
            first_read_timer.running = true;
        }
    }

    function update_value() {
        if (data_component) {
            data_field.text = data_component.getValueText(precision);
        }
    }

    onLabel_alignChanged: {
        switch (label_align) {
        case "right": label_field.horizontalAlignment = TextInput.AlignRight; break;
        case "center": label_field.horizontalAlignment = TextInput.AlignHCenter; break;
        default: label_field.horizontalAlignment = TextInput.AlignLeft; break;
        }
    }
    onData_alignChanged: {
        switch (input_align) {
        case "right": data_field.horizontalAlignment = TextInput.AlignRight; break;
        case "center": data_field.horizontalAlignment = TextInput.AlignHCenter; break;
        default: data_field.horizontalAlignment = TextInput.AlignLeft; break;
        }
    }

    spacing: stacked? 1:5
    padding: 1
    width: stacked? Math.max(label_field.width, data_field.implicitWidth) :
                    label_field.width + data_field.implicitWidth + 10

    Timer {
        id: first_read_timer

        property int restart_count: 0

        interval: 5000
        onTriggered: {
            update_value();
            interval += 5000;
            restart_count += 1;
            if (restart_count <= 10) restart();
        }
    }

    Text {
        id: label_field

        visible: text
        height: data_field.height
        width: label_width
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
