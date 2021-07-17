import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

Button {
    id: button

    property int size: 25
    property string button_type: "up"
    property bool show_background: true

    width: size
    height: size

    background: Rectangle {
        visible: show_background
        color: button.down ? Globals.buttonDownColor : Globals.buttonUpColor
        border.color: Globals.buttonBorderColor
        border.width: 1
        radius: 4
    }

    font.family: "Webdings"
    font.pixelSize: size - 4
    text: type_character()

    function type_character() {
        switch (button_type) {
        case "left": return "3";
        case "right": return "4";
        case "up": return "5";
        case "down": return "6";
        case "X":
            background.color = "#ff7860";
            return "r";
        default: return "s"
        }
    }
}
