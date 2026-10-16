import QtQuick
import calamares.slideshow 1.0
Presentation {
    id: presentation
    function onActivate() { currentSlide=0; advance.start() }
    function onLeave() { advance.stop() }
    Timer { id: advance; interval: 8000; repeat: true; onTriggered: presentation.goToNextSlide() }
    Slide {
        Rectangle { anchors.fill: parent; color: "#0a0d13"
            Image { source: "assets/wordmark.png"; width: parent.width*.75; height: parent.height*.5; fillMode: Image.PreserveAspectFit; anchors.horizontalCenter: parent.horizontalCenter; y: 10 }
            Column { anchors.horizontalCenter: parent.horizontalCenter; y: parent.height*.57; spacing: 20
                Text { text: "Your machine. Your rules."; color: "#e5d3ff"; font.pixelSize: 32; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "A Linux foundation. An unmistakably NeurOS experience."; color: "#98a1b5"; font.pixelSize: 15; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }
    }
    Slide {
        Rectangle { anchors.fill: parent; color: "#0a0d13"
            Column { anchors.centerIn: parent; width: parent.width*.8; spacing: 24
                Text { text: "MAKE ROOM FOR YOUR IDEAS"; color: "#76edb8"; font.pixelSize: 12; font.letterSpacing: 2 }
                Text { text: "A desktop with a pulse."; color: "#e5d3ff"; font.pixelSize: 34; font.bold: true }
                Text { width: parent.width; text: "NeurOS Interface brings a custom shell to Hyprland. Axon puts package management within reach. Radioport gives your terminal a soundtrack."; color: "#98a1b5"; font.pixelSize: 17; wrapMode: Text.WordWrap; lineHeight: 1.5 }
            }
        }
    }
}
