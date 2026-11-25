import QtQuick
import QtQuick.Controls

ComboBox {
    id: control
    implicitHeight: 42
    font.family: "DejaVu Sans"; font.pixelSize: 13
    contentItem: Text { leftPadding: 12; rightPadding: 30; text: control.displayText; color: "#eee8ff"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
    background: Rectangle { color: "#111823"; border.color: control.activeFocus ? "#79efb7" : "#514060" }
    indicator: Text { x: control.width - width - 12; anchors.verticalCenter: parent.verticalCenter; text: "▾"; color: "#b391e5" }
    delegate: ItemDelegate {
        required property int index
        width: control.width; text: control.textAt(index); highlighted: control.highlightedIndex === index
        contentItem: Text { text: parent.text; color: "#eee8ff"; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { color: parent.highlighted ? "#3a2a50" : "#111823" }
    }
    popup: Popup {
        y: control.height; width: control.width; implicitHeight: Math.min(contentItem.implicitHeight, 260); padding: 1
        contentItem: ListView { clip: true; implicitHeight: contentHeight; model: control.popup.visible ? control.delegateModel : null; currentIndex: control.highlightedIndex; ScrollBar.vertical: ScrollBar {} }
        background: Rectangle { color: "#111823"; border.color: "#704b9d" }
    }
}
