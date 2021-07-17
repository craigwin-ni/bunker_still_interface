import QtQuick 2.15
import QtQuick.Extras 1.4

Rectangle {
    id: led
    width: 25
    height: 25
    color: "black"

    property bool enable: false

    StatusIndicator {
        active: true  // we use enable to specify an off color as well as an on color
        anchors.centerIn: parent
        color: led.enable? "lightgreen": "#FF2030"
    }
}
