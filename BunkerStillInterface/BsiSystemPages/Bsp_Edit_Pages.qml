import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import Bunker 1.0
import "../javascript/page_editor.js" as Peditjs
import "../BsiDisplayObjects"
import "../BsiProcessObjects"

ColumnLayout {

    BpoPageUnitModel {
        id: pageUnitModel
        Component.onCompleted: {pager.page_unit_model = pageUnitModel;}
    }

    Component {
        id: pageUnitDelegate
        BdoPageUnitDelegate {}
    }

    Connections {
        target: fileUtil
        function onPagesUpdated() {
            pageUnitModel.update_page_list();
        }
        function onPageUnitsUpdated() {
            pageUnitModel.update_page_unit_list();
        }
    }

    ListView {
        id: pageListView

        Layout.preferredHeight: count*30
        Layout.preferredWidth: 500

        clip: true
        visible: true
        currentIndex: -1
        model: pageUnitModel
        delegate: pageUnitDelegate
    }

    BdoListNameAdder {
        id: page_unit_adder
        addButtonText: "Add Display Unit"
        blankListEntry: Peditjs.blank_page_unit()

        onNewElementChanged: {
            base_unit_selector.model = pageUnitModel.bu_list;
            base_unit_selector.currentIndex = -1;
            baseUnitInfo.visible = true;
        }

        Row {
            id: baseUnitInfo
            visible: false

            Text {
                text: "BaseUnit:"
                font.pointSize: 11
            }

            ComboBox {
                id: base_unit_selector

                implicitHeight: 26
                implicitWidth: 180
                font.pointSize: 11
                font.family: "Arial"
                background: Rectangle {
                    color: base_unit_selector.currentIndex===-1? "lightgray" : Globals.textBgColor
                    border.width: 1
                    border.color: "grey"
                    radius: 5
                }

                onActivated: {
                    // copy pu so we don't send more NewElementChanged signals
                    let page_unit = JSON.parse(JSON.stringify(page_unit_adder.newElement));

                    page_unit.base_unit_name = editText;
                    page_unit.description = "New page unit";

                    let base_unit = pageUnitModel.base_units[page_unit.base_unit_name];
                    if (base_unit) {
                        if (base_unit.childs) {
                            page_unit.childs = [];
                        }
                        let extracted = Peditjs.extractStandins(base_unit);
                        page_unit.datas = extracted.datas;
                        page_unit.props = extracted.props;
                    } else {
                        log.addMessage("(C) Selected base unit '" + page_unit.base_unit_name +
                                       "' not in PageUnitModel")
                    }

                    baseUnitInfo.visible = false;
                    page_unit_adder.finishAdd(pageUnitModel, page_unit);
                }
            }

            BdoButton_Text {
                text: "Cancel"
                implicitHeight: 18
                font.pointSize: 10
                onClicked: {
                    baseUnitInfo.visible = false;
                    page_unit_adder.rejectAdd();
                }
            }
        }
    }
}

