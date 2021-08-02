import QtQuick 2.15
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import Bunker 1.0

Rectangle {
    id: gauge

    property var data_component                        // <sump_temp>
    property alias center_scale: _gauge.center_scale   // 60
    property alias min_range: _gauge.min_range         // 5
    property int size                                  // 75

    implicitWidth: size
    implicitHeight: size
    radius: size/2
    color: "#ffc"

    onData_componentChanged: {
        if (data_component) {
            data_component.onValueChanged.connect(_gauge.set_value);
            data_component.onValueChanged.connect(text_display.set_value);
        }
    }

    Rectangle {
        id: text_display

        anchors.top: parent.verticalCenter
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: size/8
        anchors.rightMargin: size/8
        anchors.bottomMargin: size/8

        function set_value() {
            text_field.text = data_component.getValueText(3);
        }

        Text {
            id: text_field
            anchors.centerIn: parent
            font.bold: true
        }
    }

    CircularGauge {
        id: _gauge

        property real data_value
        property real center_scale
        property real min_range

        anchors.fill:parent

        function set_value() {
            if (data_component) {
                data_value = data_component.value;
                value = data_component.value;
//                console.log("Gauge.set_value: " + value);
            }
        }

        stepSize: 0.1;
        minimumValue: center_scale - 50;
        maximumValue: center_scale + 50;

        style: CircularGaugeStyle {
            id: _gauge_style

            // internal properties
            readonly property real angle_range: 290
            readonly property int tick_count: 10
            readonly property real tick_angle: angle_range / tick_count

            property int tickstep_index: 0
            property int tickstep_power: 1
            property int tickstep_mult: 1
            readonly property var tickstep_magnitude: [Math.log10(1), Math.log10(2), Math.log10(5)]
            readonly property var minor_ticks: [4, 3, 4]

            property bool update_in_progress: false

            Component.onCompleted: {
                control.onData_valueChanged.connect(update_value);
                control.center_scale = 50;
                control.value = 50;
                control.minimumValue = 0;
                control.maximumValue = 100;
            }

            function update_value() {
                if (update_in_progress) {
                    return;
                }

                update_in_progress = true;

    //            let data_angle = valueToAngle(control.value);
                let data_angle = ((control.value-control.center_scale)
                                  / (control.maximumValue - control.minimumValue)
                                 * angle_range);
//                console.log("GaugeStyle.update_value: "
//                            +"value="+control.value
//                            +" tick_step="+tickmarkStepSize
//                            +" tick_angle="+tick_angle
//                            +" data_angle="+data_angle
//                            +"\n         value_range="+control.minimumValue+" to "+control.maximumValue
//                            +" center="+control.center_scale
//                            +"\n         angle_range="+minimumValueAngle+" to "+maximumValueAngle
//                            );
                if (Math.abs(data_angle) < tick_angle) {
                    decrease_range();
                    set_scale();
                } else if ((data_angle > maximumValueAngle - tick_angle)
                           || (data_angle < minimumValueAngle + tick_angle)) {
                    increase_range();
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
                var tick_step;
                let step = Math.pow(10, tickstep_magnitude[tickstep_index] + tickstep_power);
                tickstep_mult = tickstep_power >= 0? 1 : Math.round(Math.pow(10, -tickstep_power));
                tick_step = Math.round(step*tickstep_mult) / tickstep_mult;

                let range = tick_step * tick_count;
                if (range < min_range) {
                    increase_range();
                    return;
                }

                let adjust_value = -(control.center_scale % tick_step);
                if (-adjust_value > 0.5*tick_step) adjust_value += tick_step;
                let adjust_angle = tick_angle * adjust_value / tick_step;

                control.stepSize = tick_step / 100;
                control.minimumValue = control.center_scale - tick_count * tick_step / 2 + adjust_value;
                control.maximumValue = control.minimumValue + tick_count * tick_step;

                tickmarkStepSize = tick_step;
                labelStepSize = tick_step;
                minorTickmarkCount = minor_ticks[tickstep_index];

                minimumValueAngle = -(angle_range/2) + adjust_angle
                maximumValueAngle = angle_range/2 + adjust_angle

//                console.log("GaugeStyle.set_scale:"
//                            +" value="+control.value
//                            +" tick_step="+tick_step
//                            +" adjust_value=" + adjust_value
//                            +" adjust_angle="+adjust_angle
//                            +"\n         value_range="+control.minimumValue+" to "+control.maximumValue
//                            +" center="+control.center_scale
//                            +"\n         angle_range="+minimumValueAngle+" to "+maximumValueAngle);
            }

            tickmarkLabel: Text {
                text: Math.round(styleData.value*tickstep_mult) / tickstep_mult
            }
        }
    }
}
