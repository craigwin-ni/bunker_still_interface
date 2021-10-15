// This file is generated from a page_unit.  Edits may be overwritten.
import QtQuick 2.15
import "../BsiBaseUnits"
import "../BsiDisplayObjects"

  Bbu_Row {
    // Property assignments
    spacing: 2
    padding: 2

    Bbu_GaugeHalf {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("column_water_exit_temp");
      }
      // Property assignments
      half: "left"
      autoscale: false
      center_scale: 50
      min_range: 80
      size: 120
    }

    Bbu_GaugeHalf {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("water_heater_input_temp");
      }
      // Property assignments
      half: "right"
      autoscale: false
      center_scale: 50
      min_range: 80
      size: 120
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("water_heater_input_temp");
      }
      // Property assignments
      label_field_text: "cool side"
      label_width: 80
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("upper_bypass_temp");
      }
      // Property assignments
      label_field_text: "bypass"
      label_width: 80
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("column_water_exit_temp");
      }
      // Property assignments
      label_field_text: "hot side"
      label_width: 80
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("circulation_pump_output");
      }
      // Property assignments
      label_field_text: "pump pwr"
      label_width: 80
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }
  }

// End of generated QML
