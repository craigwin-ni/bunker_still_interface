import QtQuick 2.15
import "../javascript/name_util.js" as Nutiljs

Row {
    id: listNameAdder

    property var listModel: null
    property var blankListEntry: ({"name": null})
    property string addButtonText: "Add Name"
    property var newElement: null

    function continueAdd() {
        let name = newListName.text.trim();
        if (!Nutiljs.is_name(name)) {
            log.addMessage("(E) Invalid character in name '" + name + "'");
            return;
        }

        addNameInfo.visible = false;
        newListName.focus = false;
        if (!name) {
            addButton.visible = true;
            return;
        }

        blankListEntry.name = name;
        newElement = blankListEntry;  // change signals parent of element readiness

        if (listModel) {
            finishAdd(listModel, newElement);
        }
    }

    function finishAdd(theModel, element) {
        theModel.addElement(element);
        addButton.visible = true;
    }

    function rejectAdd() {
        addButton.visible = true;
        addNameInfo.visible = false;
    }

    Keys.onReturnPressed: {
        continueAdd();
        event.accepted = true;
    }
    Keys.onEscapePressed: {
        rejectAdd()
        event.accepted = true;
    }

    BdoButton_Text {
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

        BdoButton_Text {
            text: "Continue"
            implicitHeight: 18
            font.pointSize: 10

            onClicked: {
                listNameAdder.continueAdd();
            }
        }

        BdoButton_Text {
            text: "Cancel"
            implicitHeight: 18
            font.pointSize: 10
            onClicked: {
                listNameAdder.rejectAdd();
            }
        }
    }
}
