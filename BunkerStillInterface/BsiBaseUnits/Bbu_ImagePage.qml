import QtQuick 2.15
import Bunker 1.0
import "../BsiDisplayObjects"

Rectangle {
    id: image_page

    property string image_name: "Still-5_index"
    readonly property real in_factor: Math.SQRT2
    readonly property real out_factor: 1/in_factor

    implicitHeight: page_image.height
    implicitWidth: page_image.width

    color: Globals.mainBgColor
    border.color: Globals.bulkTextBorderColor
    border.width: 2

    Component.onCompleted: view_full_image();

    function view_1to1() {
        page_image.width = page_image.implicitWidth
        page_image.height = page_image.implicitHeight
    }
    function view_full_image() {
        let scale = Math.min(page_view.width / page_image.implicitWidth,
                             page_view.height / page_image.implicitHeight);
        page_image.width = page_image.implicitWidth * scale;
        page_image.height = page_image.implicitHeight * scale;
    }

    MouseArea {
        visible: false
        property bool printing: false
        property real prior_x: 0
        property real prior_y: 0

        anchors.fill: parent
        hoverEnabled: true

        onEntered: printing = true;
        onExited: printing = false;

        onPositionChanged: if (visible && printing) print_mouse(mouse, false);
        onClicked: if (visible && printing) print_mouse(mouse, true);

        function print_mouse(mouse, save) {
            let x = (mouse.x/page_image.width).toPrecision(4);
            let y = (mouse.y/page_image.height).toPrecision(4);
            if (save) {
                prior_x = x;
                prior_y = y;
            }
            location_text.text = ("prior X:"+prior_x + " Y:"+prior_y
                                  +"\ncurrent:"+x + "  :"+y
                                  +"\ndelta  :"+(x-prior_x).toPrecision(4) + "  :"+(y-prior_y).toPrecision(4)
                                 );
        }

        Text {
            id: location_text
            x: page_view.contentX+30
            y: page_view.contentY+2
        }

    }

    Column {
        x: page_view.contentX+2
        y: page_view.contentY+2

        BdoButton_Letter {
            id: zoom_in
            text: "+"

            onClicked: {
                page_image.width *= in_factor
                page_image.height *= in_factor
            }
        }
        BdoButton_Letter {
            id: zoom_out
            text: "-"

            onClicked: {
                page_image.width *= out_factor
                page_image.height *= out_factor
            }
        }
        BdoButton_Text {
            id: one_to_one
            text: "1:1"
            leftPadding: 5
            rightPadding: 4
            onClicked: view_1to1();
        }
        BdoButton_Letter {
            id: view_full
            text: "F"
            onClicked: view_full_image();
        }
    }

    Image {
        id: page_image
        source: "../images/" + image_name + ".png"
        anchors.centerIn: parent
    }
}
