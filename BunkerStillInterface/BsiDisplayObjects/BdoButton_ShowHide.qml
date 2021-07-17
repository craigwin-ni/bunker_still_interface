import QtQuick 2.0

BdoButton_Symbol {
    property bool visibility: false

    size: 20
    button_type: "right"
    show_background: false

    onClicked: {
        visibility = !visibility;
        button_type = visibility? "down" : "right";
    }
}
