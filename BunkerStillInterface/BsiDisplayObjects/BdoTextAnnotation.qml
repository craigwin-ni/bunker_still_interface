import QtQuick 2.15

Rectangle {
    id: annotation_rect

    property var annobj: ({})  // annotation object
    property int precision: 4
    property bool hover: false

    property string labels: ""
    property var data_components: []
    property bool update_required: true

    property var pid_popup: null
    property string popup_text: ""

    Component.onCompleted: {
        precision = annobj.precision || 4;
        hover = annobj.hover || false;
        let anntype = annobj.pid_name? "pid" : "standard";
        if (anntype === "pid") setup_pid();
        else setup_standard();
        update_timer.start();
    }
    function setup_standard() {
        let display_list = annobj.display_list;
        for (let i=0; i<display_list.length; i++) {
            if (i) labels += "\n";
            labels += display_list[i][0];
            let data_component = componentStore.get_component(display_list[i][1]);
            data_components.push(data_component);
            data_component.onValueChanged.connect(set_update_flag);
        }
    }
    function setup_pid() {
        let pid_name = annobj.pid_name;
        labels = "enable\nSP\nPV\nCV";
        for (let suffix of ["_enable", "_set_point", "_process_value", "_control_value"]) {
            let data_component = componentStore.get_component(pid_name+suffix);
            data_components.push(data_component);
            data_component.onValueChanged.connect(set_update_flag);
        }
        popup_text = "import QtQuick 2.15\nimport \"../BsiBaseUnits\"\n"
                    +"Bbu_PidGauge {\nid: gauge\n"
                    +"x:annotation_rect.x>parent.width/2?parent.width-width-20:20\n"
                    +"y:annotation_rect.y>250?annotation_rect.y-240:annotation_rect.y+annotation_rect.height+10\n"
                    +"z:1\nsize: 150\nshow_data:true\nbackground_color:\"#f0ffffff\"\n"
                    +"Component.onCompleted: {enable_component = componentStore.get_component(\""
                    +pid_name+"_enable\");}\n"
                    +"MouseArea {\nanchors.fill: parent\ndrag.target: gauge\n"
                    +"onClicked: {gauge.visible = false;}\n}}";
    }

    Timer {
        id: update_timer

        interval:1500
        repeat: true
        onTriggered: {
            if (update_required) {
                update_required = false;
                update_data_text();
            }
        }
    }

    function set_update_flag() {update_required = true;}
    function update_data_text() {
        let text = "";
        for (let i=0; i<data_components.length; i++) {
            if (i) text += "\n";
            text += data_components[i].getValueText(precision);
        }
        data_text.text = text;
    }

    function generate_pid_popup() {
        let popup = Qt.createQmlObject(popup_text, annotation_rect.parent);
        if (!popup) {
            log.addMessage("(E) Failed to create pid popup for '" + annobj.pid_name
                           + "'. QML:" + popup_text);
        }
        return popup;
    }

    x: annobj.x * parent.width
    y: annobj.y * parent.height
    implicitWidth: label_text.width + data_text.width + 6
    implicitHeight: label_text.height
    color: "#b0FFFFFF"

    Text {
        id: label_text
        text: labels
    }
    Text {
        id: data_text
        x: label_text.width + 6
    }

    MouseArea {
        anchors.fill: parent;
        onClicked: {
            if (annobj.pid_name) {
                if (!pid_popup) pid_popup = generate_pid_popup();
                pid_popup.visible = true;
            }
        }
    }
}
