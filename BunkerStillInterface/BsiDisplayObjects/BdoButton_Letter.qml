import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

Button {
    id: button

    property int size: 25

    width: size
    height: size

    background: Rectangle {
        color: button.down ? Globals.buttonDownColor : Globals.buttonUpColor
        border.color: Globals.buttonBorderColor
        border.width: 1
        radius: 4
    }

    font.family: "Comic Sans MS"
    font.pixelSize: size - 4
}
