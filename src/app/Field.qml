import QtQuick
import QtQuick.Controls
Column {
    id: field
    property string label: ""
    property alias text: input.text
    property alias placeholderText: input.placeholderText
    property bool secret: false
    spacing: 9
    Text { text: field.label.toUpperCase(); color: "#8c93a8"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10; font.letterSpacing: 1.3 }
    TextField {
        id: input; width: parent.width; height: 47
        color: "#edf0f6"; placeholderTextColor: "#636c80"
        font.pixelSize: 14; leftPadding: 14; selectByMouse: true
        echoMode: field.secret ? TextInput.Password : TextInput.Normal
        background: Rectangle { color: "#101620"; border.color: input.activeFocus ? "#b289f9" : "#303646" }
        Accessible.name: field.label
    }
}
