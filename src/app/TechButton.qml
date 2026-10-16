import QtQuick
import QtQuick.Controls
Button {
    id: control
    property bool primary: false
    implicitWidth: 168; implicitHeight: 46
    hoverEnabled: true
    font.family: "DejaVu Sans Mono"; font.pixelSize: 11; font.bold: true
    opacity: enabled ? 1 : 0.35
    contentItem: Text { text: control.text; font: control.font; color: control.primary ? "#090d12" : "#d5cee5"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
    background: Rectangle {
        color: control.primary ? (control.down ? "#9b6add" : control.hovered ? "#c4a0ff" : "#ac7bf5") : control.hovered ? "#242030" : "#10141d"
        border.color: control.activeFocus ? "#76f6bc" : control.primary ? "#c5a1ff" : "#373344"
        border.width: control.activeFocus ? 2 : 1
        Rectangle { width: 9; height: 9; rotation: 45; color: "#0a0d13"; anchors.right: parent.right; anchors.top: parent.top; anchors.rightMargin: -5; anchors.topMargin: -5 }
    }
    Accessible.name: text
}
