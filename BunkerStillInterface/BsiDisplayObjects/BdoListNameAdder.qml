import QtQuick 2.0

Row {
    id: listNameAdder

    property var listModel
    property var blankListEntry: ({"name": null})
    property string addButtonText: "Add Name"

    function acceptNewListName() {
        addButton.visible = true;
        addNameInfo.visible = false;
        newListName.focus = false;

        let name = newListName.text.trim();
        if (!name) return;
        let new_element = JSON.parse(JSON.stringify(blankListEntry));
        new_element.name = name;
        listModel.addElement(new_element);
    }

    function rejectNewList() {
        addButton.visible = true;
        addNameInfo.visible = false;
    }

    Keys.onReturnPressed: {
        acceptNewListName();
        event.accepted = true;
    }
    Keys.onEscapePressed: {
        rejectNewList()
        event.accepted = true;
    }

    BdoButton {
        id: addButton
        text: addButtonText;
        implicitHeight: 20
        font.pointSize: 11
        activeFocusOnTab: false

        anchors.verticalCenter: parent.Center

        onClicked: {
            addNameInfo.visible = true;
            addButton.visible = false;
            newListName.focus = true;
        }
    }

    Row {
        id: addNameInfo
        visible: false

        Text {
            text: "Name:"
            font.pointSize: 11
        }

        BdoTextField {
            id: newListName
            implicitWidth: 100
        }

        BdoButton {
            text: "Continue"
            implicitHeight: 18
            font.pointSize: 10

            onClicked: {
                listNameAdder.acceptNewListName();
            }
        }

        BdoButton {
            text: "Cancel"
            implicitHeight: 18
            font.pointSize: 10
            onClicked: {
                listNameAdder.rejectNewList();
            }
        }
    }
}
