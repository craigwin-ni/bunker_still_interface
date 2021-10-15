const readonly_baseurl = "qrc:/readonly_files/";

const writable_basepath = writable_path + "/";  // writable_path is set by main.cpp
const writable_baseurl = "file:" + writable_basepath;

const connections_file_name = "connections.json";
const connections_file_subpath = connections_file_name;
//const connections_file_path = writable_basepath + connections_file_name;
//const connections_file_url = writable_baseurl + connections_file_name;

//const page_basepath = writable_basepath + "pages/";
const page_basesubpath = "pages/";
const page_baseurl = writable_baseurl + page_basesubpath;

//const system_page_baseurl = "qrc:/BsiSystemPages/";
//const system_default_page_url = system_page_baseurl + system_default_page_file;
const system_page_basesubpath = "BsiSystemPages/"
const system_default_page_file = "Bsp_Title.qml";
const system_default_page_subpath = system_page_basesubpath + system_default_page_file;

//const base_unit_baseurl = "qrc:///BsiBaseUnits/";
const base_unit_basesubpath = "BsiBaseUnits/";

const page_unit_basesubpath = "page_units/";
//const page_unit_basepath = writable_basepath + page_unit_basesubpath;
const page_unit_baseurl = writable_baseurl + page_unit_basesubpath;

/////////////////////////////
// system page path functions
/////////////////////////////

function system_page_file_from_name(page_name) {
    if (is_private_page(page_name)) {
        return page_name + ".qml"
    }

    return "Bsp_" + page_name.replace(/ /, '_') + ".qml"
}

function system_page_subpath_from_name(page_name) {
    return system_page_basesubpath + system_page_file_from_name(page_name);
}

//function system_page_url_from_name(page_name) {
//    return Pathjs.system_page_baseurl + system_page_file_from_name(page_name);
//}

function system_page_name_from_file(page_file) {
    return page_file.replace(/_/, ' ').substring(4, page_file.length-4);
}

function is_private_page(page_name) {
    return page_name.startsWith("Bpp_")
}


/////////////////////////////
// dyanmic page path functions
/////////////////////////////

function page_basename_from_name(page_name) {
    let still = status_banner.connected_still;
    if (!still && page_name !== "*") {
        log.addMessage("(E) Cannot address page file '" + page_name + "': still connection has not been made.")
        return "";
    }
    return "Bdp" + still + "_" + page_name;
}

function page_file_from_name(page_name) {
    let basename = page_basename_from_name(page_name);
    return basename  + ".qml";
}

function page_subpath_from_name(page_name) {
    let file = page_file_from_name(page_name);
    if (!file) return ""
    return page_basesubpath + file;
}

function page_name_from_file(page_file) {
    return page_file.substring(page_file.indexOf("_")+1, page_file.length-4);
}

/////////////////////////////
// page_unit path functions
/////////////////////////////

function page_unit_file_from_name(pu_name) {
    return "Bpu_" + pu_name + ".json";
}

function page_unit_subpath_from_name(pu_name) {
    return page_unit_basesubpath + page_unit_file_from_name(pu_name);
}

//function page_unit_path_from_name(pu_name) {
//    return page_unit_basepath + page_unit_file_from_name(pu_name);
//}

//function page_unit_url_from_name(pu_name) {
//    return page_unit_baseurl + page_unit_file_from_name(pu_name);
//}

function page_unit_name_from_file(pu_file) {
    return pu_file.substring(4, pu_file.length-5);
}

/////////////////////////////
// base_unit path functions
/////////////////////////////

function base_unit_component_from_name(bu_name) {
    return "Bbu_" + bu_name;
}

//function base_unit_file_from_name(bu_name) {
//    return "Bbu_" + bu_name + ".qml";
//}

////function base_unit_url_from_name(bu_name) {
////    return base_unit_baseurl + base_unit_file_from_name(bu_name);
////}

//function base_unit_subpath_from_name(bu_name) {
//    return base_unit_basesubpath + base_unit_file_from_name(bu_name);
//}

//function base_unit_name_from_file(bu_file) {
//    return bu_file.substring(4, bu_file.length-5);
//}
