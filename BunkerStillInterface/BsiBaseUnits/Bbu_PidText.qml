import QtQuick 2.15
import "../BsiDisplayObjects"

BbuPidBase {
//    property alias pid_enable_component: enable_component
    property int pid_label_width: 60

//===================================================
    function update_enable() {
        enable_field.input_text = enable_component.getValueText();
    }

    function update_pv() {
        pv_field.input_text = pv_component.getValueText();
    }

    function update_cv() {
        cv_field.input_text = cv_component.getValueText();
    }

    function update_pvName() {
        pvName_field.input_text = pvName_component.getValueText();
    }

    function update_cvName() {
        cvName_field.input_text = cvName_component.getValueText();
    }

    function update_sp() {
        sp_field.input_text = sp_component.getValueText();
    }

    function update_i_term() {
        i_term_field.input_text = i_term_component.getValueText();
    }

    function update_p_gain() {
        p_gain_field.input_text = p_gain_component.getValueText();
    }

    function update_i_gain() {
        i_gain_field.input_text = i_gain_component.getValueText();
    }

    function update_d_gain() {
        d_gain_field.input_text = d_gain_component.getValueText();
    }

    function update_d_beta() {
        d_beta_field.input_text = d_beta_component.getValueText();
    }

    function update_minCv() {
        minCv_field.input_text = minCv_component.getValueText();
    }

    function update_maxCv() {
        maxCv_field.input_text = maxCv_component.getValueText();
    }

//===================================================

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
