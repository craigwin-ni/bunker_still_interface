import QtQuick 2.15

ListModel {
    id: connectionModel

    property string connectionFile: "BSI/connections.json"

    signal connectionsChanged(string name)

    property var jsonIo: BpoJsonIo {
        id: jsonIo
        onJsonErrorChanged: {
            log.addMessage("Connections: " + jsonIo.jsonErrorMsg);
        }
    }

    function setConnection(index, jsobject) {
        let name = connectionModel.get(index).name
        connectionModel.set(index, jsobject);
        connectionsChanged(name);
    }

    // This function is called by ListNameAdder
    function addElement(jsobject) {
        // enforce no-underscore rule for connection name
        if (indexOf("_", jsobject.name) >=0) {
            jsobject.name = jsobject.name.replace(/_/, "=");
            log.addMessage("Connection name changed to '" + jsobject.name + "' to eliminate underscore");
        }

        // check for duplicate name and if so, modify name
        let new_name = jsobject.name;
        let instance_number = 0;
        let done = false;
        while (!done) {
            done = true;
            for (let i=0; i<connectionModel.count; i++) {
                let connection = connectionModel.get(i);
                if (new_name === connection.name) {
                    instance_number += 1;
                    new_name = jsobject.name + " (" + instance_number + ")";
                    done = false;
                }
            }
        }
        if (jsobject.name !== new_name) {
            jsobject.name = new_name;
            log.addMessage("Connection name changed to '" + jsobject.name + "' to avoid duplication");
        }

        connectionModel.append(jsobject);
        storeConnections();
        connectionsChanged(jsobject.name);
    }

    function removeConnection(index, n) {
        let name = connectionModel.get(index).name;
        connectionModel.remove(index, n);
        connectionsChanged(name);
    }

    function loadConnections() {
        let connections = jsonIo.loadJson(connectionFile);
        if (jsonIo.jsonError) return;

        connectionModel.clear();
        for (let name of Object.keys(connections)) {
            let connection = connections[name];
            if (!connection.password)
                connection.password = "";
            connectionModel.append(connection);
        }
        connectionsChanged("");
    }

    function storeConnections() {
        let connections = {};
        for (let i=0; i<connectionModel.count; i++) {
            let connection = JSON.parse(JSON.stringify(connectionModel.get(i)));
            connections[connection.name] = connection;
            connection.password = "";  // don't write passwords to disk
        }
        jsonIo.storeJson(connectionFile, connections);
    }

    function connectionNames() {
        let names = [];
        for (let i=0; i<connectionModel.count; i++) {
            names.push(connectionModel.get(i).name);
        }
        return names;
    }
}

//    ListElement {
//        name: "Still-5"
//        address: "192.168.0.195"
//        port: 1883
//        user: "admin"
//        password: ""
//    }
//    ListElement {
//        name: "Still-6"
//        address: "192.168.0.196"
//        port: 1883
//        user: "admin"
//        password: ""
//    }
//    ListElement {
//        name: "Stillsim"
//        address: "127.0.0.1"
//        port: 1883
//        user: "admin"
//        password: ""
//    }

