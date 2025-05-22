import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

ColumnLayout {
    id: fullRoot

    //Layout.fillHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical

    Kirigami.Heading {
        Layout.fillWidth: true
        level: 3
        wrapMode: Text.WordWrap
        text: headsetcontrol.model
    }

    PlasmaComponents.Label {
        id: headsetStatus
        text: headsetcontrol.status_text
    }

    // Why there is no separator Component built-in is beyond me.
    Item {
        height: headsetStatus.height

        Layout.fillWidth: true

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right

            // same as MenuItem background
            implicitWidth: Kirigami.Units.gridUnit * 8
            implicitHeight: 1
            color: Kirigami.Theme.textColor
            opacity: 0.2
        }
    }

    RowLayout {
        id: featureSidetone
        visible: headsetcontrol.features.includes("s")

        Layout.fillHeight: false
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

        Layout.fillHeight: false
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

        Layout.fillHeight: false
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

        Layout.fillHeight: false
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

    // ChatMix controls
    RowLayout {
        id: featureChatMix
        visible: headsetcontrol.features.includes("c")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Slider {
            id: featureChatMixValue
            Layout.fillWidth: true
            from: 0
            to: 128
            value: 64
            wheelEnabled: true
            stepSize: 1.0

            ToolTip {
                text: featureChatMixValue.value.toFixed()
            }
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set ChatMix")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' --chatmix ' + featureChatMixValue.value.toFixed())
        }
    }

    // Equalizer preset controls
    RowLayout {
        id: featureEqualizer
        visible: headsetcontrol.features.includes("e")

        Layout.fillHeight: false
        Layout.fillWidth: true

        ComboBox {
            id: equalizerPreset
            Layout.fillWidth: true
            model: [i18n("Flat"), i18n("Bass Boost"), i18n("Treble Boost"), i18n("Custom")]
            currentIndex: 0
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set EQ Preset")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' --equalizer-preset ' + equalizerPreset.currentIndex)
        }
    }

    // Microphone volume control
    RowLayout {
        id: featureMicVolume
        visible: headsetcontrol.features.includes("m")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Slider {
            id: micVolumeValue
            Layout.fillWidth: true
            from: 0
            to: 100
            value: 50
            wheelEnabled: true
            stepSize: 1.0

            ToolTip {
                text: micVolumeValue.value.toFixed() + "%"
            }
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set Mic Volume")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' --microphone-volume ' + micVolumeValue.value.toFixed())
        }
    }

    // Mic LED brightness control
    RowLayout {
        id: featureMicLedBrightness
        visible: headsetcontrol.features.includes("l") && headsetcontrol.features.includes("m")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Slider {
            id: micLedBrightnessValue
            Layout.fillWidth: true
            from: 0
            to: 100
            value: 50
            wheelEnabled: true
            stepSize: 1.0

            ToolTip {
                text: micLedBrightnessValue.value.toFixed() + "%"
            }
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set Mic LED Brightness")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' --microphone-mute-led-brightness ' + micLedBrightnessValue.value.toFixed())
        }
    }

    // Volume limiter control
    RowLayout {
        id: featureVolumeLimiter
        visible: headsetcontrol.features.includes("v")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Slider {
            id: volumeLimiterValue
            Layout.fillWidth: true
            from: 0
            to: 100
            value: 100
            wheelEnabled: true
            stepSize: 1.0

            ToolTip {
                text: volumeLimiterValue.value.toFixed() + "%"
            }
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set Volume Limit")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' --volume-limiter ' + volumeLimiterValue.value.toFixed())
        }
    }

    // Spacer item until I figure out how to resize the pop-up.
    Item {
        Layout.fillHeight: true
    }

    // Separate DataSource for non-polling commands. No signal here since we
    // don't expect any output.
    Plasma5Support.DataSource {
        id: headsetCommand
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            var stdout = data["stdout"].trim();
            var code = data["exit code"];
            disconnectSource(sourceName); // cmd finished
        }

        function exec(cmd) {
            connectSource(cmd);
        }
    }
}