// This file is generated from a page_unit.  Edits may be overwritten.
import QtQuick 2.15
import "../BsiBaseUnits"
import "../BsiDisplayObjects"

  Bbu_ImagePage {
    // Property assignments
    image_name: "Still-5_index"

    //Annotations
    BdoTextAnnotation {
    annobj: {
      "x": 0.3025,
      "y": 0.1685,
      "pinpoint": "TC",
      "precision": 4,
      "to_page": "cooling",
      "display_list": [
            [
                  "column in",
                  "water_heater_input_temp"
            ],
            [
                  "bypass",
                  "upper_bypass_temp"
            ],
            [
                  "column out",
                  "column_water_exit_temp"
            ]
      ]
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.33,
      "y": 0.5625,
      "pinpoint": "BC",
      "precision": 4,
      "display_list": [
            [
                  "flow",
                  "water_flow_sensor"
            ],
            [
                  "Tin",
                  "water_heater_input_temp"
            ],
            [
                  "Tout",
                  "water_heater_temp"
            ]
      ]
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.33,
      "y": 0.853,
      "pinpoint": "BC",
      "precision": 4,
      "display_list": [
            [
                  "flow",
                  "feedstock_flow_sensor"
            ],
            [
                  "Tin",
                  "feedstock_heater_input_temp"
            ],
            [
                  "Tout",
                  "feedstock_heater_temp"
            ],
            [
                  "Tdegas",
                  "degasser_stack_temp"
            ]
      ]
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.71,
      "y": 0.406,
      "precision": 4,
      "pinpoint": "CR",
      "display_list": [
            [
                  "top",
                  "stillhead_temp"
            ],
            [
                  "heads",
                  "upper_draw_temp"
            ],
            [
                  "hearts",
                  "middle_draw_temp"
            ],
            [
                  "tails",
                  "lower_draw_temp"
            ],
            [
                  "feed in",
                  "column_feed_temp"
            ],
            [
                  "sump",
                  "sump_temp"
            ]
      ]
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.99,
      "y": 0.855,
      "pinpoint": "BR",
      "pid_name": "main_heater_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.01,
      "y": 0.951,
      "pinpoint": "BL",
      "pid_name": "feedstock_heater_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.01,
      "y": 0.677,
      "pinpoint": "BL",
      "pid_name": "water_heater_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.01,
      "y": 0.817,
      "pinpoint": "BL",
      "pid_name": "feedstock_pump_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.01,
      "y": 0.529,
      "pinpoint": "BL",
      "pid_name": "water_pump_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.01,
      "y": 0.255,
      "pinpoint": "BL",
      "pid_name": "circulation_pump_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.99,
      "y": 0.218,
      "pinpoint": "BR",
      "pid_name": "upper_draw_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.99,
      "y": 0.45,
      "pinpoint": "BR",
      "pid_name": "middle_draw_pid"
}
    }
    BdoTextAnnotation {
    annobj: {
      "x": 0.99,
      "y": 0.649,
      "pinpoint": "BR",
      "pid_name": "lower_draw_pid"
}
    }
  }

// End of generated QML
