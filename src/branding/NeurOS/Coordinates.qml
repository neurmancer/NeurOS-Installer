import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 800; implicitHeight: 560
    property string selectedRegion: config.currentTimezoneCode.split('/')[0]
    Rectangle { anchors.fill: parent; color: "#090d14" }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 28; spacing: 16
        Text { text: "DEPLOYMENT / COORDINATES"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 11; font.letterSpacing: 1 }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#523c70" }
        Text { text: "Set your coordinates."; color: "#f2edff"; font.family: "DejaVu Sans"; font.bold: true; font.pixelSize: 32; wrapMode: Text.Wrap; Layout.fillWidth: true }
        Text { text: "Sync your corner of the grid. Choose your system language and time zone."; color: "#a5adbf"; font.pixelSize: 14; wrapMode: Text.Wrap; Layout.fillWidth: true }
        GridLayout {
            columns: 2; Layout.fillWidth: true; columnSpacing: 22; rowSpacing: 8
            Text { text: "SYSTEM LANGUAGE"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
            Text { text: "REGIONAL FORMATS"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
            DeckSelect {
                Layout.fillWidth: true; model: config.supportedLocales
                currentIndex: Math.max(0, model.indexOf(config.currentLanguageCode))
                onActivated: config.currentLanguageCode = currentText
            }
            DeckSelect {
                Layout.fillWidth: true; model: config.supportedLocales
                currentIndex: Math.max(0, model.indexOf(config.currentLCCode))
                onActivated: config.currentLCCode = currentText
            }
            Text { text: "REGION"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
            Text { text: "TIME ZONE"; color: "#b391e5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
            DeckSelect {
                id: regions; Layout.fillWidth: true; model: config.regionModel; textRole: "name"; valueRole: "key"
                Component.onCompleted: { let i = indexOfValue(root.selectedRegion); if (i >= 0) currentIndex = i; config.regionalZonesModel.region = root.selectedRegion; zones.syncSelection() }
                onActivated: { root.selectedRegion = currentValue; config.regionalZonesModel.region = currentValue; zones.currentIndex = 0; if (zones.count) config.setCurrentLocation(root.selectedRegion, zones.currentValue) }
            }
            DeckSelect {
                id: zones; Layout.fillWidth: true; model: config.regionalZonesModel; textRole: "name"; valueRole: "key"
                function syncSelection() { let key = config.currentTimezoneCode.substring(root.selectedRegion.length + 1); let i = indexOfValue(key); currentIndex = i }
                onActivated: config.setCurrentLocation(root.selectedRegion, currentValue)
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 100
            color: "#101620"; border.color: "#30394b"
            Column { anchors.centerIn: parent; spacing: 12
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "CLOCK SYNC / TARGET ZONE"; color: "#72efb6"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: config.currentTimezoneName; color: "#eee8ff"; font.pixelSize: 24; font.bold: true }
            }
        }
        Text { text: "You can change these settings later in your installed system."; color: "#8e99ad"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
    }
}
