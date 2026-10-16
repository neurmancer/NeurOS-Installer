import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: app
    width: 1280; height: 820; minimumWidth: 1060; minimumHeight: 720
    visible: true; title: "NeurOS // System installer"
    color: "#0a0d13"
    property int page: 0
    property int visited: 0
    property bool motion: true
    property bool allowClose: false
    property string language: "English (United States)"
    property string timezone: "Europe/Istanbul"
    property string keyboard: "English (US)"
    property int diskIndex: -1
    property string filesystem: "Btrfs"
    property string username: ""
    property string hostname: "neuros"
    property string password: ""
    property string confirmation: ""
    property bool axon: true
    property bool radioport: true
    property string notice: ""
    property var steps: ["Jack in", "Coordinates", "Input deck", "Storage", "Identity", "Final scan"]
    property var subtitles: ["Establish connection", "Your corner of the world", "Make every key count", "Choose your destination", "Make this machine yours", "One last look"]
    property bool diskValid: diskIndex >= 0 && diskIndex < host.disks.length
    property bool identityValid: host.validName(username) && host.validHostname(hostname) && password.length >= 8 && password === confirmation
    property bool canContinue: page === 3 ? diskValid : page === 4 ? identityValid : page === 5 ? diskValid && identityValid : true
    property string diskPath: diskIndex >= 0 && diskIndex < host.disks.length ? host.disks[diskIndex].path : "No drive selected"
    function next() { if (canContinue && page < 5) { page++; visited = Math.max(visited,page) } }
    function plan() { return {language:language,timezone:timezone,keyboard:keyboard,disk:diskPath,filesystem:filesystem,username:username,hostname:hostname,axon:axon,radioport:radioport} }
    onClosing: close => { if (!allowClose && page > 0) { close.accepted=false; quitDialog.open() } }
    Shortcut { sequence: "Alt+Right"; onActivated: app.next() }
    Shortcut { sequence: "Alt+Left"; onActivated: if(app.page>0) app.page-- }
    Shortcut { sequence: "Escape"; onActivated: quitDialog.open() }

    component Mono: Text { color: "#8892a6"; font.family: "DejaVu Sans Mono"; font.pixelSize: 10; font.letterSpacing: 1.1 }
    component Heading: Text { color: "#f0edf7"; font.family: "DejaVu Sans"; font.pixelSize: 35; font.bold: true; font.letterSpacing: -1.4 }
    component Body: Text { color: "#98a1b5"; font.pixelSize: 14; lineHeight: 1.45; wrapMode: Text.WordWrap }
    component Line: Rectangle { height: 1; color: "#262c39" }
    component Tile: Rectangle { color: "#10151f"; border.color: "#293040" }

    // Thin grid and registration marks echo the concept sheets without obscuring text.
    Canvas {
        anchors.fill: parent
        onPaint: {
            const c=getContext("2d");c.reset();c.strokeStyle="#111722";c.lineWidth=1;
            for(let x=0;x<width;x+=48){c.beginPath();c.moveTo(x,0);c.lineTo(x,height);c.stroke();}
            for(let y=0;y<height;y+=48){c.beginPath();c.moveTo(0,y);c.lineTo(width,y);c.stroke();}
        }
    }
    Rectangle { x: 0; y: 0; width: parent.width; height: 3; color: "#a677f2" }
    Rectangle {
        id: header; x: 0; y: 3; width: parent.width; height: 78; color: "#0c1018"
        Row {
            anchors.left: parent.left; anchors.leftMargin: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 16
            Image { source: "../branding/NeurOS/assets/mark.svg"; width: 38; height: 42; fillMode: Image.PreserveAspectFit }
            Column { spacing: 5; Text { text: "NeurOS"; color: "#f2eff9"; font.pixelSize: 22; font.bold: true; font.letterSpacing: 1 }
                Mono { text: "NEURO SOFTWARE DISTRIBUTION"; font.pixelSize: 8; font.letterSpacing: 1.4 } }
        }
        Row { anchors.right: parent.right; anchors.rightMargin: 30; anchors.verticalCenter: parent.verticalCenter; spacing: 22
            Mono { text: "SYSTEM UPLINK  /  01"; anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 116; height: 28; color: "#21172e"; border.color: "#66438e"
                Mono { anchors.centerIn: parent; text: "GUI PREVIEW"; color: "#c29afc"; font.pixelSize: 9 } }
        }
        Line { anchors.bottom: parent.bottom; width: parent.width }
    }
    Rectangle {
        id: sidebar; x: 0; y: header.y+header.height; width: 238; height: parent.height-y; color: "#0c1018"
        Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: "#262c39" }
        Mono { x: 30; y: 30; text: "INITIALIZATION SEQUENCE"; font.pixelSize: 9 }
        Column {
            x: 16; y: 72; width: parent.width-32; spacing: 7
            Repeater {
                model: app.steps
                delegate: Button {
                    id: stepButton
                    required property int index
                    required property string modelData
                    width: parent.width; height: 58
                    enabled: index <= app.visited && (index <= 3 || app.diskValid) && (index <= 4 || app.identityValid)
                    onClicked: app.page=index
                    background: Rectangle {
                        color: app.page===stepButton.index ? "#21192f" : stepButton.hovered ? "#151b27" : "transparent"
                        border.color: app.page===stepButton.index ? "#5d407d" : "transparent"
                        Rectangle { width: 3; height: parent.height; color: "#b384fc"; visible: app.page===stepButton.index }
                    }
                    contentItem: Row {
                        leftPadding: 15; spacing: 16
                        Text { anchors.verticalCenter: parent.verticalCenter; text: stepButton.index<app.page ? "✓" : "0"+(stepButton.index+1); color: stepButton.index<app.page ? "#73f5ba" : app.page===stepButton.index ? "#c49fff" : "#535e74"; font.family: "DejaVu Sans Mono"; font.pixelSize: 13 }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: stepButton.modelData; color: app.page===stepButton.index ? "#eee6fc" : "#9097a9"; font.pixelSize: 13 }
                    }
                    Accessible.name: modelData
                }
            }
        }
        Column {
            x: 30; anchors.bottom: parent.bottom; anchors.bottomMargin: 34; width: parent.width-60; spacing: 15
            Line { width: parent.width }
            Row { spacing: 8; Rectangle { width: 5; height: 5; radius: 3; color: "#72f4b6"; anchors.verticalCenter: parent.verticalCenter }
                Mono { text: "LOCAL LINK ACTIVE"; color: "#72f4b6"; font.pixelSize: 9 } }
            Mono { text: host.platform; font.pixelSize: 9; font.letterSpacing: 0; width: parent.width; wrapMode: Text.Wrap }
            NeonCheck { text: "Animate interface"; checked: app.motion; onToggled: app.motion=checked; palette.windowText: "#8791a6"; font.pixelSize: 11 }
            Mono { text: "NSD / BUILT TO BE YOURS"; font.pixelSize: 8; font.letterSpacing: 0.5 }
        }
    }
    Item {
        id: workspace; x: sidebar.width; y: header.y+header.height; width: parent.width-x; height: parent.height-y-98
        Column {
            x: 42; y: 29; width: parent.width-84; spacing: 10
            Row { width: parent.width
                Mono { text: "DEPLOYMENT / " + app.steps[app.page].toUpperCase(); color: "#a685cc"; width: parent.width-100 }
                Mono { text: "0"+(app.page+1)+" / 06"; horizontalAlignment: Text.AlignRight; width: 100 }
            }
            Row { width: parent.width; spacing: 5
                Repeater { model: 6; Rectangle { required property int index; width: (parent.width-25)/6; height: 2; color: index<=app.page ? "#a578e8" : "#252936" } }
            }
        }
        Loader {
            id: pageLoader; x: 42; y: 85; width: parent.width-84; height: parent.height-y-18
            sourceComponent: [welcome,location,keyboardPage,storage,identity,review][app.page]
            onLoaded: { item.opacity=0; reveal.restart() }
            NumberAnimation { id: reveal; target: pageLoader.item; property: "opacity"; from: 0; to: 1; duration: app.motion ? 230 : 0 }
        }
    }
    Rectangle {
        x: sidebar.width; y: parent.height-98; width: parent.width-x; height: 98; color: "#0c1018"
        Line { width: parent.width }
        Column { x: 42; anchors.verticalCenter: parent.verticalCenter; spacing: 7
            Mono { text: app.notice || (app.page===5 ? "DEPLOYMENT PLAN / FINAL SCAN" : "YOUR NEXT SYSTEM IS ON THE LINE"); color: "#a78bbd"; font.pixelSize: 9 }
            Text { text: "Preview mode · No changes are made to your disks."; color: "#768096"; font.pixelSize: 11 }
        }
        Row { anchors.right: parent.right; anchors.rightMargin: 42; anchors.verticalCenter: parent.verticalCenter; spacing: 12
            TechButton { text: app.page===0 ? "EXIT" : "←  BACK"; implicitWidth: 106; onClicked: app.page===0 ? quitDialog.open() : app.page-- }
            TechButton { text: app.page===0 ? "JACK IN   →" : app.page===5 ? "EXPORT PLAN   ↗" : "CONTINUE   →"; primary: true; enabled: app.canContinue
                onClicked: { if(app.page===5) { if(host.savePlan(app.plan())) app.notice="PLAN SAVED · PASSWORDS EXCLUDED" } else app.next() } }
        }
    }
    Component {
        id: welcome
        Item {
            Column { width: parent.width*.58; spacing: app.height < 780 ? 12 : 18
                Mono { text: "SIGNAL FOUND. HELLO, OPERATOR."; color: "#74efb8"; font.pixelSize: 11 }
                Heading { text: "Your machine.\nYour rules."; font.pixelSize: app.height < 780 ? 40 : 52; lineHeight: 1.05 }
                Body { width: parent.width-16; text: "A fresh system. A new signal. A desktop with a pulse.\nJack in. Make this machine unmistakably yours." }
                Row { spacing: 8
                    Repeater { model: ["LINUX FOUNDATION", "NEUROS SOUL"]
                        Rectangle { required property string modelData; width: tag.implicitWidth+20; height: 25; color: "#141c22"; border.color: "#2b3d3d"
                            Mono { id: tag; anchors.centerIn: parent; text: modelData; font.pixelSize: 8; color: "#92b5aa"; font.letterSpacing: 0.7 } }
                    }
                }
            }
            Reactor { anchors.right: parent.right; anchors.top: parent.top; anchors.topMargin: -17; width: parent.width*.41; height: app.height < 780 ? 235 : 290; animated: app.motion }
            Column { anchors.bottom: parent.bottom; width: parent.width; spacing: 18
                Row { width: parent.width; Mono { text: "YOUR SYSTEM LOADOUT"; width: parent.width-160; font.pixelSize: 9 }
                    Mono { text: "THREE PARTS. ONE SYSTEM."; font.pixelSize: 8; width: 160; horizontalAlignment: Text.AlignRight } }
                Row { width: parent.width; spacing: 12
                    Repeater { model: [ {n:"01",title:"A desktop, reimagined.",tag:"NEUROS INTERFACE",body:"Hyprland movement. A custom shell.\nEverything within reach."}, {n:"02",title:"Packages, without friction.",tag:"AXON",body:"A native front end for libalpm.\nYour software, under your control."}, {n:"03",title:"Give your terminal a voice.",tag:"RADIOPORT",body:"Your music library. Your queue.\nA soundtrack for the late hours."} ]
                        Tile { required property var modelData; width: (parent.width-24)/3; height: app.height < 780 ? 140 : 155
                            Column { anchors.fill: parent; anchors.margins: 18; spacing: 13
                                Row { width: parent.width; Mono { text: modelData.tag; color: "#b391e5"; font.pixelSize: 8; width: parent.width-22; font.letterSpacing: 0.4 }
                                    Mono { text: modelData.n; color: "#5b6479"; font.pixelSize: 9 } }
                                Text { text: modelData.title; color: "#e1e3eb"; font.pixelSize: 12; font.bold: true; width: parent.width; wrapMode: Text.WordWrap }
                                Body { text: modelData.body; font.pixelSize: 11; width: parent.width }
                            }
                        }
                    }
                }
                Mono { text: "+  OPEN BY DESIGN                                      PERSONAL BY DEFAULT  /  NSD"; font.pixelSize: 8; color: "#58657a" }
            }
        }
    }
    Component {
        id: location
        Column { spacing: 24
            Heading { text: "Set your coordinates." }
            Body { text: "Sync your corner of the grid. Choose your system language and time zone." }
            Line { width: parent.width }
            Row { spacing: 24; width: parent.width
                Selector { width: (parent.width-24)/2; label: "System language"; model: ["English (United States)","Türkçe","Deutsch","Français","Español"]; currentIndex: model.indexOf(app.language); onChosen: app.language=currentText }
                Selector { width: (parent.width-24)/2; label: "Time zone"; model: ["Europe/Istanbul","Europe/London","Europe/Berlin","America/New_York","America/Los_Angeles","Asia/Tokyo","UTC"]; currentIndex: model.indexOf(app.timezone); onChosen: app.timezone=currentText }
            }
            Tile { width: parent.width; height: 180
                Canvas { anchors.fill: parent; opacity: 0.5; onPaint: { const c=getContext("2d");c.strokeStyle="#526178";for(let x=0;x<width;x+=38){c.beginPath();c.moveTo(x,0);c.lineTo(x,height);c.stroke();}for(let y=0;y<height;y+=30){c.beginPath();c.moveTo(0,y);c.lineTo(width,y);c.stroke();} } }
                Column { anchors.centerIn: parent; spacing: 14
                    Mono { text: "CLOCK SYNC / TARGET ZONE"; anchors.horizontalCenter: parent.horizontalCenter; color: "#72f4b6" }
                    Heading { text: app.timezone; font.pixelSize: 30 }
                }
            }
            Body { text: "You can change both settings later in your installed system."; font.pixelSize: 12 }
        }
    }
    Component {
        id: keyboardPage
        Column { spacing: 24
            Heading { text: "Tune your input deck." }
            Body { text: "Pick your keymap. The test terminal below still uses your current live-session layout." }
            Selector { width: parent.width*.6; label: "Installed keyboard layout"; model: ["English (US)","English (UK)","Turkish (Q)","Turkish (F)","German","French"]; currentIndex: model.indexOf(app.keyboard); onChosen: app.keyboard=currentText }
            Field { width: parent.width; label: "Test terminal"; placeholderText: "Signal check: the quick brown fox jumps over the grid…" }
            Tile { width: parent.width; height: 155
                Column { anchors.centerIn: parent; spacing: 8
                    Repeater { model: ["Q W E R T Y U I O P", "A S D F G H J K L", "Z X C V B N M"]
                        Row { required property string modelData; spacing: 7; anchors.horizontalCenter: parent.horizontalCenter
                            Repeater { model: modelData.split(" ")
                                Rectangle { required property string modelData; width: 36; height: 30; color: "#191d2b"; border.color: "#41364f"; radius: 3
                                    Mono { anchors.centerIn: parent; text: modelData; color: "#c6b1e4" } }
                            }
                        }
                    }
                }
                Mono { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 10; text: "US REFERENCE"; font.pixelSize: 8 }
            }
        }
    }
    Component {
        id: storage
        Column { spacing: 23
            Heading { text: "Choose your landing zone." }
            Body { text: "Select a drive for your installation plan. Devices are detected read-only." }
            Selector { width: parent.width; label: host.disks.length ? "Destination drive" : "No writable disks detected"; model: host.disks; textRole: "label"; currentIndex: app.diskIndex; onChosen: index => app.diskIndex=index }
            Selector { width: parent.width*.5; label: "Preferred filesystem"; model: ["Btrfs","ext4"]; currentIndex: model.indexOf(app.filesystem); onChosen: app.filesystem=currentText }
            Tile { width: parent.width; height: 100
                Column { anchors.fill: parent; anchors.margins: 20; spacing: 13
                    Mono { text: "LAYOUT TO BE DEFINED BY THE INSTALLER"; color: "#c19bf2" }
                    Body { width: parent.width; text: "The plan records your preferred drive and filesystem. Partitioning, encryption and existing-data handling will be reviewed in Calamares before any installation."; font.pixelSize: 12 }
                }
            }
            Body { width: parent.width; text: "Nothing is formatted or mounted by this preview."; color: "#74d7ad"; font.pixelSize: 12 }
        }
    }
    Component {
        id: identity
        Column { spacing: 20
            Heading { text: "Register your identity." }
            Body { text: "Choose your handle. Name your node. Keep the access codes yours." }
            Row { width: parent.width; spacing: 22
                Field { width: (parent.width-22)/2; label: "Handle / username"; text: app.username; placeholderText: "neuro"; onTextChanged: app.username=text }
                Field { width: (parent.width-22)/2; label: "Node / machine name"; text: app.hostname; onTextChanged: app.hostname=text }
            }
            Row { width: parent.width; spacing: 22
                Field { width: (parent.width-22)/2; label: "Access code / password"; secret: true; text: app.password; placeholderText: "At least 8 characters"; onTextChanged: app.password=text }
                Field { width: (parent.width-22)/2; label: "Confirm access code"; secret: true; text: app.confirmation; onTextChanged: app.confirmation=text }
            }
            Body { width: parent.width; font.pixelSize: 12; color: app.canContinue ? "#74d7ad" : "#b5a4ce"
                text: app.canContinue ? "Identity details look good. Passwords are never included in the exported plan." : "Username: lowercase letters, numbers, hyphens or underscores; start with a letter or underscore. Machine name: letters, numbers and interior hyphens. Passwords must match and contain at least 8 characters." }
            Line { width: parent.width }
            Body { text: "Passwords stay in memory for this preview and are discarded when you close it."; font.pixelSize: 12 }
        }
    }
    Component {
        id: review
        Column { spacing: 17
            Heading { text: "Run the final scan." }
            Body { text: "Check your coordinates, identity and loadout. Export the plan when everything lines up." }
            Tile { width: parent.width; height: 164
                Column { anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Repeater { model: [ ["LOCATION", app.language+"  ·  "+app.timezone], ["KEYBOARD", app.keyboard], ["DESTINATION", app.diskPath+"  ·  "+app.filesystem], ["IDENTITY", (app.username || "Not configured")+" @ "+app.hostname] ]
                        Row { required property var modelData; width: parent.width
                            Mono { width: 135; text: modelData[0]; font.pixelSize: 9 }
                            Text { width: parent.width-135; text: modelData[1]; color: "#dedee9"; font.pixelSize: 12; elide: Text.ElideRight }
                        }
                    }
                }
            }
            Row { spacing: 24
                NeonCheck { text: "Include Axon"; checked: app.axon; onToggled: app.axon=checked; palette.windowText: "#dfd9eb" }
                NeonCheck { text: "Include Radioport"; checked: app.radioport; onToggled: app.radioport=checked; palette.windowText: "#dfd9eb" }
            }
            Body { width: parent.width; text: "NeurOS kernel and interface are part of the base experience. The installation backend is not connected yet; saving this plan does not install the system."; font.pixelSize: 12 }
            TechButton { text: "INSTALL NEUROS"; enabled: false; ToolTip.visible: hovered; ToolTip.text: "Available once Calamares integration is complete." }
        }
    }
    Dialog {
        id: quitDialog; title: "Disconnect from setup?"; anchors.centerIn: parent; modal: true; width: 390
        palette.windowText: "#ece6f4"; palette.text: "#ece6f4"; palette.buttonText: "#ece6f4"; palette.button: "#30213f"
        background: Rectangle { color: "#151b26"; border.color: "#745197" }
        standardButtons: Dialog.Yes | Dialog.No
        contentItem: Body { text: "Your unsaved choices will be discarded. No disks have been changed."; width: 350 }
        onAccepted: { app.password=""; app.confirmation=""; app.allowClose=true; app.close() }
    }
}
