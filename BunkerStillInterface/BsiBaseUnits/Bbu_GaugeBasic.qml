import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: gauge

    // page_unit properties
    property var data_component                        // <sump_temp>
    property int size                                  // 75
    property bool autoscale                            // true/false
    property alias center_scale: _gauge.center_scale   // 50
    property alias min_range: _gauge.min_range         // 2

    property alias gauge_width: _gauge.width
    property alias gauge_height: _gauge.height

    // derived component accessible properties used by CircularGaugeStyle
    property real angle_range: 290
    property int tick_count: 10
    property real start_angle: -angle_range/2
    property real end_angle: angle_range/2

    // properties for derived components
    property bool dynamic_center: false  // used for PID setpoint

    implicitWidth: size
    implicitHeight: size
    radius: size/2
    color: "#ffc"

    onData_componentChanged: {
        if (data_component) {
            data_component.onValueChanged.connect(_gauge.set_value);
        }
    }

    CircularGauge {
        id: _gauge

        property real center_scale
        property real min_range
        property bool autoscale             // true/false

        property real data_value

        width: size
        height: size

        Component.onCompleted: {
            if (!autoscale) {
                minimumValue = center_scale - min_range/2.0;
                maximumValue = center_scale + min_range/2.0;
                stepSize = min_range / 400;
            }
        }

        function set_value() {
            if (data_component) {
                value = data_value = data_component.value;
            }
        }

        stepSize: 0.1;
        minimumValue: center_scale - 50;
        maximumValue: center_scale + 50;

        style: CircularGaugeStyle {
            // internal properties
            property real tick_angle: angle_range / tick_count
            property real max_data_angle: angle_range/2 - tick_angle

            property int tickstep_index: 0
            property int tickstep_power: 2
            property int tickstep_mult: 1
            readonly property var tickstep_magnitude: [Math.log10(1), Math.log10(2), Math.log10(5)]
            readonly property var minor_ticks: [4, 3, 4]
            property real tick_step

            property bool update_in_progress: false

            minimumValueAngle: start_angle
            maximumValueAngle: end_angle

            Component.onCompleted: {
                _gauge.onData_valueChanged.connect(update_value);
                if (dynamic_center) {
                    _gauge.onCenter_scaleChanged.connect(set_scale);
                }
                if (!autoscale) {
                    tickmarkStepSize = min_range/tick_count;
                    labelStepSize = tickmarkStepSize;
                    minorTickmarkCount = 4;
                    tickstep_mult = 100;
                }
            }

            function update_value() {
                if (!autoscale) return;
                if (update_in_progress) {
                    return;
                }

                update_in_progress = true;

//                let data_angle = valueToAngle(control.value);
                let value_range = control.maximumValue - control.minimumValue;
                let data_angle = Math.abs((control.value-control.center_scale) / value_range
                                 * angle_range);
//                console.log("GaugeStyle.update_value:"
//                            +" value="+control.value
//                            +" tick_step="+tickmarkStepSize
//                            +" tick_angle="+tick_angle
//                            +" data_angle="+data_angle
//                            +"\n         value_range="+control.minimumValue+" to "+control.maximumValue
//                            +" center="+control.center_scale
//                            +"\n         angle_range="+minimumValueAngle+" to "+maximumValueAngle
//                            );
                if (data_angle < tick_angle && value_range > min_range+control.stepSize) {
                    decrease_range();
                    set_scale();
                } else if (data_angle > max_data_angle) {
                    increase_range();
                    set_scale();
                } else if (!dynamic_center) {
                    // set center scale to tickmark nearest data value
                    let proposed_center = Math.round(control.value/tick_step) * tick_step;
                    control.center_scale = proposed_center;
                    set_scale();
                }
                update_in_progress = false;
            }

            function increase_range() {
                if (tickstep_index === 2) {
                    tickstep_index = 0;
                    tickstep_power += 1;
                } else {
                    tickstep_index += 1;
                }
            }

            function decrease_range() {
                if (tickstep_index === 0) {
                    tickstep_index = 2;
                    tickstep_power -=1;
                } else {
                    tickstep_index -= 1;
                }
            }

            function set_scale() {
                let step = Math.pow(10, tickstep_magnitude[tickstep_index] + tickstep_power);
                tickstep_mult = tickstep_power >= 0? 1 : Math.round(Math.pow(10, -tickstep_power));
                tick_step = Math.round(step*tickstep_mult) / tickstep_mult;

                control.stepSize = tick_step / 50;
                control.minimumValue = control.center_scale - tick_count * tick_step / 2;
                control.maximumValue = control.minimumValue + tick_count * tick_step;

//                console.log("GaugeBase.set_scale tick_step="+tick_step
//                            +" tick_count="+tick_count
//                            +" minValue="+control.minimumValue
//                            +" center="+control.center_scale
//                            +" maxValue="+control.maximumValue
//                            );

                tickmarkStepSize = tick_step;
                labelStepSize = tick_step;
                minorTickmarkCount = minor_ticks[tickstep_index];

            }

            tickmarkLabel: Text {
                text: Math.round(styleData.value*tickstep_mult) / tickstep_mult;
            }
        }
    }
}
