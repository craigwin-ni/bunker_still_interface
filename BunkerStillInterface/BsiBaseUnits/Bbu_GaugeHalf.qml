import QtQuick 2.15

Rectangle {
    property alias data_component: gauge.data_component // <sump_temp>
    property alias size: gauge.size                     // 75
    property alias autoscale: gauge.autoscale           // true/false
    property alias center_scale: gauge.center_scale     // 50
    property alias min_range: gauge.min_range           // 2
    property alias half: gauge.half                     // left/right/top/bottom

    property alias bg_color: bg_clipper.bg_draw_color
    property alias gauge_min_value: gauge.gauge_min_value
    property alias gauge_max_value: gauge.gauge_max_value
    property alias dynamic_center: gauge.dynamic_center
    property alias tick_count: gauge.tick_count

    width: (half==="left"||half==="right")? size/2 : size
    height: (half==="left"||half==="right")? size : size/2

    // background semi-circle
    Rectangle {
        id: bg_clipper

        property alias bg_draw_color: bg_draw.color

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
        x: (half==="right")? -size/2 : 0;
        y:  (half==="bottom")? -size/2 : 0;
        color: "transparent"
        radius: 0
        angle_range: 180
        tick_count: 8

        Component.onCompleted: {
            if (half==="left") {
                start_angle = -180;
                end_angle = 0;
            } else if (half==="top") {
                start_angle = -90;
                end_angle = 90;
            } else if (half==="right") {
                start_angle = 180;
                end_angle = 0;
            } else {
                start_angle = 270;
                end_angle = 90;
            }
        }
    }
}
