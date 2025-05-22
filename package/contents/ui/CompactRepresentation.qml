import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot

    onClicked: plasmoid.expanded = !plasmoid.expanded

    Kirigami.Icon {
        source: "headset"
        anchors.fill: parent

        // No receiver plugged in.
        Kirigami.Icon {
            visible: !headsetcontrol.present
            width: parent.width / 4
            height: parent.height / 4
            source: "emblem-error"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }

        // Receiver present, but no headset connected.
        Kirigami.Icon {
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
                        return Kirigami.Theme.positiveTextColor;
                    if (headsetcontrol.percent >= 70)
                        return Kirigami.Theme.neutralTextColor;
                    if (headsetcontrol.percent >= 50)
                        return Kirigami.Theme.neutralTextColor;
                    if (headsetcontrol.percent >= 30)
                        return Kirigami.Theme.neutralTextColor;
                    return Kirigami.Theme.negativeTextColor;
                }
                anchors.bottom: parent.bottom
                anchors.left: parent.left
            }

            // Headset present and charging or plugged-in and fully charged. We
            // can't really distinguish the two cases.
            Kirigami.Icon {
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