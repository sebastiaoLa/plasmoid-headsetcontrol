import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ColumnLayout {
    id: fullRoot

    Layout.fillHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical

    PlasmaExtras.Heading {
        Layout.fillWidth: true
        level: 3
        wrapMode: Text.WordWrap
        text: headsetcontrol.model
    }

    PlasmaComponents.Label {
        id: headsetStatus
        text: headsetcontrol.status
    }

    RowLayout {
        id: featureSidetone
        visible: headsetcontrol.features.includes("s")

        Layout.fillWidth: true

        PlasmaComponents.Slider {
            id: featureSidetoneValue
            Layout.fillWidth: true
            from: 0
            to: 128
            value: 16
            wheelEnabled: true
            stepSize: 1.0

            ToolTip {
                text: featureSidetoneValue.value.toFixed()
            }
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set sidetone")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -s ' + featureSidetoneValue.value.toFixed())
        }
    }

    RowLayout {
        id: featureLights
        visible: headsetcontrol.features.includes("l")

        Layout.fillWidth: true

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Enable lights")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -l 1')
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Disable lights")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -l 0')
        }
    }

    RowLayout {
        id: featureVoicePrompt
        visible: headsetcontrol.features.includes("v")

        Layout.fillWidth: true

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Enable voice prompt")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -v 1')
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Disable voice prompt")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -v 0')
        }
    }

    RowLayout {
        id: featureRotateToMute
        visible: headsetcontrol.features.includes("r")

        Layout.fillWidth: true

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Enable rotate-to-mute")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -r 1')
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Disable rotate-to-mute")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -r 0')
        }
    }

    // Separate DataSource for non-polling commands. No signal here since we
    // don't expect any output.
    PlasmaCore.DataSource {
        id: headsetCommand
        engine: "executable"
        connectedSources: []
        onNewData: {
            var stdout = data["stdout"].trim();
            var code = data["exit code"];
            console.log("headsetCommand code: " + code + ", output: " + stdout);

            disconnectSource(sourceName); // cmd finished
        }
        
        function exec(cmd) {
            connectSource(cmd);
        }
    }
}