import QtQuick
Item {
    id: reactor
    property bool animated: true
    property real phase: 0
    NumberAnimation on phase { from: 0; to: 360; duration: 48000; loops: Animation.Infinite; running: reactor.animated }
    onPhaseChanged: dial.requestPaint()
    Canvas {
        id: dial; anchors.fill: parent
        onPaint: {
            const c = getContext("2d"), w=width, h=height, r=Math.min(w,h)*0.40;
            c.reset(); c.translate(w/2,h/2);
            c.lineWidth=1;
            for(let i=0;i<80;i++) {
                let a=i*Math.PI/40;
                c.strokeStyle=i%5===0 ? "#74718d" : "#323044";
                c.beginPath();c.moveTo(Math.cos(a)*r,Math.sin(a)*r);c.lineTo(Math.cos(a)*(r+(i%5===0?12:5)),Math.sin(a)*(r+(i%5===0?12:5)));c.stroke();
            }
            c.strokeStyle="#363046";c.beginPath();c.arc(0,0,r-15,0,Math.PI*2);c.stroke();
            c.save();c.rotate(reactor.phase*Math.PI/180);
            c.strokeStyle="#b083f9";c.lineWidth=3;c.beginPath();c.arc(0,0,r-25,0,Math.PI*1.2);c.stroke();
            c.strokeStyle="#6af4b5";c.lineWidth=2;c.beginPath();c.arc(0,0,r-33,Math.PI*1.15,Math.PI*1.9);c.stroke();c.restore();
            c.strokeStyle="#594174";c.lineWidth=1;
            for(let k=0;k<3;k++){
                c.beginPath(); for(let i=0;i<=6;i++){let a=i*Math.PI/3+Math.PI/6;let rr=r*(0.47+k*.055);let x=Math.cos(a)*rr,y=Math.sin(a)*rr;if(i===0)c.moveTo(x,y);else c.lineTo(x,y);}c.stroke();
            }
            c.strokeStyle="#272e3c";
            for(let i=-1;i<=1;i+=2){c.beginPath();c.moveTo(i*(r+22),0);c.lineTo(i*(w/2),0);c.stroke();}
        }
    }
    Text { anchors.centerIn: parent; text: "N"; color: "#d8baff"; font.family: "DejaVu Sans"; font.bold: true; font.italic: true; font.pixelSize: 92 }
    Text { anchors.horizontalCenter: parent.horizontalCenter; y: parent.height*.79; text: "N E U R A L   C O R E"; color: "#6af4b5"; font.family: "DejaVu Sans Mono"; font.pixelSize: 9 }
}
