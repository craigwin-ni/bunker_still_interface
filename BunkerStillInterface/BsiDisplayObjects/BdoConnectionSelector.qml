import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Extras 1.4
import Bunker 1.0

RowLayout{
    property alias connected_still: connectionSelector.connected_still

    spacing: -3

    ComboBox {
        id: connectionSelector

        property string connected_still: ""
        onCurrentTextChanged: { connectionSelector.connected_still = (currentIndex > 0)? currentText : "";}

        implicitHeight: 26
        implicitWidth: 180
        font.bold: true
        font.pointSize: 11
        font.family: "Arial"
        background: Rectangle {
            color: connectionSelector.currentIndex==0? "lightgray" : Globals.textBgColor
            border.width: 2
            border.color: "grey"
            radius: 5
        }

        model: ["Connect"].concat(connectionModel.connectionNames())

        Connections {  // Note: QML 'Connections' type is unrelated to Bsi MQTT connections.
            target: connectionModel

            function onConnectionsChanged(changed_name) {
                log.addMessage("onConnectionsChanged")

                let name = connectionSelector.currentText;
                let index = connectionSelector.currentIndex;

                let new_names = connectionModel.connectionNames();
                var new_index;

                if (index === 0) {
                    // if we weren't connected, we're still not connnected, but with new names
                    connectionSelector.model = ["Connect"].concat(new_names);
                } else {
                    // if we were connected, see if name is in list
                    new_index = new_names.findIndex((element) => element === name);
                    new_index += 1;
                    log.addMessage("old index="+index+" new_index="+new_index+" name="+name+" changed_name="+changed_name );
                    if (new_index) {
                        // We were connnected and connection is still available
                        if (!changed_name || changed_name === name) {
                            // The connection may have changed but we let the user do the reconnection.
                            log.addMessage("Possible change to " + connectionSelector.currentText);
                        }
                        connectionSelector.model = ["Disconnect"].concat(new_names);
                    } else {
                        // We were connected but connection was removed.
                        mqtt.disconnect();
                        log.addMessage("Disconnect from " + connectionSelector.currentText);
                        connectionSelector.model = ["Connect"].concat(new_names);
                    }
                    connectionSelector.currentIndex = new_index;
                }
            }
        }

        onActivated: {
            log.addMessage("Accepted: " + currentText + " (" + currentIndex + ")");
            // disconnect (may not actually be connected)
            mqtt.disconnect();
            log.addMessage("Disconnect from current connection (if any)");

            if (index == 0) {
                // We selected to Disconnect; prepare selecter with connect opeion
                model = ["Connect"].concat(connectionModel.connectionNames());
            } else {
                // Selected a connection; prepare selector with disconnect option
                mqtt.connect(connectionModel.get(index-1))
                log.addMessage("Connect to " + connectionModel.get(index-1).name);
                model = ["Disconnect"].concat(connectionModel.connectionNames());
            }
            currentIndex = index
        }
    }

    BdoLed {
        id: connectionLed
        implicitHeight: 26
        implicitWidth: 26
        radius: 5
        Connections {  // Note: QML 'Connections' type is unrelated to Bsi MQTT connections.
            target: mqtt
            function onConnectedChanged(connected) {
                connectionLed.enable = mqtt.connected
            }
        }
    }
}
