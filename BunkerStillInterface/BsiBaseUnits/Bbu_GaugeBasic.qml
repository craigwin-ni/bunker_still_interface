import QtQuick 2.15
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: gauge

    // page_unit properties
    property var data_component                        // <sump_temp>
    property int size                                  // 75
    property alias autoscale: _gauge.autoscale         // true/false
    property alias center_scale: _gauge.center_scale   // 50
    property alias min_range: _gauge.min_range         // 2

    property alias gauge_width: _gauge.width
    property alias gauge_height: _gauge.height
    property alias gauge_min_value: _gauge.minimumValue
    property alias gauge_max_value: _gauge.maximumValue

    // derived component accessible properties used by CircularGaugeStyle
    property real angle_range: 290
    property int tick_count: 10
    property real start_angle: -angle_range/2
    property real end_angle: angle_range/2

    // properties for derived components
    property bool dynamic_center: false  // set true for PID setpoint

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

        Component.onCompleted: {if (!autoscale) set_static_scale();}
        onMin_rangeChanged: {if (!autoscale) set_static_scale;}
        onCenter_scaleChanged: {if (!autoscale) set_static_scale();}

        function set_static_scale() {
            if (!autoscale) {
                if (center_scale && min_range) {
                    minimumValue = center_scale - min_range/2.0;
                    maximumValue = center_scale + min_range/2.0;
                    stepSize = min_range / 400;
                }
            }
        }

        function set_value() {
            if (data_component) {
                value = data_value = data_component.value;
            }
        }

        stepSize: 2;
        minimumValue: center_scale - 10;
        maximumValue: center_scale + 10;

        style: CircularGaugeStyle {
            // internal properties
            property real tick_angle: angle_range / tick_count
            property real max_data_angle: angle_range/2 - tick_angle

            property int tickstep_index: 0
            property int tickstep_power: 0
            property int tickstep_mult: 100
            readonly property var tickstep_magnitude: [Math.log10(1), Math.log10(2), Math.log10(5)]
            readonly property var minor_ticks: [4, 3, 4]
            property real tick_step: 1
            property real true_center: 50

            property bool update_in_progress: false
            minimumValueAngle: start_angle
            maximumValueAngle: end_angle


            Component.onCompleted: {
                _gauge.onData_valueChanged.connect(update_value);
                if (!autoscale) {
                    set_static_tickmarks();
                    _gauge.onCenter_scaleChanged.connect(set_static_tickmarks);
                    _gauge.onMin_rangeChanged.connect(set_static_tickmarks);
                } else {
                    _gauge.onCenter_scaleChanged.connect(set_center);
                }
            }

            function set_static_tickmarks() {
                if (!autoscale) {
                    tickmarkStepSize = min_range/tick_count;
                    labelStepSize = tickmarkStepSize;
                    minorTickmarkCount = 4;
                    tickstep_mult = 100;
                }
            }

            function set_center() {
                if (!center_scale) return;
                if (!dynamic_center) {
                    true_center = center_scale;
                    set_scale();
                } else {
                    let new_center = Math.round(center_scale/tick_step) * tick_step;
                    if (new_center !== true_center) {
                        true_center = new_center;
                        set_scale();
                    }
                }
            }

            function update_value() {
                // Note: gauge.value is set above in gauge.set_value().
                if (!autoscale) return;
                if (update_in_progress) return;
                if (!Number.isFinite(control.value)) return;
                if (!control.value || !center_scale) return;

                update_in_progress = true;

//                let data_angle = valueToAngle(control.value);
                let value_range = control.maximumValue - control.minimumValue;
                let data_angle = Math.abs((control.value-true_center) / value_range
                                 * angle_range);
//                console.log("GaugeStyle.update_value:"
//                            +" value="+control.value
//                            +" tick_step="+tickmarkStepSize
//                            +" tick_angle="+tick_angle
//                            +" data_angle="+data_angle
//                            +"\n         value_range="+control.minimumValue+" to "+control.maximumValue
//                            +" center="+true_center
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
                    if (Math.abs(control.value-true_center)/tick_step > 0.8) {
                        true_center = proposed_center;
                        set_scale();
                    }
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
                if (!Number.isFinite(control.value)) return;
                if (!control.value || !center_scale) return;
                let step = Math.pow(10, tickstep_magnitude[tickstep_index] + tickstep_power);
                tickstep_mult = (tickstep_power >= 0)? 1 : Math.round(Math.pow(10, -tickstep_power));
                tick_step = Math.round(step*tickstep_mult) / tickstep_mult;

                control.stepSize = tick_step / 50;
                control.minimumValue = true_center - tick_count * tick_step / 2;
                control.maximumValue = control.minimumValue + tick_count * tick_step;

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
