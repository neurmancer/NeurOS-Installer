// Shared visual study, not enabled as a Calamares navigation controller.
// Calamares uses its native widget sidebar until its context API is integrated.
import QtQuick
Rectangle {
    color: "#0c1018"; implicitWidth: 238; implicitHeight: 600
    Image { source: "assets/mark.svg"; width: 92; height: 92; anchors.horizontalCenter: parent.horizontalCenter; y: 40 }
    Text { text: "NEUROS / SYSTEM SETUP"; color: "#b58af1"; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter; y: 160 }
}
