import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import TextFile 1.0
import "../BsiDisplayObjects"
import "../BsiProcessObjects"
import "../javascript/page_editor.js" as Peditjs
import "../javascript/page_util.js" as Putiljs

Column {
    id: page_generator

    property var root_unit

    onVisibleChanged: {
        if (visible) {
            // This indicated the user has entered a page generator session.
            let page_unit_model = pager.page_unit_model;
            let still = status_banner.connected_still;
            if (!still) {
                log.addMessage("(C) PageGenerator entered without still connection.");
                status_banner.requested_page = "Edit Pages";
                return;
            }
            root_unit = page_unit_model.get_page_unit(pager.page_unit_name);
            if (!root_unit) {
                log.addMessage("(E) PageGenerator: page unit '" + pager.page_unit_name
                               + "' could not be found");
                status_banner.requested_page = "Edit Pages";
                return;
            }

            // do deep update and get unresolved standins
            Peditjs.updatePageUnitStandins(root_unit, true);
            let unresolved = Peditjs.extractStandins(root_unit);

            // merge in prior resolutions and present to user
            if (!root_unit.resolutions) root_unit.resolutions = {};
            if (!root_unit.resolutions[still]) root_unit.resolutions[still] = unresolved;
            Peditjs.mergeStandins(root_unit.resolutions[still].datas, unresolved.datas);
            Peditjs.mergeStandins(root_unit.resolutions[still].props, unresolved.props);
            assignment_lists.assignments_owner = root_unit.resolutions[still];
        }
    }

    function check_for_annotated_image(page_unit) {
        if (page_unit.base_unit_name !== "ImagePage") return null;
        let annotations = null;
        let image_name = null;
        let props = page_unit.props;
        for (let i_ = 0; i_<props.length; i++) {
            if (props[i_][0] === "<image_name>") {
                image_name = props[i_][1];
                break;
            }
        }
        if (image_name) {
            let annotation_path = Putiljs.writable_basepath + "annotations/" + image_name + ".json";
            annotations = jsonIo.loadJson(annotation_path, false);
            if (jsonIo.jsonError && jsonIo.jsonError != 5) {
                log.addMessage("(E) Image annotations: "+jsonIo.jsonErrorMsg);
            }

            console.log("PageGenerator.check_for_annotated_image path="+annotation_path
                        +"\nannotations="+JSON.stringify(annotations, 0, 2));
            console.log("       error msg: "+jsonIo.jsonErrorMsg);
        } else {
            log.addMessage("(E) ImagePage unit without an image_name property.");
        }

        return annotations;
    }

    BpoJsonIo {id: jsonIo}

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
                let page_unit_model = pager.page_unit_model;
                let still = status_banner.connected_still;
                let resolutions = root_unit.resolutions[still];
                page_unit_model.put_page_unit(root_unit);  // save resolutions
                let root_unit_copy = JSON.parse(JSON.stringify(root_unit));
                Peditjs.resolve_page_unit(root_unit_copy, resolutions);  // update unit solely for this processing
                let annotations = check_for_annotated_image(root_unit_copy);

                // Generate page QML; pagegen will check that all standins are resolved.
                let page_name = root_unit.name;  // XXX need to accept different name
                let page_text = Peditjs.pagegen(root_unit, root_unit.resolutions[still], page_name, annotations);
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
