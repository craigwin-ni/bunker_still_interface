import QtQuick 2.15
import "../javascript/page_editor.js" as Peditjs
Row {
    required property var assignment_0
    required property var assignment_1
    required property var assignment_2
    required property bool is_datas

    height: 30
    width: 300

    function verify_value(entered) {
        if (is_datas) {
            if (!Peditjs.stand_in_re.test(entered.trim())) return false;
        }
        return true;
    }

    BdoTextLabeledField {
        label_text: assignment_0 || "undefined";
        input_text: assignment_1 || "undefined";

        label_width: 120
        input_width: 150

        onInput_ready: {
            let text = input_text.trim();
            if (!verify_value(text)) {
                log.addMessage("Invalid assignment resolution for '" + assignment_0 + ": " + text);
                input_text = assignment_1;
                return;
            }
            // 3rd parent is ListView; ListView.model is the AssignmentListModel for this datas_list
            // This statement updates the model's assignment list which is a reference to the
            // currently edited page_unit's list, thereby updating the actual list.
            parent.parent.parent.model.update_assignment(assignment_0, text);
        }
    }
}
