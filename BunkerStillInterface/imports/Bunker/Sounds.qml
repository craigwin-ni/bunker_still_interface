pragma Singleton

import QtQuick 2.15
import QtMultimedia 5.15

Item {
    property var error: SoundEffect {
        id: error
        source: "../../sounds/beep-error.wav"
    }
    property var critical: SoundEffect {
        id: critical
        source: "../../sounds/smoke-detector-1.wav"
    }
}
