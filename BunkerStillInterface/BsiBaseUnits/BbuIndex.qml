import QtQuick 2.15

QtObject {
    id: bu_index
    property var base_units: ({
        "DataAsText": {
            "name": "DataAsText",
            "description": "Display component value as text with the specified label",
            "base_unit_name": null,
            "datas": [["value.text", "<Data1>", ""]],
            "props": [["label.text", "<Label>", "SomeData:"]]
            },
        "Row": {
            "name": "Row",
            "description": "Row Layout of installed childs",
            "base_unit_name": null,
            "datas": [],
            "props": [],
            "childs": []
            }
    })
}
