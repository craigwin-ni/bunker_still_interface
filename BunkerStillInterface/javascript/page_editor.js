
Qt.include("name_util.js");

var base_unit_baseurl = "qrc:///BsiBaseUnits/";
var base_unit_basepath = "BsiBaseUnits/";

function base_unit_component_from_name(bu_name) {
    return "Bbu_" + bu_name;
}

function base_unit_file_from_name(bu_name) {
    return "Bbu_" + bu_name + ".qml";
}

function base_unit_url_from_name(bu_name) {
    return base_unit_baseurl + base_unit_file_from_name(bu_name);
}

function base_unit_path_from_name(bu_name) {
    return base_unit_basepath + base_unit_file_from_name(bu_name);
}

function base_unit_type_from_name(bu_name) {
    return "Bbu_" + bu_name;
}

function base_unit_name_from_file(bu_file) {
    return bu_file.substring(4, bu_file.length-5);
}

var page_unit_basepath = "BSI/page_units/";
var page_unit_baseurl = "file:BSI/page_units/";

function page_unit_file_from_name(pu_name) {
    return "Bpu_" + pu_name + ".json";
}

function page_unit_path_from_name(pu_name) {
    return page_unit_basepath + page_unit_file_from_name(pu_name);
}

function page_unit_url_from_name(pu_name) {
    return page_unit_baseurl + page_unit_file_from_name(pu_name);
}

function page_unit_name_from_file(pu_file) {
    return pu_file.substring(4, pu_file.length-5);
}

function blank_page_unit() {
    // page_unit is {"name": <page_unit_name>,
    //               "description": <descriptive one-liner>,
    //               "base_unit_name": <base_unit_name>,
    //               "datas": [<datas 2-tuple>, ...],
    //               "props": [<props 3-tuple>, ...],
    //    (optional) "childs": [<a_child>, ...] }
    // a_child is {"unit_name": <page/base_unit_name>,
    //           "datas": [<datas 3-tuple>, ...],
    //           "props":[<props 3-tuple>}
    // datas 3-tuple is [<extracted_stand-in>, <resolution_stand-in>, <example_value>]
    // props 3-tuple is [<extracted_stand-in>, <resolution_stand-in|value>, <example_value>]
    // Notes: example_value should indicate type (string, int, etc) and typical value;
    //        datas standins are not resolved to a value until page generation;
    //        identifiers 'child' and 'children' are used by QML so I avoid them.
    return {
            name: "",
            description: "",
            base_unit_name: "",
            datas: [],
            props: [],
            // childs: [], (optional), added dynamically when required
            };
}

function updatePageUnitStandins(page_unit, deep) {
    // Note: This will modify the argument page unit.
    //       It will update the pageUnitModel if the standins are modified.

    let modified = false;

    if (!page_unit) return modified;

    let pu_model = pager.page_unit_model;
    if (pu_model.base_units[page_unit_name]) return modified;  // skip base units

    if (deep) {
        let base_unit = pu_model.get_base_unit(page_unit.base_unit_name);
        if (!base_unit) {
            log.addMessage("(C) updatePageUnitStandins: cannot find base_unit '" + page_unit.base_unit_name);
        }
        let extracted = extractStandins(base_unit);
        modified = mergeStandins(page_unit.datas, extracted.datas) || modified;
        modified = mergeStandins(page_unit.props, extracted.props) || modified;
    }

    let childs = page_unit.childs;

    if (childs) {
        var i_child, child_name, child_unit;
        if (deep) {
            // update each child
            for (i_child=0; i_child<childs.length; i_child++) {
                child_unit = pu_model.get_page_unit(childs[i_child].unit_name);
                if (!child_unit) {
                    log.addMessage("(C) updatePageUnitStandins: cannot find child page_unit '"
                                   + childs[i_child].unit_name);
                    continue;
                }
                updatePageUnitStandins(child_unit, deep);
            }
        }

        // extract and merge standins from each child
        for (i_child=0; i_child<childs.length; i_child++) {
            let a_child = childs[i_child];
            child_unit = pu_model.get_page_unit(a_child.unit_name);
            if (!child_unit) {
                log.addMessage("(C) updatePageUnitStandins: child unit '"
                               + a_child.unit_name + "' of page unit '" +
                               page_unit.name + "' is not in pageUnitModel");
                continue;
            }
            let extracted = extractStandins(child_unit);
            modified = mergeStandins(a_child.datas, extracted.datas) || modified;
            modified = mergeStandins(a_child.props, extracted.props) || modified;
        }
    }

    if (modified) {
        pu_model.put_page_unit(page_unit);
    }

    return modified;
}

function extractStandins(page_unit) {
    // Extract unresolved props standins from page_unit (or base unit).
    // Return {"datas": [<datas standins>], "props": [<props tuples: standin, example value>]}
    let extracted = {"datas": [], "props": []};

    let datas_dict = {};
    let props_dict = {};

    var i_datas, i_props, i_child;
    var candidate;
    let datas = page_unit.datas;
    let props = page_unit.props;
    let childs = page_unit.childs;

    _extract_standins(datas, datas_dict);
    _extract_standins(props, props_dict);

    if (childs) {
        for (i_child=0; i_child<childs.length; i_child++) {
            datas = childs[i_child].datas;
            props = childs[i_child].props;
            _extract_standins(datas, datas_dict);
            _extract_standins(props, props_dict);
        }
    }

    datas = Object.values(datas_dict);
    datas.sort((a,b)=>{return a[0]>b[0]?1:-1;});
    datas.map(p=>{p.unshift(p[0]); return p;});

    props = Object.values(props_dict);
    props.sort((a,b)=>{return a[0]>b[0]?1:-1;});
    props.map(p=>{p.unshift(p[0]); return p;});

    extracted = {"datas": datas, "props": props};

//    console.log("extractStandins extracted: " + JSON.stringify(extracted, 0, 2));
    return extracted;
}

function _extract_standins(assignments, assignments_dict) {
    // assignments is a datas or props member
    var i_assignment
    for (i_assignment=0; i_assignment<assignments.length; i_assignment++) {
        let candidate = assignments[i_assignment][1];
        if (is_stand_in(candidate)) {
            if (assignments_dict[candidate] === undefined) {
                assignments_dict[candidate] = assignments[i_assignment].slice(1,3);
            }
        }
    }
}

function mergeStandins(standins, new_standins) {
    // merge new_standins into standins.
    // Standins may be either [<datas 2-tuple>, ...] or [<props 3-tuple>, ...]
    // however both standins and new_standins must be the same type.
    var standin, new_standin;
    var added_standins = [];
    var i_list;
    let modified = false;

//    console.log("mergeStandins:\n... new: "+JSON.stringify(new_standins, 0, 2)
//                +"\n... old: "+JSON.stringify(standins, 0, 2));
    // eliminate outdated standins, those not in new_standins.
    for (i_list=standins.length-1; i_list>=0; i_list--) {
        standin = standins[i_list];
        let keep = false;
        for (new_standin of new_standins) {
            if (standin[0] === new_standin[0]) {
                keep = true;
                break;
            }
        }
        if (!keep) {
            standins.splice(i_list, 1);
            modified = true;
        }
    }

    // update with new entries, those in new_standins but not in standins
    for (i_list=0; i_list<new_standins.length; i_list++) {
        new_standin = new_standins[i_list];
        let add = true;
        for (standin of standins) {
            if (standin[0] === new_standin[0]) {
                add = false;
                break;
            }
        }
        if (add) {
            added_standins.push(new_standin);
        }
    }
    if (added_standins.length) {
        for (i_list=0; i_list<added_standins.length; i_list++) standins.push(added_standins[i_list]);
        standins.sort((a, b) => {return a[0]>b[0]? 1: -1;});
        modified = true;
    }
//    console.log("\n... merge: "+JSON.stringify(standins, 0, 2)+"\n...modified: "+modified);

    return modified;
}

function add_page_unit_child(page_unit, child_unit_name) {
    // Note: This does not update the pageUnitModel
    //       It is for editing purposes and editor may cancel result.
    //       Use put_page_unit in editor to preserve changes.
    if (!page_unit.childs) {
        log.addMessage("(C) Jeditps.add_page_unit_child: attempt to add child '" + child_unit_name
                       + "' to non-structural page unit '" + page_unit.name + "'");
        return null;
    }

    let child_unit = pager.page_unit_model.get_page_unit(child_unit_name);
    if (!child_unit) {
        log.addMessage("(C) Jeditps.add_page_unit_child: child_unit_name '"
                       + child_unit_name + "' not in pageUnitModel.");
        return null;
    }

    // Scan descendants of child_unit for occurrance of page_unit.
    // This indicates a cycle that must be disallowed.
    if (child_unit.name === page_unit.name || scan_for_descendant(child_unit, page_unit.name)) {
        log.addMessage("(E) Jeditps.add_page_unit_child: page_unit '" + page_unit.name
                       + "' is a descendant of '" + child_unit_name + "' so it cannot add '"
                       + child_unit_name + "' as a child.");
        return null;
    }

    let extracted = extractStandins(child_unit);

    let new_child = {
            "unit_name": child_unit.name,
            "datas": extracted.datas,
            "props": extracted.props
            };
    page_unit.childs.push(new_child);
    return new_child;
}

function scan_for_descendant(page_unit, descendant_name) {
    if (!page_unit.childs) return false;
    for (let a_child of page_unit.childs) {
        if (a_child.unit_name === descendant_name) return true;
        let child_unit = pager.page_unit_model.get_page_unit(a_child.unit_name);
        if (!child_unit) {
            log.addMessage("(E) Peditjs.scan_for_descendant("+descendant_name
                           +"): cannot get child unit '"+a_child.unit_name+"'");
            console.log("Peditjs.scan_for_descendant: error on childs: "+JSON.stringify(page_unit, 0, 2));
            continue;
        }

        if (scan_for_descendant(child_unit, descendant_name)) return true;
    }
    return false;
}

function pagegen(page_unit, resolution, page_name) {
    let page_text = "";
    let page_unit_model = pager.page_unit_model;
    if (!page_name) page_name = page_unit_name;
    console.log("pagegen: generating page '" + page_name + "'");

    // Check for complete resolution
    var i_resolution;
    let errors = 0;
    for (let section of ["datas", "props"]) {
        for (i_resolution=0; i_resolution<resolution[section].length; i_resolution++) {
            if (is_stand_in(resolution[section][i_resolution][1])) {
                log.addMessage("(E) Standin '" + resolution[section][i_resolution][0]
                               + "' is not resolved.");
                errors += 1;
            }
        }
    }
    if (errors) return page_text;

    // Generate top of QML file.
    page_text = (" " + qml_file_head).slice(1);
//    page_text += "Item {\n";

    // Recursively generate page contents
    page_text += generate_unit(page_unit, resolution, 2);

    // Generate bottom of QML file.
//    page_text += "}\n\n// End of generated QML\n";
    page_text += "\n// End of generated QML\n";

    return page_text;
}

function generate_unit(page_unit, resolution, indent) {
    let page_text = "";

    // Resolve page_unit
    resolve_page_unit(page_unit, resolution);

    // Get a copy of base unit and resolve it uning resolved page unit.
    let base_unit = page_unit_model.get_base_unit(page_unit.base_unit_name);
    resolve_page_unit(base_unit, page_unit);

    // Generate top of this unit.
    page_text += " ".repeat(indent) + base_unit_component_from_name(page_unit.base_unit_name) + " {\n";
    indent += 2;

    var data, prop;
//    if (base_unit.props.length + base_unit.datas.length) {
    if (base_unit.datas.length) {
        page_text += "\n" + " ".repeat(indent) + "Component.onCompleted: {\n";
        indent += 2;
        page_text += " ".repeat(indent) + "//\n";
        page_text += " ".repeat(indent) + "// Data assignments\n";
        for (data of base_unit.datas) {
            page_text += " ".repeat(indent) + data[0]
                         + " = componentStore.get_component(\"" + data[1] + "\");\n";
        }
        indent -= 2;
        page_text += " ".repeat(indent) + "}\n";
    }
    if (base_unit.props.length) {
        page_text += " ".repeat(indent) + "//\n";
        page_text += " ".repeat(indent) + "// Property assignments\n";
        for (prop of base_unit.props) {
            if (prop[0].startsWith("S")) {
                let escaped_prop = prop[1].replace("\"", "\\\"");
                page_text += " ".repeat(indent) + prop[0].slice(1) + ": \"" + escaped_prop + "\"\n";
            } else {
                page_text += " ".repeat(indent) + prop[0] + ": " + prop[1] + "\n";
            }
        }
    }
//    }

    // Generate each child
    if (page_unit.childs) {
        for (let child of page_unit.childs) {
            page_text += "\n";
            let child_unit = page_unit_model.get_page_unit(child.unit_name);
            page_text += generate_unit(child_unit, child, indent);
        }
    }

    // Generate end of this unit
    indent -= 2;
    page_text += " ".repeat(indent) + "}\n";

    return page_text;
}

function resolve_page_unit(page_unit, resolution) {
    // replace all column 2 standins with the resolution.
    let datas_dict = {};
    let props_dict = {};
    resolution.datas.forEach((tuple)=>{datas_dict[tuple[0]] = tuple[1];});
    resolution.props.forEach((tuple)=>{props_dict[tuple[0]] = tuple[1];});
    var data, prop, child;

    for (data of page_unit.datas) {
        data[1] = datas_dict[data[1]] || data[1];
    }
    for (prop of page_unit.props) {
        prop[1] = props_dict[prop[1]] || prop[1];
    }

    if (page_unit.childs) {
        for (child of page_unit.childs) {
            for (data of child.datas) {
                data[1] = datas_dict[data[1]] || data[1];
            }
            for (prop of child.props) {
                prop[1] = props_dict[prop[1]] || prop[1];
            }
        }
    }
}

const qml_file_head = "// This file is generated from a page_unit.  Edits may be overwritten.\n"
                      + "import QtQuick 2.15\n"
//                      + "import QtQuick.Controls 2.15\n"
                      + "import \"../BsiBaseUnits\"\n"
//                      + "import \"../BsiDisplayObjects\"\n"
//                      + "import Bunker 1.0\n"
                      + "\n"
