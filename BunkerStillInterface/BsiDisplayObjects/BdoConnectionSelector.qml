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

        property string requested_still: ""
        property string connected_still: ""

        implicitHeight: 26
        implicitWidth: 157
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
                var new_index = new_names.indexOf(name) +1;

                console.log("ConnectionSelector: old index="+index+" new_index="+new_index
                            +" name="+name+" changed_name="+changed_name );

                if (index === 0) {
                    // if we weren't connected, we're still not connnected, but with new names
                    connectionSelector.model = ["Connect"].concat(new_names);
                } else {
                    // if we were connected, see if name is in list
//                    new_index = new_names.findIndex((element) => element === name);
//                    new_index = new_names.indexOf(name);
//                    new_index += 1;
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
                        index = 0;
                    }
//                    connectionSelector.currentIndex = new_index;
                    connected_still = index === 0? "" : name; //connectionModel.connectionNames()[index-1];
                }
            }
        }

        onConnected_stillChanged: {
            let index = Math.max(0, model.indexOf(connected_still));
            currentIndex = model.indexOf(connected_still);
        }

        onActivated: {
            log.addMessage("Accepted: " + currentText + " (" + currentIndex + ")");
            // disconnect (may not actually be connected)
            mqtt.disconnect();
            log.addMessage("Disconnect from current connection (if any)");

            if (index == 0) {
                // We selected to Disconnect; prepare selecter with connect opeion
                model = ["Connect"].concat(connectionModel.connectionNames());
                connected_still = "";
            } else {
                // Selected a connection; prepare selector with disconnect option
                mqtt.connect(connectionModel.get(index-1))
                log.addMessage("Connect to " + connectionModel.get(index-1).name);
                model = ["Disconnect"].concat(connectionModel.connectionNames());
                requested_still = connectionModel.connectionNames()[index-1];
            }
//            currentIndex = index;  // changing model resets index to 0
//            if (index == 0) selected_still = "";
//            else requested_still =
//            requested_still = index === 0? "" : connectionModel.connectionNames()[index-1];
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
                connectionSelector.connected_still = connectionSelector.requested_still;
            }
        }
    }
}
