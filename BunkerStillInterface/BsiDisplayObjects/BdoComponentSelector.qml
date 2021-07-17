import QtQuick 2.15
import QtQuick.Controls 2.15

BdoButton_Text {
    id: componentNameButton
    text: "D"

    property Menu menu
    property string selected_name: ""

    onClicked: {
        let menu = build_component_menu();
        menu.open()
    }

    function generate_submenu_text(group, names) {
        var text;
        text = "import QtQuick 2.15\nimport QtQuick.Controls 2.15\n";
        text += "Menu {\n  title: \"" + group + "\"\n";
        for (let name of names) {
            text += "  MenuItem { text: \"" + name + "\"\n" +
                    "    onTriggered: {selected_name = text;}\n  }\n";
        }
        text += "}\n";
        // log.addMessage("Submenus:\n" + text);
        return text;
    }

    function build_component_menu() {
        let groups = componentStore.get_group_names();
        let grouped_names = componentStore.get_grouped_component_names();
        let text = "import QtQuick 2.15\nimport QtQuick.Controls 2.15\n  Menu{}\n";
        let menu = Qt.createQmlObject(text, componentNameButton);
        for (let group of groups) {
            let submenu = Qt.createQmlObject(generate_submenu_text(group, grouped_names[group]), menu);
            menu.addMenu(submenu);
        }
        return menu;
    }
}
