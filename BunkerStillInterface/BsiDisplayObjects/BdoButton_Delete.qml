import QtQuick 2.15
import QtQuick.Controls 2.15
import Bunker 1.0

BdoButton_Symbol {
    id: delete_button

    property string check_name: "this"

    signal verified
    signal canceled

    button_type: "X"

    BdoDialog_Verify {
        id: verify_dialog

        parent: delete_button
        align: "right"
        title: "Verify Delete"
        dialog_text: "Delete '" + check_name + "'?"

        onAccepted: {verified();}
        onRejected: {canceled();}
    }

    onClicked: {verify_dialog.open();}
}
