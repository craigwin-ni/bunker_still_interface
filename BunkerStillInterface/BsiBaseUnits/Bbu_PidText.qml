import QtQuick 2.0
import "../BsiDisplayObjects"

Item {
    property var enable_component: null
    property var pv_component: null
    property var cv_component: null
    property var pvName_component: null
    property var cvName_component: null
    property var sp_component: null
    property var i_term_component: null
    property var p_gain_component: null
    property var i_gain_component: null
    property var d_gain_component: null
    property var d_beta_component: null
    property var minCv_component: null
    property var maxCv_component: null

    property int pid_label_width: 60
    property string base_name

    onEnable_componentChanged: {
        if (enable_component) {
            enable_component.onValueChanged.connect(update_enable);
            first_read_timer.running = true;
        }
    }

    function update_enable() {
        if (!base_name && enable_component.name) base_name = enable_component.name.slice(0, -7);
        enable_field.input_text = enable_component.getValueText();
    }

    onBase_nameChanged: {
        pv_component = componentStore.get_component(base_name + "_process_value");
        cv_component = componentStore.get_component(base_name + "_control_value");
        pvName_component = componentStore.get_component(base_name + "_process_component");
        cvName_component = componentStore.get_component(base_name + "_control_component");
        sp_component = componentStore.get_component(base_name + "_set_point");
        i_term_component = componentStore.get_component(base_name + "_i_term");
        p_gain_component = componentStore.get_component(base_name + "_p_gain");
        i_gain_component = componentStore.get_component(base_name + "_i_gain");
        d_gain_component = componentStore.get_component(base_name + "_d_gain");
        d_beta_component = componentStore.get_component(base_name + "_d_beta");
        minCv_component = componentStore.get_component(base_name + "_min_cv");
        maxCv_component = componentStore.get_component(base_name + "_max_cv");
    }

//===================================================
    onPv_componentChanged: {
        if (pv_component) {
            pv_component.onValueChanged.connect(update_pv);
        }
    }

    function update_pv() {
        pv_field.input_text = pv_component.getValueText();
    }

//===================================================
    onCv_componentChanged: {
        if (cv_component) {
            cv_component.onValueChanged.connect(update_cv);
        }
    }

    function update_cv() {
        cv_field.input_text = cv_component.getValueText();
    }

//===================================================
    onPvName_componentChanged: {
        if (pvName_component) {
            pvName_component.onValueChanged.connect(update_pvName);
        }
    }

    function update_pvName() {
        pvName_field.input_text = pvName_component.getValueText();
    }

//===================================================
    onCvName_componentChanged: {
        if (cvName_component) {
            cvName_component.onValueChanged.connect(update_cvName);
        }
    }

    function update_cvName() {
        cvName_field.input_text = cvName_component.getValueText();
    }

//===================================================
    onSp_componentChanged: {
        if (sp_component) {
            sp_component.onValueChanged.connect(update_sp);
        }
    }

    function update_sp() {
        sp_field.input_text = sp_component.getValueText();
    }

//===================================================
    onI_term_componentChanged: {
        if (i_term_component) {
            i_term_component.onValueChanged.connect(update_i_term);
        }
    }

    function update_i_term() {
        i_term_field.input_text = i_term_component.getValueText();
    }

//===================================================
    onP_gain_componentChanged: {
        if (p_gain_component) {
            p_gain_component.onValueChanged.connect(update_p_gain);
        }
    }

    function update_p_gain() {
        p_gain_field.input_text = p_gain_component.getValueText();
    }

//===================================================
    onI_gain_componentChanged: {
        if (i_gain_component) {
            i_gain_component.onValueChanged.connect(update_i_gain);
        }
    }

    function update_i_gain() {
        i_gain_field.input_text = i_gain_component.getValueText();
    }

//===================================================
    onD_gain_componentChanged: {
        if (d_gain_component) {
            d_gain_component.onValueChanged.connect(update_d_gain);
        }
    }

    function update_d_gain() {
        d_gain_field.input_text = d_gain_component.getValueText();
    }

//===================================================
    onD_beta_componentChanged: {
        if (d_beta_component) {
            d_beta_component.onValueChanged.connect(update_d_beta);
        }
    }

    function update_d_beta() {
        d_beta_field.input_text = d_beta_component.getValueText();
    }

//===================================================
    onMinCv_componentChanged: {
        if (minCv_component) {
            minCv_component.onValueChanged.connect(update_minCv);
        }
    }

    function update_minCv() {
        minCv_field.input_text = minCv_component.getValueText();
    }

//===================================================
    onMaxCv_componentChanged: {
        if (maxCv_component) {
            maxCv_component.onValueChanged.connect(update_maxCv);
        }
    }

    function update_maxCv() {
        maxCv_field.input_text = maxCv_component.getValueText();
    }

//===================================================

    Timer {
        id: first_read_timer

        property int restart_count: 0

        interval: 5000
        onTriggered: {
            console.log("PidText first_restart_count triggered");
            update_enable();
            update_pv();
            update_cv();
            update_pvName();
            update_cvName();
            update_sp();
            update_i_term();
            update_p_gain();
            update_i_gain();
            update_d_gain();
            update_d_beta();
            update_minCv();
            update_maxCv();
            interval += 5000;
            restart_count -= 1;
            if (restart_count >= 0) restart();
        }
    }

    implicitWidth: pid_row.width
    implicitHeight: pid_row.height
    Row {
        id: pid_row
        Column {
            BdoTextLabeledField {
                id: enable_field
                label_text: "Enable"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: sp_field
                label_text: "SP"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: pv_field
                label_text: "PV"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: cv_field
                label_text: "CV"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: i_term_field
                label_text: "I_term"
                label_width: pid_label_width
                label_align: "right"
            }
        }
        Column {
            BdoTextLabeledField {
                id: p_gain_field
                label_text: "P_gain"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: i_gain_field
                label_text: "I_gain"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: d_gain_field
                label_text: "D_gain"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: d_beta_field
                label_text: "D_beta"
                label_width: pid_label_width
                label_align: "right"
            }
        }
        Column {
            BdoTextLabeledField {
                id: pvName_field
                label_text: "PV name"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: cvName_field
                label_text: "CV name"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: minCv_field
                label_text: "CV min"
                label_width: pid_label_width
                label_align: "right"
            }
            BdoTextLabeledField {
                id: maxCv_field
                label_text: "CV max"
                label_width: pid_label_width
                label_align: "right"
            }
        }
    }
}
