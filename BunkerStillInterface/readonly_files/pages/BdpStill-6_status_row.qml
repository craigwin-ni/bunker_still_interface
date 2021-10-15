// This file is generated from a page_unit.  Edits may be overwritten.
import QtQuick 2.15
import "../BsiBaseUnits"
import "../BsiDisplayObjects"

  Bbu_Row {
    // Property assignments
    spacing: 3
    padding: 1

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("run_mode");
      }
      // Property assignments
      label_field_text: "mode"
      label_width: 50
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("upper_draw_temp");
      }
      // Property assignments
      label_field_text: "heads"
      label_width: 50
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("lower_draw_temp");
      }
      // Property assignments
      label_field_text: "hearts"
      label_width: 50
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }

    Bbu_DataAsText {

      Component.onCompleted: {
        // Data assignments
        data_component = componentStore.get_component("sump_temp");
      }
      // Property assignments
      label_field_text: "sump"
      label_width: 50
      label_align: "center"
      data_align: "center"
      precision: 4
      stacked: true
    }
  }

// End of generated QML
