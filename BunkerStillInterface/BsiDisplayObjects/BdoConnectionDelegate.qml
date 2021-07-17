import QtQuick 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0

Item {
    id: delegateItem

    required property string name
    required property string address
    required property string port
    required property string user
    required property string password
    required property int index

    height: 100

    Keys.onReturnPressed: {
        editDisposition.acceptEdit();
        event.accepted = true;
    }
    Keys.onEscapePressed: {
        editDisposition.rejectEdit()
        event.accepted = true;
    }

    Rectangle {
        id: background

        height: 100
        width: connectionView.width
        color: "lightpink"
        radius: 5
        border.color: Globals.bulkTextBorderColor
        border.width: 1

        Connections {  // Note: QML 'Connections' type is unrelated to Bsi MQTT connections.
            target: connectionView
            function onCurrentIndexChanged() {
                if (connectionView.currentIndex === background.parent.index) {
                    background.color = "lightsteelblue";
                } else {
                    background.color = "lightpink"
                    addressValue.readOnly = true;
                    portValue.readOnly = true;
                    userValue.readOnly = true;
                    passwordValue.readOnly = true;
                }
            }
        }
    }

    GridLayout {
        columns: 4
        x: 10; y: 10;
        z: 1

        Text {
            text: delegateItem.name
            font.bold: true; font.pointSize: 12
        }

        Row {
            spacing: 2
            BdoButton_Text {
                id: editButton
                text: "Edit"
                implicitHeight: 15
                font.pointSize: 10
                activeFocusOnTab: false

                onClicked: {
                    connectionView.currentIndex = delegateItem.index;
                    addressValue.readOnly = false;
                    portValue.readOnly = false;
                    userValue.readOnly = false;
                    passwordValue.readOnly = false;
                    editButton.visible = false;
                    removeButton.visible = false;
                    okButton.visible = true;
                    cancelButton.visible = true;
                    addressValue.focus = true;

//                    connectionModel.storeConnections();  // Why was this here?
                }
            }
            BdoButton_Text {
                id: removeButton
                text: "Remove"
                implicitHeight: 15
                font.pointSize: 10
                activeFocusOnTab: false

                onClicked: {
                    connectionView.currentIndex = delegateItem.index;
                    editButton.visible = false;
                    removeButton.visible = false;
                    confirmButton.visible = true;
                    cancelRemoveButton.visible = true;
                }
            }
            BdoButton_Text {
                id: confirmButton
                text: "Confirm"
                implicitHeight: 15
                font.pointSize: 10
                activeFocusOnTab: false
                visible: false
                onClicked: {
                    if (delegateItem.index >= 0) {
                        connectionModel.removeConnection(index, 1);
                        connectionModel.storeConnections();
                    }
                    connectionView.currentIndex = -1;

                    confirmButton.visible = false;
                    cancelRemoveButton.visible = false;
                    editButton.visible = true;
                    removeButton.visible = true;
                }
            }
            BdoButton_Text {
                id: cancelRemoveButton
                text: "Cancel"
                implicitHeight: 15
                font.pointSize: 10
                visible: false
                activeFocusOnTab: false
                onClicked: {
                    connectionView.currentIndex = -1;
                    confirmButton.visible = false;
                    cancelRemoveButton.visible = false;
                    editButton.visible = true;
                    removeButton.visible = true;
                }
            }
        }

        Row {
            id: editDisposition

            spacing: 2

            function acceptEdit() {
                connectionView.currentIndex = -1;
                connectionModel.setConnection(
                        delegateItem.index,
                        {
                            "address": addressValue.text,
                            "port": Number(portValue.text),
                            "user": userValue.text,
                            "password": passwordValue.text
                        });
                addressValue.readOnly = true;
                portValue.readOnly = true;
                userValue.readOnly = true;
                passwordValue.readOnly = true;
                editButton.visible = true;
                removeButton.visible = true;
                okButton.visible = false;
                cancelButton.visible = false;
                passwordValue.focus = false;

                connectionModel.storeConnections();
            }

            function rejectEdit() {
                connectionView.currentIndex = -1;
                addressValue.text = delegateItem.address
                portValue.text = delegateItem.port
                userValue.text = delegateItem.user
                passwordValue.text = delegateItem.password
                addressValue.readOnly = true;
                portValue.readOnly = true;
                userValue.readOnly = true;
                passwordValue.readOnly = true;
                editButton.visible = true;
                removeButton.visible = true;
                okButton.visible = false;
                cancelButton.visible = false;
                passwordValue.focus = false;
            }

            BdoButton_Text {
                id: okButton
                text: "OK"
                implicitHeight: 15
                font.pointSize: 10
                visible: false
                activeFocusOnTab: false

                onClicked: {
                    editDisposition.acceptEdit();
                }
            }
            BdoButton_Text {
                id: cancelButton
                text: "Cancel"
                implicitHeight: 15
                font.pointSize: 10
                visible: false
                activeFocusOnTab: false

                onClicked: {
                    editDisposition.rejectEdit();
                }
            }
        }

        Text {text: " "}  // Fill two empty cells in GridLayout
        Text {text: " "}

        BdoTextField {
            text: "Address:"
            readOnly: true
            activeFocusOnTab: false
        }
        BdoTextField {
            id: addressValue
            text: delegateItem.address
            readOnly: true
            Layout.minimumWidth: 100
        }
        BdoTextField {
            text: "Port:"
            readOnly: true
            activeFocusOnTab: false
        }
        BdoTextField {
            id: portValue
            text: delegateItem.port
            readOnly: true
            Layout.minimumWidth: 100
        }
        BdoTextField {
            text: "Username:"
            readOnly: true
            activeFocusOnTab: false
        }
        BdoTextField {
            id: userValue
            text: delegateItem.user
            readOnly: true
            Layout.minimumWidth: 100
        }
        BdoTextField {
            text: "Password:"
            readOnly: true
            activeFocusOnTab: false
        }
        BdoTextField {
            id: passwordValue
            text: delegateItem.password
            echoMode: TextInput.PasswordEchoOnEdit
            readOnly: true
            Layout.minimumWidth: 100
        }
    }
}
