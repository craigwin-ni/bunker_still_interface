import QtQuick 2.15

QtObject {
    id: bu_index
    property var base_units: ({
        "DataAsText": {
            "name": "DataAsText",
            "description": "Display component value as text with the specified label",
            "base_unit_name": null,
            "datas": [["data_component", "<data>", "<sump_temp>"]],
            "props": [["precision", "<precision>", "4"],
                      ["Slabel_field_text", "<label>", "Temperature"]]
        },
        "Row": {
            "name": "Row",
            "description": "Row Layout of configured childs",
            "base_unit_name": null,
            "datas": [],
            "props": [],
            "childs": []
        },
    })
}
