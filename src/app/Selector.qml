import QtQuick
import QtQuick.Controls
Column {
    id: selector
    property string label: ""
    property alias model: combo.model
    property alias currentIndex: combo.currentIndex
    property alias currentText: combo.currentText
    property alias textRole: combo.textRole
    signal chosen(int index)
    spacing: 9
    Text { text: selector.label.toUpperCase(); color: "#8c93a8"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10; font.letterSpacing: 1.3 }
    ComboBox {
        id: combo; objectName: selector.label; width: parent.width; height: 47
        font.pixelSize: 14; leftPadding: 14; rightPadding: 36
        palette.text: "#edf0f6"; palette.buttonText: "#edf0f6"; palette.base: "#151c29"; palette.highlight: "#67449a"; palette.highlightedText: "#ffffff"
        contentItem: Text {
            text: combo.displayText; font: combo.font; color: "#edf0f6"
            verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
        }
        indicator: Text {
            x: combo.width-width-14; y: (combo.height-height)/2
            text: combo.popup.visible ? "▴" : "▾"; color: "#bd93f7"; font.pixelSize: 18
        }
        background: Rectangle { color: "#101620"; border.color: combo.activeFocus || combo.popup.visible ? "#b289f9" : "#303646" }
        delegate: ItemDelegate {
            id: option
            required property int index
            width: combo.width-8; height: 42
            text: combo.textAt(index)
            highlighted: combo.highlightedIndex === index
            hoverEnabled: true
            contentItem: Text {
                text: option.text; font: combo.font
                color: option.highlighted || option.hovered ? "#ffffff" : "#d8deed"
                verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                leftPadding: 10; rightPadding: 10
            }
            background: Rectangle {
                color: option.highlighted || option.hovered ? "#382449" : "#131925"
                Rectangle { width: 3; height: parent.height; color: "#7bf1bd"; visible: option.highlighted }
            }
        }
        popup: Popup {
            y: combo.height+5; width: combo.width; padding: 4
            implicitHeight: Math.min(menu.contentHeight+8,260)
            background: Rectangle { color: "#131925"; border.color: "#9268c6" }
            contentItem: ListView {
                id: menu; clip: true; implicitHeight: contentHeight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex
                boundsBehavior: Flickable.StopAtBounds
                ScrollIndicator.vertical: ScrollIndicator {
                    contentItem: Rectangle { implicitWidth: 3; implicitHeight: 24; color: "#b48ae8"; radius: 1 }
                }
            }
        }
        onActivated: index => selector.chosen(index)
        Accessible.name: selector.label
    }
}
