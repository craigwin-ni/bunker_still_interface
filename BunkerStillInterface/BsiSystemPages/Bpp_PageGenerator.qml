import QtQuick 2.15
import QtQuick.Controls 2.15
import "../BsiDisplayObjects"
import "../javascript/page_editor.js" as Peditjs

Item {
    id: page_generator

    property var page_unit_model
    property var root_unit
    property var unresolved

    onVisibleChanged: {
        if (visible) {
            // This indicated the user has entered a page generator session.
            page_unit_model = pager.page_unit_model;
            root_unit = page_unit_model.get_page_unit(pager.page_unit_name);
            // do deep update and get unresolved standins
            Peditjs.updatePageUnitStandins(root_unit, true);
            unresolved = Peditjs.extractStandins(root_unit);
            assignment_lists.assignments_owner = unresolved;
        }
    }

    BdoPuAssignments {
        id: assignment_lists
        indent: 1
        title: "Unresolved Standins"
        showHide: false
    }


}
