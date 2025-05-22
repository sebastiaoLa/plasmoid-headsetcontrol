import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM
import Qt.labs.platform as StandardPathsModule

KCM.SimpleKCM {
    id: configPage

    property alias cfg_binaryPath: formLayout.binaryPath_textField.text
    property alias cfg_pollingRate: formLayout.pollingRate_spinBox.value

    Kirigami.FormLayout {
        id: formLayout
        
        RowLayout {
            Kirigami.FormData.label: i18n("Headsetcontrol path:")
        
            TextField {
                id: binaryPath_textField
                placeholderText: i18n("No file selected.")
            }
            Button {
                text: i18n("Browse")
                icon.name: "folder-symbolic"
                onClicked: fileDialogLoader.active = true

                Loader {
                    id: fileDialogLoader
                    active: false

                    sourceComponent: FileDialog {
                        id: fileDialog
                        currentFolder: StandardPathsModule.StandardPaths.standardLocations(StandardPathsModule.StandardPaths.MusicLocation)[0]
                        nameFilters: [
                            i18n("All files (%1)", "*"),
                        ]
                        onAccepted: function() {
                            var path = selectedFile.toString();
                            // remove prefixed "file://"
                            path = path.replace(/^(file:\/{2})/,"");
                            // unescape html codes like '%23' for '#'
                            formLayout.binaryPath_textField.text = decodeURIComponent(path);
                            fileDialogLoader.active = false;
                        }
                        onRejected: function() {
                            fileDialogLoader.active = false;
                        }
                        Component.onCompleted: open()
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Polling rate (ms):")

            SpinBox {
                id: pollingRate_spinBox
                from: 500
                to: 60000
                stepSize: 100
            }
        }
    }
}
