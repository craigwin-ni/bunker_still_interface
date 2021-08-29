import QtQuick 2.15

Column {

    signal moveUp
    signal moveDown

    spacing: -1

    BdoButton_Symbol {
        property bool visibility: false

        size: 13
        padding: 0
        font.pixelSize: 15
        font.bold: true
        button_type: "up"

        onClicked: {
            moveUp();
        }
    }
    BdoButton_Symbol {
        property bool visibility: false

        size: 13
        padding: 0
        font.pixelSize: 15
        font.bold: true
        button_type: "down"

        onClicked: {
            moveDown();
        }
    }
}
