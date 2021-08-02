import QtQuick 2.15
import QtQuick.Controls 2.15
import TextFile 1.0
import "../BsiDisplayObjects"
import "../javascript/page_editor.js" as Peditjs
import "../javascript/page_util.js" as Putiljs

Column {
    id: page_generator

    property var page_unit_model
    property var root_unit
    property var unresolved

    onVisibleChanged: {
        if (visible) {
            // This indicated the user has entered a page generator session.
            page_unit_model = pager.page_unit_model;
            root_unit = page_unit_model.get_page_unit(pager.page_unit_name);
            if (!root_unit) {
                log.addMessage("(E) PageGenerator: page unit '" + pager.page_unit_name
                               + "' could not be found");
                status_banner.requested_page = "Edit Pages";
                return;
            }

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
        final_resolve: true
    }

    TextFile {
        id: pagefile

        onErrorChanged: {
            if (error) {
                let msg = error_msg(errnum);
                log.addMessage("(E) Error writing page file " + path + ": " + msg);
            }
        }
    }

    Row {
        id: button_row

        BdoButton_Text {
            text: "Continue"

            onClicked: {
                // pagegen will check that all standins are resolved.
                let page_name = root_unit.name;  // XXX need to accept different name
                let page_text = Peditjs.pagegen(root_unit, unresolved, page_name);
                if (!page_text) return;
                // save page text in pages folder.
                pagefile.path = Putiljs.page_path_from_name(page_name);
                if (!pagefile.path) return;
                pagefile.write(page_text);
                if (pagefile.error) return;

                status_banner.requested_page = "Edit Pages";
            }
        }
        BdoButton_Text {
            text: "Cancel"

            onClicked: {
                status_banner.requested_page = "Edit Pages";
            }
        }
    }
}
