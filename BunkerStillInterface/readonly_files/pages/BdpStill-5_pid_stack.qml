// This file is generated from a page_unit.  Edits may be overwritten.
import QtQuick 2.15
import "../BsiBaseUnits"

  Bbu_Column {
    //
    // Property assignments
    spacing: 4
    padding: 2

    Bbu_PidGauge {

      Component.onCompleted: {
        //
        // Data assignments
        enable_component = componentStore.get_component("main_heater_pid_enable");
      }
      //
      // Property assignments
      size: 150
    }

    Bbu_PidGauge {

      Component.onCompleted: {
        //
        // Data assignments
        enable_component = componentStore.get_component("lower_draw_pid_enable");
      }
      //
      // Property assignments
      size: 150
    }

    Bbu_PidGauge {

      Component.onCompleted: {
        //
        // Data assignments
        enable_component = componentStore.get_component("middle_draw_pid_enable");
      }
      //
      // Property assignments
      size: 150
    }

    Bbu_PidGauge {

      Component.onCompleted: {
        //
        // Data assignments
        enable_component = componentStore.get_component("upper_draw_pid_enable");
      }
      //
      // Property assignments
      size: 150
    }
  }

 // End of generated QML
