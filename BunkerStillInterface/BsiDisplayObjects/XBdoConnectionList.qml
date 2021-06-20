import QtQuick 2.0
import QtQuick.Layouts 1.15

Rectangle {
    id: connectionEditor

    color: "lightgrey"

    Component {
        id: connectionDelegate

        Item {
            id: delegateItem

            required property string name
            required property string address
            required property string port
            required property string user
            required property string password
            required property int index

            width: connectionView.width
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
                x: 2; y: 2; width: parent.width - 2*x; height: parent.height - 2*y
                color: "ivory"
                radius: 5

                Connections {  // Note: QML 'Connections' type is unrelated to Bsi MQTT connections.
                    target: connectionView
                    function onCurrentIndexChanged() {
                        if (connectionView.currentIndex === background.parent.index) {
                            background.color = "lightsteelblue";
                        } else {
                            background.color = "ivory"
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
                    BdoButton {
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

                            connectionModel.storeConnections();
                        }
                    }
                    BdoButton {
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
                    BdoButton {
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
                    BdoButton {
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

                    BdoButton {
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
                    BdoButton {
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
    }

    ListView {
        id: connectionView

        width: parent.width
        anchors.top: parent.top
        anchors.bottom: connectionAdder.top

        clip: true
        currentIndex: 0
        model: connectionModel
        delegate: connectionDelegate
    }

    Row {
        id: connectionAdder
        width: parent.width
        anchors.bottom: parent.bottom

        function acceptNewConnection() {
            addButton.visible = true;
            addConnectionInfo.visible = false;
            newConnectionName.focus = false;

            let name = newConnectionName.text.trim();
            if (!name) return;
            connectionModel.appendConnection({
                    "name": name,
                    "address": "",
                    "port": 0,
                    "user": "",
                    "password": ""
                    });
            connectionModel.storeConnections();
        }
        function rejectNewConnection() {
            addButton.visible = true;
            addConnectionInfo.visible = false;
        }

        Keys.onReturnPressed: {
            acceptNewConnection();
            event.accepted = true;
        }
        Keys.onEscapePressed: {
            rejectNewConnection()
            event.accepted = true;
        }

        BdoButton {
            id: addButton
            text: "Add Connection";
            implicitHeight: 20
            font.pointSize: 11
            activeFocusOnTab: false

            anchors.verticalCenter: parent.Center

            onClicked: {
                addConnectionInfo.visible = true;
                addButton.visible = false;
                newConnectionName.focus = true;
            }
        }

        Row {
            id: addConnectionInfo
            visible: false

            Text {
                text: "Name:"
                font.pointSize: 11
            }

            BdoTextField {
                id: newConnectionName
                implicitWidth: 100
            }

            BdoButton {
                text: "Continue"
                implicitHeight: 18
                font.pointSize: 10

                onClicked: {
                    connectionAdder.acceptNewConnection();
                }
            }

            BdoButton {
                text: "Cancel"
                implicitHeight: 18
                font.pointSize: 10
                onClicked: {
                    connectionAdder.rejectNewConnection();
                }
            }
        }
    }
}
