import QtQuick 2.15

ListModel {
    // Models children of a page unit
    property var page_unit

    onPage_unitChanged: {
        update_model();
    }

    function update_model() {
        clear();

        if (!page_unit || !page_unit.childs) return;
        let childs = page_unit.childs;
        for (let i_child=0; i_child<childs.length; i_child++) {
            append({"child_index": i_child});
        }
    }
}
