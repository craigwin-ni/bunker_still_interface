import QtQuick 2.15

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

    property string pid_basename: ""

    onEnable_componentChanged: {
        if (enable_component) {
            if (enable_component.name) {
                setup_pid()
            } else {
                enable_component.onNameChanged.connect(setup_pid);
            }

            enable_component.onValueChanged.connect(update_enable);
        }
    }

    function setup_pid() {
        let base_name = enable_component.name.slice(0, -7);
        pid_basename = base_name;
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
        first_read_timer.running = true;
        enable_component.onNameChanged.disconnect(setup_pid);
    }

//===================================================
    onPv_componentChanged:     if (pv_component)     pv_component.onValueChanged.connect(update_pv);
    onCv_componentChanged:     if (cv_component)     cv_component.onValueChanged.connect(update_cv);
    onPvName_componentChanged: if (pvName_component) pvName_component.onValueChanged.connect(update_pvName);
    onCvName_componentChanged: if (cvName_component) cvName_component.onValueChanged.connect(update_cvName);
    onSp_componentChanged:     if (sp_component)     sp_component.onValueChanged.connect(update_sp);
    onI_term_componentChanged: if (i_term_component) i_term_component.onValueChanged.connect(update_i_term);
    onP_gain_componentChanged: if (p_gain_component) p_gain_component.onValueChanged.connect(update_p_gain);
    onI_gain_componentChanged: if (i_gain_component) i_gain_component.onValueChanged.connect(update_i_gain);
    onD_gain_componentChanged: if (d_gain_component) d_gain_component.onValueChanged.connect(update_d_gain);
    onD_beta_componentChanged: if (d_beta_component) d_beta_component.onValueChanged.connect(update_d_beta);
    onMinCv_componentChanged:  if (minCv_component)  minCv_component.onValueChanged.connect(update_minCv);
    onMaxCv_componentChanged:  if (maxCv_component)  maxCv_component.onValueChanged.connect(update_maxCv);
//===================================================

    Timer {
        id: first_read_timer

        // This timer function insures that at least one value update is performed
        // on components that may never have a value change.

        property int restart_count: 5

        interval: 5000
        onTriggered: {
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
            if (restart_count > 0) restart();
        }
    }
}
