import QtQuick
import QtQuick.Controls
CheckBox {
    id: control
    spacing: 9; padding: 0
    indicator: Rectangle {
        implicitWidth: 18; implicitHeight: 18
        x: control.leftPadding; y: (control.height-height)/2
        color: control.checked ? "#242036" : "#101620"
        border.color: control.activeFocus ? "#75f4b7" : control.checked ? "#b184ee" : "#485065"
        Text { anchors.centerIn: parent; text: "✓"; color: "#8cf7c4"; font.pixelSize: 13; visible: control.checked }
    }
    contentItem: Text { text: control.text; color: "#a3aabd"; font.pixelSize: 12; leftPadding: control.indicator.width+control.spacing; verticalAlignment: Text.AlignVCenter }
}
