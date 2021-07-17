import QtQuick 2.0
import "../BsiProcessObjects"
import "../javascript/page_editor.js" as Peditjs

Item {
    id: delegateItem

    required property string name
    required property var page_unit

    height: 30
    width: 500
    visible: true

    Row {
        anchors.fill: parent

        BdoTextLabeledField {
            label_width: 150
            label_text: name + " (" + page_unit.base_unit_name + ")"
            input_width: 200
            input_text: page_unit.description
            read_only: true
        }
        BdoButton_Letter {
            text: "E"
            onClicked: {
                pager.page_unit_name = page_unit.name
                status_banner.requested_page = "Bpp_PageUnitEditor"
            }
        }

        Text {text: " "}

        BdoButton_Letter {
            text: "P"
            onClicked: {
                let still_name = status_banner.connected_still;
                if (!still_name) {
                    log.addMessage("(E) PageGenerator cannot start: no still is selected.")
                    return;
                }
                if (!mqtt.connected) {
                    log.addMessage("(E) PageGenerator cannot start: connection to "
                                   + still_name + " is down.");
                    return;
                }

                pager.page_unit_name = page_unit.name
                status_banner.requested_page = "Bpp_PageGenerator"
            }
        }

        Text {text: " "}

        BdoButton_Delete {
            id: delete_button
            check_name: name
            onVerified: {
                pager.page_unit_model.remove_page_unit(name);
            }
        }
    }
}
