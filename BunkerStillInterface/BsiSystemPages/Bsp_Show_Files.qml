import QtQuick 2.15
import Qt.labs.folderlistmodel 2.15
import "../BsiDisplayObjects"

Column {
    id: filesPage

    property alias url: fileView.url

    padding: 10

    Row {
        height: 30

        BdoTextField {
            readOnly: true
            text: "URL: "
        }
        BdoTextField {
            readOnly: false
            text: "."
            onEditingFinished: {
                filesPage.url = text;
                countField.text = "  Count=" + fileView.count;
            }
        }
        BdoTextField {
            id: countField
        }

    }

    ListView {
        id: fileView

        property alias url: folderModel.folder

        width: 200; height: 400

        FolderListModel {
            id: folderModel

            folder: "."
            nameFilters: ["*"]
        }

        Component {
            id: fileDelegate
            Text { text: filePath }
        }

        model: folderModel
        delegate: fileDelegate
    }
}
