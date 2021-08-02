import QtQuick 2.15

QtObject {
    id: bu_index
    property var base_units: {
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
        "WebView": {
            "name": "WebView",
            "description": "Render a web url",
            "base_unit_name": null,
            "datas": [],
            "props": [["Surl", "<WebUrl>", "http://influx.bunkerstills.com:3000/..."],
                      ["width", "<width>", "400"],
                      ["height", "<height>", "200"]
                     ]
        },
        "Gauge":
        {   "name": "Gauge",
            "description": "Autoscaling general purpose meter",
            "base_unit_name": null,
            "datas": [["data_component", "<data>", "<sump_temp>"]],
            "props": [["center_scale", "<center_scale>", "60"],
                      ["min_range", "<min_range>", "5"],
                      ["size", "<meter_size>", "75"]
            ]
        }
    }
}
