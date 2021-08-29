import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../BsiDisplayObjects"

ColumnLayout {
    id: connectionEditor

    width: parent.parent.width

    Component {
        id: connectionDelegate
        BdoConnectionDelegate {}
    }

    ListView {
        id: connectionView

        Layout.preferredHeight: count*100
        Layout.maximumWidth: 400
        Layout.minimumWidth: 320
        Layout.preferredWidth: parent.width

        clip: true
        currentIndex: -1
        model: connectionModel
        delegate: connectionDelegate
    }

    BdoListNameAdder {
        listModel: connectionModel
        addButtonText: "Add Connection"
        blankListEntry: ({
                "name": "",
                "address": "",
                "port": 0,
                "user": "",
                "password": ""
                })
    }
}
