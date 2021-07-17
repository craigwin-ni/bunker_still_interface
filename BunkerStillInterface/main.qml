import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Bunker 1.0
import "BsiProcessObjects"

Window {
    id: main_window
    objectName: "main_window"
    width: 480
    height: 640
    visible: true
    title: qsTr("Bunker Distillation Systems")

    Component.onCompleted: {
        connectionModel.loadConnections();
    }

    BpoConnectionModel {id: connectionModel}
    BpoMqttClient {id: mqtt}
    BpoComponentStore {id: componentStore}

    BsiBanner {
        id: status_banner
        width: parent.width
    }

    SplitView {
        orientation: Qt.Vertical
        anchors.top: status_banner.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        BsiPager {
            width: parent.width
            SplitView.fillHeight: true
        }

        BsiLog {
            id: log

            onHeightChanged: {
                if (height === SplitView.minimumHeight) log.scroll_to_bottom();
            }

            implicitWidth: parent.width
            height: 35
            SplitView.minimumHeight: 35
            text: "Log messages"
        }
    }
}
