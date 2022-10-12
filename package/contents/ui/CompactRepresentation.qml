import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

MouseArea {
    id: compactRoot

    onClicked: plasmoid.expanded = !plasmoid.expanded

    PlasmaCore.IconItem {
        source: "headset"
        anchors.fill: parent

        // No receiver plugged in.
        PlasmaCore.IconItem {
            visible: !headsetcontrol.present
            width: parent.width / 4
            height: parent.height / 4
            source: "emblem-error"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }

        // Receiver present, but no headset connected.
        PlasmaCore.IconItem {
            visible: headsetcontrol.present && !headsetcontrol.available
            width: parent.width / 4
            height: parent.height / 4
            source: "emblem-unavailable"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }

        Item {
            visible: headsetcontrol.available
            anchors.fill: parent

            // Headset present, not fully charged.
            Rectangle {
                visible: headsetcontrol.percent >= 0 && headsetcontrol.percent < 100
                height: 1
                width: (parent.width * headsetcontrol.percent) / 100
                color: {
                    if (headsetcontrol.percent >= 90)
                        return "green";
                    if (headsetcontrol.percent >= 70)
                        return "greenyellow";
                    if (headsetcontrol.percent >= 50)
                        return "lightgreen";
                    if (headsetcontrol.percent >= 30)
                        return "orange";
                    return "red";
                }
                anchors.bottom: parent.bottom
                anchors.left: parent.left
            }

            // Headset present and charging or plugged-in and fully charged. We
            // can't really distinguish the two cases.
            PlasmaCore.IconItem {
                visible: headsetcontrol.percent == -1 || headsetcontrol.percent == 100
                width: parent.width / 4
                height: parent.height / 4
                source: "emblem-mounted"
                anchors.bottom: parent.bottom
                anchors.right: parent.right
            }
        }
    }
}