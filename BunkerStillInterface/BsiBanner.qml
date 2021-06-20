import QtQuick 2.15
import QtQuick.Controls 2.15
import "./BsiDisplayObjects"

Rectangle {
    id: banner

    readonly property alias connected_still: connectionSelector.connected_still
             property alias requested_page: pageSelector.requested_page
    readonly property alias current_page: pageSelector.current_page
    readonly property alias current_page_file: pageSelector.current_page_file

    implicitHeight: 54
    color: global.mainBgColor
    border.color: global.bulkTextBorderColor
    border.width: 2

    Row {
        padding: 2

        Column {
            BdoConnectionSelector {
                id: connectionSelector
                height: 25
            }
            BdoPageSelector {
                id: pageSelector
                height: 25
            }
        }

        BdoComponentSelector {
            id: componentSelector

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
        BdoTextField {
            id: data_field
        }
    }
}
