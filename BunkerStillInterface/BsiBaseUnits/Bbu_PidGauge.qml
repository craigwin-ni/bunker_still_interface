import QtQuick 2.15
import "../BsiDisplayObjects"
import Bunker 1.0

BbuPidBase {
    id: pid_gauge

    property int size

    property int pid_label_width: 60

    property bool enable
    property real sp
    property real pv
    property real cv
    property string pvName
    property string cvName
    property real i_term
    property real p_gain
    property real i_gain
    property real d_gain
    property real d_beta
    property var minCv
    property var maxCv
    property bool show_data: false
    property color background_color: "transparent"

    onMinCvChanged: {set_cv_scale();}
    onMaxCvChanged: {set_cv_scale();}

//===================================================
    function update_enable() {enable = enable_component.value;}
    function update_pv() {
        pv = pv_component.value;
        pv_field.input_text = pv_component.getValueText(6);
    }
    function update_cv() {
        cv = cv_component.value;
        cv_field.input_text = cv_component.getValueText(6);
    }
    function update_pvName() { pvName = pvName_component.value || 0;}
    function update_cvName() { cvName = cvName_component.value || 0;}
    function update_sp() {
        sp = sp_component.value || 0;
        sp_field.input_text = sp_component.getValueText(6);
    }
    function update_i_term() {
        i_term = i_term_component.value || 0;
        i_term_field.input_text = i_term_component.getValueText(6);
    }
    function update_p_gain() { p_gain = p_gain_component.value || 0;}
    function update_i_gain() { i_gain = i_gain_component.value || 0;}
    function update_d_gain() { d_gain = d_gain_component.value || 0;}
    function update_d_beta() { d_beta = d_beta_component.value || 0;}
    function update_minCv() { minCv = minCv_component.value || 0;}
    function update_maxCv() { maxCv = maxCv_component.value || 0;}
//===================================================
    function set_cv_scale() {
        if (!Number.isFinite(minCv) || !Number.isFinite(maxCv)) return;
        let range = (minCv===maxCv)? Math.min(0.8, maxCv) : maxCv - minCv;
        cv_gauge.min_range = range;
        function score_tick_count(ticks) {
            const base = 0.5;
            let step = range / ticks;
            let score = 0;
            for (let tick = 0; tick <= ticks; tick++) {
                let tick_value = Math.round((minCv + tick * step)*10000) / 10000;
                if (tick_value % base === 0) score += 1;
            }
            return score;
        }

        let best_score = 0;
        let best_tick_count = 8;
        for (let tick_count=8; tick_count>=2; tick_count-=1) {
            let score = score_tick_count(tick_count);
            if (score > best_score) {
                best_score = score;
                best_tick_count = tick_count;
            }
        }
        cv_gauge.tick_count = best_tick_count;
//        console.log("GaugePid.set_cv_scale return count="+best_tick_count+", score="+best_score);
    }

    implicitWidth: pid_row.width
    implicitHeight: pid_row.height
    Rectangle {
        id: background
        anchors.fill: parent
        visible: background_color !== "transparent"
        color: background_color
    }

    Row {
        id: pid_row

        Column {
            id: gauge_column

            padding: 4
            spacing: 4

            Rectangle {
                width: size
                height: header1.height + header2.height
                radius: 5
                border.color: "red"
                border.width: 2
                MouseArea {
                    anchors.fill:parent
                    onClicked: {show_data = !show_data;}
                }

                Text {
                    id: header1

                    text: pid_basename
                    width: size
                    font: Globals.subtitle_font
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    id: header2

                    y: header1.height
                    text: "PV: " + pvName + "\nCV: " + cvName
                    width: size
                    font: Globals.data_font
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAnywhere
                }
            }

            Rectangle {
                id: gauges

                width: size
                height: size

                Bbu_GaugeHalf {
                    id: pv_gauge

                    Component.onCompleted: {
                        pv_gauge.bg_color = "transparent";
                    }

                    data_component: pv_component
                    half: "top"
                    x: 0
                    y: 0
                    autoscale: true
                    center_scale: sp
                    dynamic_center: true
                    min_range: 4
                    size: pid_gauge.size
                }
                Bbu_GaugeHalf {
                    id: cv_gauge

                    Component.onCompleted: {
                        cv_gauge.bg_color = "transparent";
                    }

                    data_component: cv_component
                    half: "bottom"
                    x: 0
                    y: size/2
                    autoscale: false
                    center_scale: (maxCv + minCv) / 2
                    min_range: 8
                    size: pid_gauge.size
                    tick_count: 8
                }
                Canvas {
                    id: annotation

                    Component.onCompleted: {
                        pid_gauge.onPvChanged.connect(requestPaint);
                        pid_gauge.onCvChanged.connect(requestPaint);
                        requestPaint();
                    }

                    anchors.fill: parent

                    onPaint: {
                        let halfsize = size/2;
                        let ctx = getContext("2d");
                        ctx.reset();
                        ctx.translate(halfsize, halfsize); // Put origin to center of gauges.

                        // draw enable indicator
                        ctx.save();
                        ctx.beginPath();
                        ctx.ellipse(-9,-9,17,17);
                        ctx.fillStyle = pid_gauge.enable? "#20c020": "#c02020";
                        ctx.fill();
                        ctx.restore();

                        // draw set_point marker
                        ctx.save();
                        ctx.globalAlpha = 0.5;
                        ctx.rotate(value_to_angle(sp, pv_gauge));
                        ctx.beginPath();
                        ctx.moveTo(-halfsize, 5);
                        ctx.lineTo(-halfsize+10, 0);
                        ctx.lineTo(-halfsize, -5);
                        ctx.closePath();
                        ctx.fillStyle = "#f00000";
                        ctx.fill();
                        ctx.restore();

                        // draw indicator arcs
                        ctx.save();
                        ctx.globalAlpha = 0.5
                        ctx.lineWidth = halfsize * 0.4;
                        let radius = halfsize * 0.8;

                        // draw cv arcs, these are on bottom gauge so angle is negative
                        ctx.save();

                        // do i_term arc
                        ctx.beginPath();
                        let effective_i_term = (i_term<minCv)? minCv : (i_term>maxCv)? maxCv : i_term;
                        let arc_angle1 = Math.PI - value_to_angle(effective_i_term, cv_gauge);
                        ctx.arc(0,0, radius, Math.PI, arc_angle1, true);
                        ctx.strokeStyle = "#06ff06";
                        ctx.stroke();

                        // do proportional arc
                        ctx.beginPath();
                        let final_value = i_term + p_gain * (sp-pv);
                        final_value = (final_value<minCv)? minCv : (final_value>maxCv)? maxCv : final_value;
                        let arc_angle2 = Math.PI - value_to_angle(final_value, cv_gauge);
                        if(arc_angle1 !== arc_angle2) {
                            ctx.arc(0,0, radius, arc_angle1, arc_angle2, arc_angle1>arc_angle2);
                            ctx.strokeStyle = arc_angle2<arc_angle1 ? "#ff0606" : "#4000ff";
                            ctx.stroke();
                        }
                        ctx.restore();

                        // do pv/sp arc
                        if (Math.abs(pv-sp)/sp > 0.0001) {
                            ctx.save();
                            ctx.beginPath();
                            arc_angle1 = Math.PI + value_to_angle(sp, pv_gauge);
                            arc_angle2 = Math.PI + value_to_angle(pv, pv_gauge);
                            ctx.arc(0,0, radius, arc_angle1, arc_angle2, arc_angle1>arc_angle2);
                            ctx.strokeStyle = arc_angle2>arc_angle1 ? "#ff0606" : "#4000ff";
                            ctx.stroke();
                            ctx.restore();
                        }

                        ctx.restore();
                    }

                    function value_to_angle(value, gauge) {
                        // Convert value to angle rotation in radians;
                        // assume range of 180 degrees (Pi radians).
                        let min_value = gauge.gauge_min_value;
                        let angle = (value-min_value) / (gauge.gauge_max_value - min_value) * Math.PI;
                        return isFinite(angle)? angle : 0;
                    }
                }
            }
        }

        Column {
            id: text_column1

            visible: show_data

            BdoTextField {
                text: "Settings"
                width: pid_label_width * 2
                readOnly: true
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            BdoTextLabeledField {
                id: p_gain_field
                label_text: "P_gain"
                label_width: pid_label_width
                label_align: "right"
                input_text: "" +p_gain
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update p_gain to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.p_gain_component.setValue(new_gain);
                }
            }
            BdoTextLabeledField {
                id: i_gain_field
                label_text: "I_gain"
                label_width: pid_label_width
                label_align: "right"
                input_text: "" +i_gain
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update i_gain to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.i_gain_component.setValue(new_gain);
                }
            }
            BdoTextLabeledField {
                id: d_gain_field
                label_text: "D_gain"
                label_width: pid_label_width
                label_align: "right"
                input_text: "" +d_gain
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update d_gain to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.d_gain_component.setValue(new_gain);
                }
            }
            BdoTextLabeledField {
                id: d_beta_field
                label_text: "D_beta"
                label_width: pid_label_width
                label_align: "right"
                input_text: "" +d_beta
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update d_beta to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.d_beta_component.setValue(new_gain);
                }
            }
            BdoTextLabeledField {
                id: minCv_field
                label_text: "CV min"
                label_width: pid_label_width
                label_align: "right"
                input_text: "" +minCv
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update CV_min to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.minCv_component.setValue(new_gain);
                }
            }
            BdoTextLabeledField {
                id: maxCv_field
                label_text: "CV max"
                label_width: pid_label_width
                label_align: "right"
                input_text: "" +maxCv
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update CV_max to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.maxCv_component.setValue(new_gain);
                }
            }
        }

        Column {
            id: text_column2

            visible: show_data

            BdoTextField {
                text: "Data values"
                width: pid_label_width * 2
                readOnly: true
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            BdoTextLabeledField {
                id: sp_field
                label_text: "SP"
                label_width: pid_label_width
                label_align: "right"
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update set_point to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.sp_component.setValue(new_gain);
                }
            }
            BdoTextLabeledField {
                id: pv_field
                label_text: "PV"
                label_width: pid_label_width
                label_align: "right"
                read_only: true
            }
            BdoTextLabeledField {
                id: cv_field
                label_text: "CV"
                label_width: pid_label_width
                label_align: "right"
                read_only: true
            }
            BdoTextLabeledField {
                id: i_term_field
                label_text: "I_term"
                label_width: pid_label_width
                label_align: "right"
                read_only: false

                onInput_ready: {
                    let new_gain = Number(input_text);
                    if (!input_text.trim() || !isFinite(new_gain)) {
                        log.addMessage("(E) Invalid setting input: '"+input_text+"'");
                        return;
                    }
                    log.addMessage("Update i_term to "+new_gain);
                    // XXX Release this code when input_ready
                    // pid_gauge.i_term_component.setValue(new_gain);
                }
            }
        }
    }
}
