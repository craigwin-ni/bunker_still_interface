import QtQuick 2.15
import "../BsiDisplayObjects"

Column {
    BdoComponentSelector {
        id: selector

        property var component: null

        function update_value() {
            data_field.text = component.getValueText();
        }

        onSelected_nameChanged: {
            component = componentStore.get_component(selected_name);
            label_field.text = component.name;
            data_field.text = component.getValueText();
            component.onValueChanged.connect(update_value);
        }
    }
    BdoTextField {
        id: label_field
        readOnly: false
    }
    Text {
        id: data_field
    }
}
