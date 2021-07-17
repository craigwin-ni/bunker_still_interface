import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

Button {
    id: button

    background: Rectangle {
        color: button.down ? Globals.buttonDownColor : Globals.buttonUpColor
        border.color: Globals.buttonBorderColor
        border.width: 1
        radius: 4
    }
}
