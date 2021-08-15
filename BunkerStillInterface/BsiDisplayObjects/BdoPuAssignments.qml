import QtQuick 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0
import "../imports/Bunker" 1.0
import "../BsiProcessObjects"

Column {
    id: assignments_editor

    property string title: "Assignments"
    property bool showHide: true;
    property bool startClosed: true;
    property bool final_resolve: false;
    property int indent: 0
    property var assignments_owner: null

    onAssignments_ownerChanged: {
        if (assignments_owner) {
            datas_model.assignments = assignments_owner.datas;
            props_model.assignments = assignments_owner.props;
        }
    }

    Component {
        id: assignmentDelegate
        BdoPuAssignmentDelegate {}
    }

    BpoPuAssignmentListModel {
        id: datas_model
        is_datas: true
        final_resolve: assignments_editor.final_resolve
    }

    BpoPuAssignmentListModel {
        id: props_model
        is_datas: false
        final_resolve: assignments_editor.final_resolve
    }

    RowLayout {
        visible: title
        Layout.leftMargin: Globals.indent_step*indent

        BdoButton_ShowHide {
            visible: showHide
            visibility: !startClosed
            onVisibilityChanged: {
                assignments_display.visible = visibility;
            }
        }

        Text {
            text: title
            font: Globals.title_font
        }
    }

    ColumnLayout {
        id: assignments_display

        visible: startClosed? !(title && showHide) : true

        ListView {
            id: datas_list

            implicitHeight: 30*datas_model.count
            Layout.leftMargin:  Globals.indent_step * (indent+1)
            delegate: assignmentDelegate
            model: datas_model
        }

        Rectangle {  // data/prop separator line
            Layout.leftMargin: 30
            implicitWidth: 250
            implicitHeight: 1
            color: "transparent"
            border.width: 1
            border.color: Globals.textBorderColor
        }

        ListView {
            id: props_list

            implicitHeight: 30*props_model.count
            Layout.leftMargin:  Globals.indent_step * (indent+1)
            delegate: assignmentDelegate
            model: props_model
        }
    }
}
