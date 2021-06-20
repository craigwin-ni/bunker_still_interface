import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: button

    background: Rectangle {
        color: button.down ? global.buttonDownColor : global.buttonUpColor
        border.color: global.buttonBorderColor
        border.width: 1
        radius: 4
    }
}
