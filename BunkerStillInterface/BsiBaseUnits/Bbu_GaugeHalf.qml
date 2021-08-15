import QtQuick 2.0


Rectangle {
    property alias data_component: gauge.data_component // <sump_temp>
    property alias size: gauge.size                     // 75
    property alias autoscale: gauge.autoscale           // true/false
    property alias center_scale: gauge.center_scale     // 50
    property alias min_range: gauge.min_range           // 2
    property alias half: gauge.half                     // left/right/top/bottom

    width: (half==="left"||half==="right")? size/2 : size
    height: (half==="left"||half==="right")? size : size/2

    // background semi-circle
    Rectangle {
        id: bg_clipper

        // this is the clipper rectangle and should match the top rectangle
        anchors.fill: parent
        color: "transparent"
        clip: true
        Rectangle {
            id: bg_draw

            // background circle to be clipped; should match gauge
            width: size
            height: size
            x: (half==="right")? -size/2 : 0;
            y:  (half==="bottom")? -size/2 : 0;
            radius: size/2
            color: "#ffc"
            border.width: 1
            border.color: "black"
        }
    }

    Bbu_GaugeBasic {
        id: gauge

        // page_unit properties
        property string half                // left/right/top/bottom

        // inherited page_unit properties
        // data_component                   // <sump_temp>
        // size                             // 120
        // autoscale                        // true/false
        // center_scale: _gauge.center_scale   // 50
        // min_range: _gauge.min_range         // 2

        // GaugeBasic is size x size.  We offset it and use the half at 0,0
//        gauge_width: (half==="left"||half==="right")? size/2 : size
//        gauge_height: (half==="left"||half==="right")? size : size/2

        x: (half==="right")? -size/2 : 0;
        y:  (half==="bottom")? -size/2 : 0;
        color: "transparent"
        radius: 0
        angle_range: 180
        tick_count: 8

        Component.onCompleted: {
            if (half==="left") {
                start_angle = 0;
                end_angle = -180;
            } else if (half==="top") {
                start_angle = -90;
                end_angle = 90;
            } else if (half==="right") {
                start_angle = 0;
                end_angle = 180;
            } else {
                start_angle = 270;
                end_angle = 90;
            }
        }
    }
}
