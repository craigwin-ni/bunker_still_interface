import QtQuick 2.0
import QtWebView 1.15

WebView {
    // set property url to the web page to be shown
    // set width and height to desired size
    onLoadingChanged: {
        if (loadRequest.errorString) {
            console.log("(E) " + loadRequest.errorString);
            log.addMessage("(E) " + loadRequest.errorString);
        }
    }
}
