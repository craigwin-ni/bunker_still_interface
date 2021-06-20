
var display_unit_basepath = "BSI/display_units/";
var display_unit_baseurl = "file:BSI/display_units/";

function display_unit_file_from_name(du_name) {
    return "Bdu_" + du_name + ".json";
}

function display_unit_name_from_file(du_file) {
    return du_file.substring(4, du_file.length-5);
}

function default_du() {
    return {
            name: "",
            url: "",
            display_unit: null,
            error: "",
            modified: false,
            in_stack: false,
            pageable: false,
            page_url: "",
            state: {},
            };
}

function default_display_unit() {
    return {
            name: "",
            description: "",
            instance_of: "",
            data: [],
            properties: [],
            };
}

function extractProperties(display_unit, display_units) {
    // extract unresolved property entries from child display_unit (or page display unit)
    // traverse all descendant DUs.

}

function mergeProperties(display_unit, child_index, extracted_properties) {
    // merge new child (unresolved) properties with current list of child properties.
}

function extractData(display_unit, display_units) {
    // extract unresolved data entries from child display_unit (or page display_unit)
    // traverse all descendant DUs.
}

function mergeData(display_unit, child_index, extracted_data) {
    // merge new child data entries from child display_unit (or page display_unit)
}

