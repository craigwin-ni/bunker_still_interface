
var page_basepath = "BSI/pages/";
var page_baseurl = "file:BSI/pages/";
var system_page_baseurl = "qrc:/BsiSystemPages/";
var system_default_page_file = "Bsp_Title.qml";

function page_file_from_name(page_name) {
    let still = status_banner.selected_still;
    if (!still) return "";
    return "Bdp" + still + "_" + page_name + ".qml";
}

function page_name_from_file(page_file) {
    return page_file.substring(page_file.indexOf("_")+1, page_file.length-4);
}

function system_page_file_from_name(page_name) {
    return "Bsp_" + page_name.replace(/ /, '_') + ".qml"
}

function system_page_name_from_file(page_file) {
    return page_file.replace(/_/, ' ').substring(4, page_file.length-4);

}
