import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import Bunker 1.0
import "../BsiDisplayObjects"
import "../BsiProcessObjects"
import "../javascript/page_editor.js" as Peditjs
import "../javascript/name_util.js" as Nutiljs

ColumnLayout {
    id: page_unit_editor

    property var edit_unit: null
    property var pu_stack: []
    property int label_width: 100
    property var page_unit_model: pager.page_unit_model

    onVisibleChanged: {
        if (visible) {
            // This indicated the user has entered a page unit edit session.
            page_unit_model = pager.page_unit_model;
            edit_unit = page_unit_model.get_page_unit(pager.page_unit_name);
            if (!edit_unit) {
                log.addMessage("(E) PageUnitEditor cannot initial-load page unit '"
                               +pager.page_unit_name+"'");
            }

            // deep update on entry to editing session
            Peditjs.updatePageUnitStandins(edit_unit, true);
            init_editor();
        }
    }

    function init_editor() {
        name_field.input_text = edit_unit.name;
        description_field.input_text = edit_unit.description;
        base_unit_selector.currentIndex = page_unit_model.bu_list.indexOf(edit_unit.base_unit_name);
        page_unit_selector.model = page_unit_model.pu_list;
        page_unit_selector.currentIndex = -1;
        child_listModel.page_unit = edit_unit;
        assignment_lists.assignments_owner = edit_unit;
    }

    function reenter_editor(next_page_unit_name) {
        // editing a child page unit
        pu_stack.push(edit_unit);
        child_listModel.clear();
        child_listView.forceLayout();
        edit_unit = page_unit_model.get_page_unit(next_page_unit_name);
        if (!edit_unit) {
            log.addMessage("(E) PageUnitEditor cannot reenter-load page unit '"
                           +pager.page_unit_name+"'");
        }
        init_editor();
    }

    function exit_editor() {
        if (pu_stack.length === 0) {
            // exiting out of initial edit session
            status_banner.requested_page = "Edit Pages";
        } else {
            // popping up from a child edit session
            edit_unit = pu_stack.pop();
            // shallow update to load any changees from edited child
            Peditjs.updatePageUnitStandins(edit_unit, false);
            init_editor();
        }
    }

    function do_save_as(name) {
        if (name) {
            // Note: edit session will now be editing newly saved page+_unit.
            console.log("PageUnitEditor.do_save_as called with name '"+name+"'");
            edit_unit.name = name;
            name_field.input_text = name;
            page_unit_model.put_page_unit(edit_unit);
            console.log("PageUnitEditor: saveAs saving as '"+name+"'");
        }
        save_as_row.visible = false;
        button_row.visible = true;
    }

    function do_change_base_unit(delete_children) {
        if (delete_children) {
            delete edit_unit.childs;
            edit_unit.childs = undefined;
            child_listModel.update_model();
            children_section.visible = false;
        }
        let base_unit_name = base_unit_selector.editText;
        let new_base = page_unit_model.get_base_unit(base_unit_name);
        edit_unit.base_unit_name = base_unit_name;
        Peditjs.mergeStandins(edit_unit.datas, new_base.datas);
        Peditjs.mergeStandins(edit_unit.props, new_base.props);
    }

//    padding: 3
    anchors.margins: 3
    spacing: 5

    BpoPuChildListModel {id: child_listModel}

    Component {
        id: child_delegate
        BdoPuChildDelegate {}
    }

    BdoDialog_Verify {
        id: verify_delete_children

        title: "Base Unit Without Children"
        dialog_text: "This base unit does not support children.\n\nDelete children and proceed?"
        parent: base_unit_selector

        onAccepted: {
            do_change_base_unit(true);
        }
        onRejected: {
            base_unit_selector.currentIndex = page_unit_model.bu_list.indexOf(edit_unit.base_unit_name);
        }
    }

    BdoDialog_Verify {
        id: verify_overwrite_page_unit

        title: "Page Unit Exists"
        dialog_text: "The page unit name already exists.\n\nReplace existing page unit?"
        parent: save_as_name_field
        y: -height

        onAccepted: {
            let name = save_as_name_field.input_text.trim();
            log.addMessage("(W) overwriting page unit '" + name
                           + "' (result=" + result + ")");
            console.log("(W) overwriting page unit '" + name + "'");
            do_save_as(name);
        }
        onRejected: {
            console.log("... overwrite rejected (result=" + result + ")");
            do_save_as("");
        }
    }

    BdoTextLabeledField {
        id: name_field

        label_text: "Page Unit: "
        label_size: Globals.title_font.pointSize
        input_size: Globals.title_font.pointSize
        input_bold: true
        read_only: true
        input_text: edit_unit? edit_unit.name : ""
        field_height: Globals.title_text_height
    }

    Text {text: " "}  // spacer

    BdoTextLabeledField {
        id: description_field

        label_width: page_unit_editor.label_width
        label_text: "Description: "
        input_width: 150

        onInput_ready: {
            edit_unit.description = input_text;
        }
    }

    Row {
        id: base_unit_row

        BdoTextField {
            text: "Base Unit: "
            implicitWidth: page_unit_editor.label_width + 5
            readOnly: true
            anchors.verticalCenter: parent.verticalCenter
        }
        ComboBox {
            id: base_unit_selector

            width: 150
            model: page_unit_model.bu_list

            onActivated: {
                console.log("base_unit_selector activated to "+editText);
                if (editText === edit_unit.base_unit_name) return;
                let new_base_name = editText;
                let new_base = page_unit_model.get_base_unit(new_base_name);
                if (!new_base) {
                    log.addMessage("(C) New base unit '" + new_base_name + "' not found.");
                    return;
                }

                if (new_base.childs && !edit_unit.childs) {
                    edit_unit.childs = [];
                    child_listModel.update_model();
                    children_section.visible = true;
                } else if (!new_base.childs && edit_unit.childs) {
                    // show dialog to confirm removal of children
                    verify_delete_children.open();
                    return;
                }
                do_change_base_unit(false);
            }
        }
    }

    BdoPuAssignments {
        id: assignment_lists
        indent: 1
        startClosed: false
    }

    Column {
        id: children_section

        leftPadding: Globals.indent_step * 2
        visible: (edit_unit && edit_unit.childs) ? true : false

        Text {
            text: "Children"
            font: Globals.title_font
        }

        ListView {
            id: child_listView

            model: child_listModel
            delegate: child_delegate
            spacing: 2
            width: 300
        }

        // 'add child' selector and support
        Row {
            BdoButton_Text {
                id: add_child_button

                text: "Add Child"

                onClicked: {
                    console.log("Add Child button clicked");
                    page_unit_selector.visible = do_add_child.visible = !page_unit_selector.visible;
                }
            }
            ComboBox {
                id: page_unit_selector

                visible: false
                model: page_unit_model.pu_list;
            }
            BdoButton_Text {
                id: do_add_child

                visible: false
                text: "Add"
                onClicked: {
                    if (page_unit_selector.currentIndex < 0) {
                        log.addMessage("(W) PageUnitEditor.AddChild: no page_unit was selected.")
                        return;
                    }
                    Peditjs.add_page_unit_child(edit_unit, page_unit_selector.editText);
                    child_listModel.update_model();
                }
            }
        }
    }

    Text {text: " "}  // spacer

    Row {
        id: button_row

        visible: true
        spacing: 3

        BdoButton_Text {
            text: "Save"
            onClicked: {
                console.log("PU_Edit Save " + edit_unit.name);
//                console.log(".. saving page_unit:\n"+JSON.stringify(edit_unit, 0, 2));
                page_unit_model.put_page_unit(edit_unit);
                exit_editor();
            }
        }
        BdoButton_Text {
            text: "Save As"
            onClicked: {
                save_as_name_field.input_text = edit_unit.name;
                button_row.visible = false;
                save_as_row.visible = true;
            }
        }
        BdoButton_Text {
            text: "Cancel"
            onClicked: {
                console.log("PU_Edit Cancel");
                exit_editor();
            }
        }
    }
    Row {
        id: save_as_row

        visible: false

        BdoTextLabeledField {
            id: save_as_name_field

            label_text: "Save page as "
            label_width: 75
            input_width: 150

            onInput_ready: {
                if (!visible) return;
                let name = input_text.trim();
                console.log("PU_Edit Save As: " + edit_unit.name + " as " + name);
                console.log("PageUnitEditor.SaveAs: save page_unit '" + edit_unit.name
                            + "' as '"+name+"'");
                if (name) {
                    if (!Nutiljs.is_name(name)) {
                        log.addMessage("(E) Invalid page_unit name: '" + name + "'");
                        name = "";
                    } else if (page_unit_model.bu_list.indexOf(name) >= 0) {
                        log.addMessage("(E) Page unit name duplicates a base unit name: '" + name + "'");
                        name = "";
                    } else {
                        // check and show overwrite-dialog if save_as path exists
                        if (page_unit_model.pu_list.indexOf(name) >= 0) {
                            verify_overwrite_page_unit.open();
                            // dialog.onAccepted() will do_save_as().
                            return;
                        }
                    }
                }
                do_save_as(name);
            }
        }
    }
}
