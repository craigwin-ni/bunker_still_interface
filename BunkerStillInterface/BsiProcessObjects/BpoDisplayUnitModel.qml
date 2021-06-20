import QtQuick 2.15
import Qt.labs.folderlistmodel 2.15
import "../javascript/page_util.js" as Putiljs
import "../javascript/page_editor.js" as Peditjs

ListModel {
    property var display_units: ({})

    property var du_folder: FolderListModel {
        id: du_folder

        folder: Peditjs.display_unit_baseurl
        showDirs: false
        showOnlyReadable: true
        sortField: FolderListModel.Name
        nameFilters: [Peditjs.display_unit_file_from_name("*")]
    }

    property var page_folder: FolderListModel {
        id: page_folder

        folder: Putiljs.page_baseurl
        showDirs: false
        showOnlyReadable: true
        sortField: FolderListModel.Name
        nameFilters: ["None"]
    }

    property var jsonIo: BpoJsonIo {
        id: jsonIo
        onJsonErrorChanged: {
            log.addMessage("DisplayUnits: " + jsonIo.jsonErrorMsg);
        }
    }

    function get_du_list() {
        var du_list = [];
        let du_count = du_folder.count;
        for (let i_page=0; i_page<page_count; i_page++) {
            let basename = du_folder.get(i_page, "fileBaseName");
            du_list.push(basename.substring(basename.indexOf("_")+1));
        }
        return du_list;
    }

    function get_page_list() {
        var page_list = [];
        var still = status_banner.connected_still;
        page_folder.nameFilters = [Putiljs.page_file_from_name("*")];
        let page_count = page_folder.count;
        for (let i_page=0; i_page<page_count; i_page++) {
            page_list.push(Peditjs.display_unit_name_from_file(page_folder.get(i_page, "fileName")));
        }
        return page_list;
    }

    function loadDisplayUnits() {
        let du_list = get_du_list();
        let page_list = get_page_list();
        clear();
        for (let du_name of du_list) {
            let du = Peditjs.default_du();
            du.name = du_name;
            du.url = Peditjs.display_unit_file_from_name(du_name);
            du.display_unit = jsonIo.loadJson(du.url);
            if (jsonIo.jsonError) {
                du.error = jsonIo.JsonErrorMsg;
                log.addMessage("(E) DisplayUnit '" + du_name + "': " + du.error);
                continue;
            }
            if (du.display_unit.name !== du.name) {
                du.error = "'" + du_name + "' has internal name '" + du.display_unit.name + "'";
                log.addMessage("(E) DisplayUnit: " + du.error);
            }

            display_units[du_name] = display_unit;

            du.pageable = false;  // XXX requires extraction of properties
            du.page_exists = page_list.indexOf(du_name) >= 0;
            append(du);
        }
    }

    // this function is called by BdoListNameAdder
    function addElement(jsobject) {
        // check for duplicate name and if so, reject it.
        if (Object.keys(display_units).indexOf(jsobject.name) >+ 0) {
            log.addMessage("DisplayUnitModel.addElement: reject duplicate name '" + jsobject.name + "'")
            return;
        }
        displayunits[jsobject.name] = jsobject.display_unit;
        append(jsobject);
    }

    function removeElement(index) {
        if (index >= 0 && index < count) {
            delete display_units[get(index).name];
            remove(index);
        }
    }
}
