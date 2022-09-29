import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: headsetcontrol

    property bool available: false
    property int percent: 0
    property string status: "N/A"
    property string model: "Headset Control"
    property string features: ""

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}

    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    Plasmoid.icon: "headset"

    Plasmoid.toolTipMainText: headsetcontrol.model
    Plasmoid.toolTipSubText: headsetcontrol.status

    // DataSource for the user command execution results.
    PlasmaCore.DataSource {
        id: subprocess
        engine: "executable"
        connectedSources: []
        onNewData: {
            var stdout = data["stdout"].trim();
            var code = data["exit code"];

            exited(sourceName, code, stdout);
            disconnectSource(sourceName); // cmd finished
        }
        
        function exec(cmd) {
            connectSource(cmd);
        }

        signal exited(string sourceName, string code, string stdout);
    }

    Timer {
        id: timer
        interval: plasmoid.configuration.pollingRate
        running: false
        repeat: false
        onTriggered: poll()
    }

    Component.onCompleted: {
        poll();
    }

    // Parse output of called command when it returns.
    Connections {
        target: subprocess
        onExited: {
            parse(sourceName, code, stdout);
        }
    }

    function poll() {
        if (!available) {
            // Try detecting headset model before charge. We don't use the short
            // output because that won't give us the headset model.
            subprocess.exec(plasmoid.configuration.binaryPath + ' -?');
        } else {
            // Try detecting features before charge. We could try to get it all
            // at once along with the model, but using the short output here is
            // much easier.
            if (features == "") {
                subprocess.exec(plasmoid.configuration.binaryPath + ' -? -c');
            } else {
                subprocess.exec(plasmoid.configuration.binaryPath + ' -b -c');
            }
        }
    }

    function parse(cmd, code, status) {
        if (code == 0) {
            if (!available) {
                headsetcontrol.available = true;
                headsetcontrol.model = parseModel(status);

                // Poll again immediately to get features.
                poll();
                return;
            } else {
                if (features == "") {
                    headsetcontrol.features = status;

                    // Poll again immediately to get battery state.
                    poll();
                    return;
                } else {
                    headsetcontrol.percent = parseInt(status);
                }
            }
        } else {
            headsetcontrol.available = false;
            headsetcontrol.features = "";
            headsetcontrol.percent = 0;
            headsetcontrol.model = "Headset Control";
        }

        // Update text.
        headsetcontrol.status = updatedStatus();

        // Start timer after parsing so subprocess can take the time it needs.
        timer.running = true;
    }

    function updatedStatus() {
        if (!available) {
            return i18n("N/A");
        }
        if (percent == -1) {
            return i18n("Charging...");
        }
        return i18n("Charge: %1%", percent);
    }

    // Extract the headset model from "-?" output.
    function parseModel(output) {
        var header = output.split("\n")[0];
        var model = header.match(/^Found ([^!]*)!$/)[1];

        return model;
    }
}
