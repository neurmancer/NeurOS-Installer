import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    implicitWidth: 800; implicitHeight: 560
    Rectangle { anchors.fill: parent; color: "#090d14" }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 28; spacing: 16
        Text { text: "DEPLOYMENT / INPUT DECK"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 11; font.letterSpacing: 1 }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#523c70" }
        Text { text: "Tune your input deck."; color: "#f2edff"; font.family: "DejaVu Sans"; font.bold: true; font.pixelSize: 32; wrapMode: Text.Wrap; Layout.fillWidth: true }
        Text { text: "Pick your keyboard layout and variant. Test the selection below."; color: "#a5adbf"; font.pixelSize: 14; wrapMode: Text.Wrap; Layout.fillWidth: true }
        GridLayout {
            columns: 2; Layout.fillWidth: true; columnSpacing: 22; rowSpacing: 8
            Text { text: "KEYBOARD LAYOUT"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
            Text { text: "LAYOUT VARIANT"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
            DeckSelect { Layout.fillWidth: true; model: config.keyboardLayoutsModel; textRole: "label"; currentIndex: model.currentIndex; onActivated: model.currentIndex = index }
            DeckSelect { Layout.fillWidth: true; model: config.keyboardVariantsModel; textRole: "label"; currentIndex: model.currentIndex; onActivated: model.currentIndex = index }
        }
        Text { text: "KEYBOARD MODEL"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
        DeckSelect { Layout.fillWidth: true; model: config.keyboardModelsModel; textRole: "label"; currentIndex: model.currentIndex; onActivated: model.currentIndex = index }
        Text { text: "TEST TERMINAL"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
        TextField { Layout.fillWidth: true; placeholderText: "Signal check: type here to test your keyboard…"; selectByMouse: true }
        Text { text: "The test field uses the live session's current layout."; color: "#8e99ad"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
        Item { Layout.fillHeight: true }
    }
}
