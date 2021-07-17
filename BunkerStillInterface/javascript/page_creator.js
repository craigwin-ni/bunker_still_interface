
var page_component;
var page_entry;
var prior_page;

function createPageObject(entry, displayed_page) {
    page_entry = entry;
    page_component = Qt.createComponent(page_entry.file, page_display);
    prior_page = displayed_page;

    let error = page_component.errorString();
    if (error) {
        log.addMessage("(E) Peditjs.createPageObject: page_component error: " + error);
    }

    if (page_component.status === Component.Ready) {
        finishPageCreation();
    } else {
        console.log("Connecting to statusChanged")
        page_component.statusChanged.connect(finishPageCreation);
    }
}

function finishPageCreation() {
    let page = page_component.createObject(page_display, {visible: false});
    if (page === null) {
        log.addMessage("Error creating page from " + page_file);
        return;
    }
    page_entry.page = page;
    if (prior_page) prior_page.visible = false;
    page.visible = true;
    pager.displayed_page = page_entry.file;
}

