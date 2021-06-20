import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../BsiDisplayObjects"

import MqttClient 1.0

MqttClient {
    id: mqtt_client

    signal connection_made
    signal connection_lost
    property bool connected
    property var connection: null

    property var password_dialog: Dialog {
        id: password_dialog
        y: 30
        parent: status_banner
        title: "Authorization Failed"
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true

        property alias password_text: passwordValue.text

        onVisibleChanged: {
            if (password_dialog.visible) {
                password_dialog.focus = true;
                passwordValue.focus = true;
            }
        }

        ColumnLayout {
            Text{
                font.pointSize: 11
                text: "A password may be required."
            }

            RowLayout {
                Text {
                    text: "Password:"
                    font.pointSize: 11
                }

                BdoTextField {
                    id: passwordValue
                    borderwidth: 2
                    Layout.minimumWidth: 100
                    text: connection? connection.password : ""
                    echoMode: TextInput.PasswordEchoOnEdit
                    width: 100

                    Keys.onReturnPressed: {event.accepted = true; password_dialog.accept();}
                    Keys.onEscapePressed: {event.accepted = true; password_dialog.reject();}
                }
            }
        }

        onAccepted: {
            connection.password = passwordValue.text;
            mqtt_client.connect(mqtt_client.connection);
        }

        onRejected: {
        }
    }

    function disconnect() {
        if (mqtt_client.state !== MqttClient.Disconnected) {
            mqtt_client.disconnectFromHost();
        }
        mqtt_client.connection = null;
    }

    function connect(connection) {
        mqtt_client.disconnect();

        mqtt_client.connection = connection;

        mqtt_client.hostname = mqtt_client.connection.address;
        mqtt_client.port = mqtt_client.connection.port;
        mqtt_client.username = mqtt_client.connection.user;
        mqtt_client.password = mqtt_client.connection.password;

        mqtt_client.connectToHost();
    }

    function reconnect() {
        mqtt_client.disconnect();
        reconnecting = true;
        mqtt_client.connectToHost();
    }

    function make_subscription(topic) {
        log.addMessage("BsiMqttClient requesting subscription to " + topic);
        return mqtt_client.subscribe(topic);
    }

    onStateChanged: {
        let state = mqtt_client.state;
        let msg = "";
        switch (state) {
        case 0:
            mqtt_client.connection_lost()
            mqtt_client.connected = false
            msg = "mqtt disconnected from " + mqtt_client.hostname;
            break;

        case 1:
            msg = "mqtt connecting to " + mqtt_client.hostname;
            break;

        case 2:
            mqtt_client.connection_made();
            mqtt_client.connected = true;
            msg = "mqtt connected to " + mqtt_client.hostname;
            break;
        }
        log.addMessage(msg);
    }

    onErrorChanged: {
        let err = mqtt_client.error;
        let msg = "";
        switch (err) {
        case 0:
            return;  // No error occurred
        case 1:
            msg = "MqttClient: The broker does not accept a connection using the specified protocol version.";
            break;
        case 2:
            msg = "MqttClient: The client ID is malformed. This might be related to its length.";
            break;
        case 3:
            msg = "MqttClient: The network connection has been established, but the service is unavailable on the broker side.";
            break;
        case 4:
            msg = "MqttClient: The data in the username or password is malformed.";
            break;
        case 5:
            msg = "MqttClient: The client is not authorized to connect.";
            mqtt_client.password_dialog.open();
            break;
        case 256:
            msg = "MqttClient: The underlying transport caused an error. For example, the connection might have been interrupted unexpectedly.";
            break;
        case 257:
            msg = "MqttClient: The client encountered a protocol violation, and therefore closed the connection.";
            break;
        case 258:
            msg = "MqttClient: An unknown error occurred.";
            break;
        case 259:
            msg = "MqttClient: An error is related to MQTT protocol level 5. A reason code might provide more details.";
            break;
        }

        if (err){
            log.addMessage(msg);
        }
    }
}

