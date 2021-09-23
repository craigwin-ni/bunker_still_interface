import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import QtWebView 1.15
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
//        console.log("Writable directory count (should be 3): "+writable_dir_count);
        file_setup_timer.running = true;
    }

    Timer {
        id: file_setup_timer

        property int iteration: 0
        interval: 500

        onTriggered: {
            iteration += 1;
            switch (iteration) {
            case 1:
                fileUtil.check_writable_dir();
                running = true;
                break;
            case 2:
                connectionModel.loadConnections();
                running = true;
                break;
            default:
                break;
            }
        }
    }

    BpoFileUtil {id: fileUtil}
    BpoConnectionModel {id: connectionModel}
    BpoMqttClient {id: mqtt}
    BpoComponentStore {id: componentStore}

    BsiBanner {
        id: status_banner
        width: parent.width
    }

    SplitView {
        id: page_log_split_view
        orientation: Qt.Vertical
        anchors.top: status_banner.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        BsiPager {
            id: pager
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
