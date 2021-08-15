import QtQuick 2.15
import Qt.labs.folderlistmodel 2.15
import "../BsiBaseUnits"
import "../BsiProcessObjects"
import "../javascript/page_util.js" as Putiljs
import "../javascript/page_editor.js" as Peditjs

ListModel {
    property alias base_units: bu_index.base_units
    property var bu_list: Object.keys(base_units)
    property var pu_list: ([])
    property var page_units: ({})
    property var page_list: ([])

    property var jsonIo: BpoJsonIo {id: jsonIo}
    property var bu_index: BbuIndex {id: bu_index}

    property var pu_folder: FolderListModel {
        id: pu_folder

        folder: Peditjs.page_unit_baseurl
        showDirs: false
        showOnlyReadable: true
        sortField: FolderListModel.Name
        nameFilters: [Peditjs.page_unit_file_from_name("*")]
        caseSensitive: false

        signal puModelUpdated()

        onStatusChanged: {
            pu_list = [];
            page_units = {};
            clear();
            if (status === FolderListModel.Ready) {
                for (let i_pu=0; i_pu<pu_folder.count; i_pu++) {
                    let pu_name = Peditjs.page_unit_name_from_file(pu_folder.get(i_pu, "fileName"));
                    let page_unit = jsonIo.loadJson(Peditjs.page_unit_path_from_name(pu_name));
                    if (jsonIo.jsonError) {
                        log.addMessage("(E) PageUnit '" + pu_name + "': " + jsonIo.jsonErrorMsg);
                        continue;
                    }
                    page_units[pu_name] = JSON.parse(JSON.stringify(page_unit));
                    pu_list.push(pu_name);
                    append({"name": pu_name, "page_unit": page_unit});
                }
            }
            puModelUpdated()
        }
    }

    property var page_folder: FolderListModel {
        id: page_folder

        folder: Putiljs.page_baseurl
        showDirs: false
        showOnlyReadable: true
        sortField: FolderListModel.Name
        nameFilters: ["NoFilesMatchThis"]
        caseSensitive: false

        property var connections: Connections {
            target: status_banner
            function onConnected_stillChanged() {
                if (status_banner.connected_still) {
                    page_folder.nameFilters = [Putiljs.page_file_from_name("*")];
                }
            }
        }

        onStatusChanged: {
            page_list = [];
            if (status === FolderListModel.Ready) {
                if (status_banner.connected_still) {
                    for (let i_page=0; i_page<page_folder.count; i_page++) {
                        page_list.push(Peditjs.page_unit_name_from_file(page_folder.get(i_page, "fileName")));
                    }
                }
            }
        }
    }

    // this function is called by BdoListNameAdder

    function addElement(page_unit) {
        // check for duplicate name and if so, reject it.
        let page_unit_name = page_unit.name
        if (Object.keys(base_units).indexOf(page_unit_name) >= 0
                || Object.keys(page_units).indexOf(page_unit_name) >= 0) {
            log.addMessage("PageUnitModel.addElement: reject duplicate name '" + page_unit_name + "'");
            return;
        }
        jsonIo.storeJson(Peditjs.page_unit_path_from_name(page_unit_name), page_unit);
        if (jsonIo.jsonError) {
            log.addMessage("(E) PageUnit '" + page_unit_name + "': " + pu.error);
            return
        }

        put_page_unit(page_unit);

        log.addMessage("Added Page Unit '" + page_unit.name + "'");
    }

    function put_page_unit(new_page_unit) {
        let pu_name = new_page_unit.name;
        let page_unit_string = JSON.stringify(new_page_unit);
        let new_pu = {"name": pu_name, "page_unit": JSON.parse(page_unit_string)};
        page_units[pu_name] = JSON.parse(page_unit_string);
        jsonIo.storeJson(Peditjs.page_unit_path_from_name(pu_name), new_page_unit);
        if (jsonIo.jsonError) {
            new_pu.error = jsonIo.Error;
            log.addMessage("(C) PageUnit '" + page_unit_name + "': " + new_pu.error);
        }
        for(let i_pu=0; i_pu<count; i_pu++) {
            let pu = get(i_pu);
            if (pu.name === pu_name) {
                set(i_pu, new_pu);
                return;
            }
        }
        pu_list.push(pu_name);
        append(new_pu);
        return;
    }

    function get_page_unit(unit_name) {
        let page_unit = page_units[unit_name];
        if (!page_unit) {
            log.addMessage("(E) pageUnitModel.get_page_unit: Cannot find unit '" + unit_name + "'");
            return null;
//            let result = Peditjs.blank_page_unit();
//            result.name = unit_name;
//            result.base_unit_name = "Undefined";
//            result.description = "This page unit does not exist.";
//            return result;
        }
        return JSON.parse(JSON.stringify(page_unit));
    }

    function get_base_unit(unit_name) {
        if (unit_name === "Undefined") return Peditjs.blank_page_unit();
        let base_unit = base_units[unit_name];
        if (!base_unit) {
            log.addMessage("(C) pageUnitModel.get_base_unit: Cannot find unit '" + unit_name + "'");
            return null;
        }
        return JSON.parse(JSON.stringify(base_unit));
    }

    function remove_page_unit(page_unit_name) {
        jsonIo.removeJson(Peditjs.page_unit_path_from_name(page_unit_name));
        // this may trigger reload via change to the page unit folder.
        log.addMessage("pageUnitModel: Deleted Page Unit " + page_unit_name)
    }
}
