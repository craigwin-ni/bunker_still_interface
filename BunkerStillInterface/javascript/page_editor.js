
var base_unit_baseurl = "qrc:///BsiBaseUnits/";
var base_unit_basepath = "BsiBaseUnits/";

function base_unit_file_from_name(bu_name) {
    return "Bbu_" + bu_name + ".json";
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
    //    (optional) "childs": [<child>, ...] }
    // child is {"unit_name": <page/base_unit_name>,
    //           "datas": [<datas 2-tuple>, ...],
    //           "props":[<props 3-tuple>}
    // datas 2-tuple is [<extracted stand-in>, <resolution stand-in>]
    // props 3-tuple is [<extracted stand-in>, <resolution stand-in or value>, <example value>]
    return {
            name: "",
            description: "",
            base_unit_name: "",
            datas: [],
            props: [],
            // childs: [], (optional), added dynamically if required
            };
}

var name_re = RegExp("^[a-zA-Z_][a-zA-Z_0-9]*$");
function validate_name(name) {
    return name_re.test(name);
}

var stand_in_re = RegExp("^<[a-zA-Z_][a-zA-Z_0-9]*>$");
function is_stand_in(s) {
    return stand_in_re.test(s);
}

function updatePageUnitStandins(page_unit, deep, recursive) {
    // Note: This will modify the argument page unit.
    //       It will update the pageUnitModel if this is a recursive call,
    //       but the initial call is working on an edited page_unit so we
    //       do not store that until the edit is saved.

    if (!page_unit) return;

    let pu_model = pager.page_unit_model;
    if (pu_model.base_units[page_unit_name]) return;  // skip base units

    if (deep) {
        let base_unit = pu_model.get_base_unit(page_unit.base_unit_name);
        if (!base_unit) {
            log.addMessage("(C) updatePageUnitStandins: cannot find base_unit '" + base_unit_name);
        }
        mergeStandins(page_unit.datas, base_unit.datas);
        mergeStandins(page_unit.props, base_unit.props);
    }

    let childs = page_unit.childs;
    if (!childs) return;

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
            updatePageUnitStandins(child_unit, deep, true);
        }
    }

    // extract and merge standins from each child
    for (i_child=0; i_child<childs.length; i_child++) {
        child_name = childs[i_child].unit_name;
        child_unit = pu_model.get_page_unit(child_name);
        if (!child_unit) {
            log.addMessage("(C) updatePageUnitStandins: child unit '" + child_name + "' of page unit '" +
                           page_unit.name + "' is not in pageUnitModel");
            continue;
        }
        let extracted = extractStandins(child_unit);
        mergeStandins(child_unit.datas, extracted.datas);
        mergeStandins(child_unit.props, extracted.props);
    }
    if (recursive) {
        pu_model.put_page_unit(page_unit);
    }
}

function extractStandins(page_unit) {
    // Extract unresolved props standins from page_unit (or base unit).
    // Return {"datas": [<datas standins>], "props": [<props tuples: standin, example value>]}
    let extracted = {"datas": [], "props": []};

    let datas_set = new Set();
    let props_dict = {};

    var i_datas, i_props, i_child;
    let datas = page_unit.datas;
    let props = page_unit.props;
    let childs = page_unit.childs;
    for (i_datas=0; i_datas<datas.length; i_datas++) {
        datas_set.add(datas[i_datas][1]);
    }
    for (i_props=0; i_props<props.length; i_props++) {
        if (props_dict[props[i_props][1]] === undefined) {
            props_dict[props[i_props][1]] = props[i_props].slice(1,3);
        }
    }
    if (childs) {
        for (i_child=0; i_child<childs.length; i_child++) {
            datas = page_unit.childs[i_child].datas;
            props = page_unit.props;
            for (i_datas=0; i_datas<datas.length; i_datas++) {
                datas_set.add(datas[i_datas][1]);
            }
            for (i_props=0; i_props<props.length; i_props++) {
                let candidate = props[i_props[1]];
                if (is_stand_in(candidate)) {
                    if (props_dict[candidate] === undefined) {
                        props_dict[candidate] = props[i_props].slice(1,3);
                    }
                }
            }
        }
    }

    datas = Array.from(datas_set);
    datas.sort();
    extracted.datas = datas.map(d=>{return [d, d]});

    props = Object.values(props_dict);
    props.sort((a,b)=>{return a[0]>b[0]?1:-1;});
    props.map(p=>{return p.unshift(p[0])});
    extracted.props = props;
//    console.log("Extracted from " + page_unit.name + ":\n" + JSON.stringify(extracted, 0, 2));
    return extracted;
}

function mergeStandins(standins, new_standins) {
    // merge new_standins into standins.
    // Standins may be either [<datas 2-tuple>, ...] or [<props 3-tuple>, ...]
    // however both standins and new_standins must be the same type.
    var standin, new_standin;
    var added_standins = [];
    var i_list;

    // eliminate outdated standins: those not in new_standins.
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
        }
    }

    // update with new entries
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
    }
}

function add_page_unit_child(page_unit, child_unit_name) {
    // Note: This does not update the pageUnitModel
    //       It is for editing purposes and editor may cancel result.
    //       Use put_page_unit to preserve changes.
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

    let extracted = extractStandins(child_unit);

    let new_child = {
            "unit_name": child_unit.name,
            "datas": extracted.datas,
            "props": extracted.props
            };
    page_unit.childs.push(new_child);
    return new_child;
}

function pagegen_resolve(page_unit_name, resolution) {
    console.log("pagegen_resolve: resolving page '" + page_unit_name + "'");
    return {};
}

function pagegen_generate(page_unit_name, resolved_units) {
    console.log("pagegen_resolve: resolving page '" + page_unit_name + "'");
    return "";
}
