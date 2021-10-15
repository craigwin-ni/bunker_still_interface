pragma Singleton

import QtQuick 2.15

//QtObject {
Item {
    property color mainBgColor: "ivory"

    property color textColor: "#000040"
    property color textBgColor: "lightyellow"
    property color textInputBgColor: Qt.darker("lightyellow", 1.05)
    property color textBorderColor: "darkslateblue"

    property color bulkTextColor: "#000040"
    property color bulkTextBgColor: "#fffff0"
    property color bulkTextBorderColor: "darkslateblue"

    property color buttonUpColor: "#ffefe0"
    property color buttonDownColor: "#f0e0d0"
    property color buttonBorderColor:"darkslateblue"

    property font label_font: Qt.font({family: "Veranda", pointSize: 10});
    property font data_font: Qt.font({family: "HP Simplified", weight: 50, pointSize: 10});
    property font title_font: Qt.font({family: "Veranda", weight: 50, pointSize: 14});
    property font subtitle_font: Qt.font({family: "Veranda", weight: 50, pointSize: 12});
    property int label_text_height:  30  // label_font_metrics.height
    property int data_text_height:  30  // data_font_metrics.height
    property int title_text_height: 40  // title_font_metrics.height
    property int subtitle_font_height: 35

    property real gridSpacing: 2
    property int indent_step: 18

//    FontMetrics {
//        id: data_font_metrics
//        font: data_font
//    }

//    FontMetrics {
//        id: label_font_metrics
//        font: label_font
//    }

//    FontMetrics {
//        id: title_font_metrics
//        font: title_font
//    }
}

