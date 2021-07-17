import QtQuick 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0

Item {
    id: pu_child_delegate

    required property int child_index
    property var childs: page_unit_editor.edit_unit.childs
    property var thisChild: childs && childs[child_index]? childs[child_index] : {"unit_name":"N/A"}

    width: 300
    height: child_unit_name.height + 6

    Component.onCompleted: {
        child_listView.height += child_row.height;
    }
    Component.onDestruction: {
        child_listView.height -= child_row.height;
    }

    Row {
        id: child_row
        BdoButton_ShowHide {
            onVisibilityChanged: {
                if (visibility) {
                    child_assignments.visible = visibility;
                    child_listView.height += (child_assignments.height+30);
                    pu_child_delegate.height += (child_assignments.height+30);
                } else {
                    child_listView.height -= (child_assignments.height+30);
                    pu_child_delegate.height -= (child_assignments.height+30);
                    child_assignments.visible = visibility;
                }
            }
        }
        Text {
            id: child_unit_name
            text: thisChild.unit_name
            font: Globals.subtitle_font
            width: 150
        }

        BdoButton_MoveUpDown {
            onMoveUp: {
                if (child_index > 0) {
                    // remove `from` item and store it
                    var c = childs.splice(child_index, 1)[0];
                    // insert stored item into position `to`
                    childs.splice(child_index-1, 0, c);
                    child_listModel.move(child_index, child_index-1, 1);
                    child_listModel.update_model();
                }
            }
            onMoveDown: {
                if (child_index < child_listModel.count-1) {
                    // remove child item and store it
                    var c = childs.splice(child_index, 1)[0];
                    // insert stored item
                    childs.splice(child_index+1, 0, c);
                    child_listModel.move(child_index, child_index+1, 1);
                    child_listModel.update_model();
                }
            }
        }

        Text {text: " "}

        BdoButton_Letter {
            text: "E"
            onClicked: {
                page_unit_editor.reenter_editor(thisChild.unit_name);
            }
        }

        Text {text: " "}

        BdoButton_Delete {
            id: delete_button

            check_name: "child #" + (child_index+1)
            onVerified: {
                childs.splice(child_index, 1);
                child_listModel.update_model();
            }
        }
    }

    BdoPuAssignments {
        id: child_assignments

        y: 50
        title: ""
        visible: false
        assignments_owner: thisChild
        indent: 1
    }
}
