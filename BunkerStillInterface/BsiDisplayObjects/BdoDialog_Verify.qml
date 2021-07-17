import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

Dialog {
    id: verify_dialog

    property alias dialog_text: verify_text.text

    property string align: "center"

    onAboutToShow: {
        set_alignment(align);
    }

    function set_alignment(alignment) {
        if (!parent) return;

        switch (alignment) {
        case "right": x = parent.width - verify_dialog.width; break;
        case "left": x = 0; break;
        default: x = parent.width/2 - width/2; break;  //   "center" and anything else...
        }
    }

    title: "Verify"
    y: parent.height
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true

    Text {
        id: verify_text
        text: "Verified? "
        font: Globals.label_font
    }
}

