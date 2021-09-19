import QtQuick 2.15

QtObject {
    id: bu_index
    property var base_units: {
        "Row": {
            "name": "Row",
            "description": "Row of page units",
            "base_unit_name": null,
            "datas": [],
            "props": [["spacing", "<row_spacing>", "6"],
                      ["padding", "<row_padding>", "2"]],
            "childs": []
        },
        "Column": {
            "name": "Column",
            "description": "Column of page units",
            "base_unit_name": null,
            "datas": [],
            "props": [["spacing", "<column_spacing>", "4"],
                      ["padding", "<column_padding>", "2"]],
            "childs": []
        },
        "DataAsText": {
            "name": "DataAsText",
            "description": "Display component value as text with the specified label",
            "base_unit_name": null,
            "datas": [["data_component", "<data>", "<sump_temp>"]],
            "props": [
                ["Slabel_field_text", "<label>", "Temperature"],
                ["label_width", "<label_width>", "160"],
                ["Slabel_align", "<label_align>", "left, right, center"],
                ["Sdata_align", "<data_align>", "left, right, center"],
                ["precision", "<precision>", "4"],
                ["stacked", "<stacked>", "true"]
            ]
        },
        "PidText": {
            "name": "PidText",
            "description": "All pid components as text",
            "base_unit_name": null,
            "datas": [["enable_component", "<pid_enable>", "<some_pid_enable>"]],
            "props": []
        },
        "PidGauge": {
            "name": "PidGauge",
            "description": "Dual gauge tracking PID operation",
            "base_unit_name": null,
            "datas": [["enable_component", "<pid_enable>", "<some_pid_enable>"]],
            "props": [["size", "<meter_size>", "150"]]
        },
        "GaugeBasic": {
            "name": "GaugeBasic",
            "description": "Basic circular gauge with optional autoscaling",
            "base_unit_name": null,
            "datas": [["data_component", "<data>", "<sump_temp>"]],
            "props": [["size", "<meter_size>", "120"],
                      ["autoscale", "<autoscale>", "true/false"],
                      ["center_scale", "<center_scale>", "60"],
                      ["min_range", "<min_range>", "5"],
            ]
        },
        "GaugeHalf":
        {   "name": "GaugeHalf",
            "description": "Basic semi-circular gauge with optional autoscaling",
            "base_unit_name": null,
            "datas": [["data_component", "<data>", "<sump_temp>"]],
            "props": [["Shalf", "<gauge_half>", "left/right/top/bottom"],
                      ["autoscale", "<autoscale>", "true/false"],
                      ["center_scale", "<center_scale>", "60"],
                      ["min_range", "<min_range>", "5"],
                      ["size", "<meter_size>", "120"]
            ]
        },
        "ImagePage": {
            "name": "ImagePage",
            "description": "Image display unit",
            "base_unit_name": null,
            "datas": [],
            "props": [["Simage_name", "<image_name>", "'abcd' (no extension)"]]
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
    }
}
