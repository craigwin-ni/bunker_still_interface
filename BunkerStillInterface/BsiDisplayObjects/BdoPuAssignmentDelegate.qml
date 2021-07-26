import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../javascript/name_util.js" as Nutiljs

Row {
    required property var assignment_0
    required property var assignment_1
    required property var assignment_2
    required property bool is_datas
    required property bool final_resolve
    property bool use_selector: is_datas && final_resolve

    height: 30
    width: 300

    property var verify_value: function (entered) {
        if (final_resolve) {
            if (Nutiljs.is_stand_in(entered.trim())) {
                log.addMessage("(E) Page final resolution cannot accept a stand-in");
                return false;
            }
            return true;
        }

        if (is_datas) {
            if (!Nutiljs.is_stand_in(entered.trim())) {
                log.addMessage("(E) Data element requires a stand-in");
                return false;
            }
        }
        return true;
    }

    BdoTextField {
        text: assignment_0 || "undefined";
        width: 100
        readOnly: true
    }

    BdoTextField {
        text: assignment_1 || "undefined";
        width: 120
        visible: !use_selector

        onEditingFinished: {
            text = text.trim();
            if (!verify_value(text)) {
                console.log("PuAssignmentDelegate: "+assignment_0+" value "+text+" Not verified.");
                text = assignment_1;
                return;
            }
            // 3rd parent is ListView; ListView.model is the AssignmentListModel for this datas_list
            // This statement updates the model's assignment list which is a reference to the
            // currently edited page_unit's list, thereby updating the actual list.
            parent.parent.parent.model.update_assignment(assignment_0, text);
        }
    }

    BdoComponentSelector {
        visible: use_selector
        text: "Still component"

        onSelected_nameChanged: {
            text = selected_name;
            parent.parent.parent.model.update_assignment(assignment_1, selected_name);
        }
    }

    BdoTextField {
        text: "(" + assignment_2 + ")"
        Layout.minimumWidth: 50
        readOnly: true
    }
}
