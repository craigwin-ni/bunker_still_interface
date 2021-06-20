import QtQuick 2.0
import QtQuick.Layouts 1.15
import "../BsiDisplayObjects"
import "../BsiProcessObjects"

Column {
    BpoDisplayUnitModel {
        id: displayUnitModel
        Component.onCompleted: {displayUnitModel.loadDisplayUnits();}
    }

    ListView {
        id: pageListView

        Layout.preferredHeight: count*100
        Layout.maximumWidth: 500
        Layout.minimumWidth: 320
        Layout.preferredWidth: parent.width

        clip: true
        currentIndex: -1
        model: displayUnitModel
        delegate: BdoDisplayUnitDelegate
    }

    BdoListNameAdder {
        listModel: pageModel
        addButtonText: "Add Display Unit"
        blankListEntry: ({
                "name": "",
                "url": "",
                "display_unit": {},
                "error": "",
                "modified": false,
                "in_stack": false,
                "pageable": false,
                "page_exists": false,
                "state": {}
                })
    }
}

