import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import Bunker 1.0
import "./BsiDisplayObjects"

BdoTextBulk {
    id: log_display

    property date dttm: new Date()
    property var locale: Qt.locale()
    property int char_limit: 10000

    text_width: parent.width

    function addMessage(msg)
    {
        log_display.text += "\n" + dttm.toLocaleString(locale, "yyMMdd-HHmmss") + ": " + msg;
        if (msg.startsWith("(C)")) {
            color = "red";
            Sounds.critical.play();
        } else if (msg.startsWith("(E)")) {
            color = "orange";
            Sounds.error.play();
        } else if (msg.startsWith("(W)")) {
            color = "yellow";
        } else {
            color = Globals.bulkTextBgColor;
        }

        if (log_display.text.length > char_limit) {
            // Make new text the tail of the current text.
            log_display.text = log_display.text.slice(-char_limit);
        }

        log_display.scroll_to_bottom();
    }
}

