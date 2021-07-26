
const page_basepath = "BSI/pages/";
const page_baseurl = "file:BSI/pages/";
const system_page_baseurl = "qrc:/BsiSystemPages/";
const system_default_page_file = "Bsp_Title.qml";
const system_default_page_url = system_page_baseurl + system_default_page_file;

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

function page_path_from_name(page_name) {
    let file = page_file_from_name(page_name);
    if (!file) return ""
    return page_basepath + file;
}

function page_name_from_file(page_file) {
    return page_file.substring(page_file.indexOf("_")+1, page_file.length-4);
}

function system_page_file_from_name(page_name) {
    if (is_private_page(page_name)) {
        return page_name + ".qml"
    }

    return "Bsp_" + page_name.replace(/ /, '_') + ".qml"
}

function system_page_url_from_name(page_name) {
    return system_page_baseurl + system_page_file_from_name(page_name);
}

function system_page_name_from_file(page_file) {
    return page_file.replace(/_/, ' ').substring(4, page_file.length-4);

}

function is_private_page(page_name) {
    return page_name.startsWith("Bpp_")
}
