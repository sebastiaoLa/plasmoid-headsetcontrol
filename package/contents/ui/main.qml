import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: headsetcontrol

    property bool present: false    // USB receiver is plugged in.
    property bool available: false  // Headset is on and connected.
    property int percent: 0
    property string status_text: "N/A" // Renamed from original 'status' property
    property string model: "Headset Control"
    property string features: ""
    property string batteryStatus: "UNKNOWN" // New property for battery status

    preferredRepresentation: Plasmoid.compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    Plasmoid.status: {
        if (headsetcontrol.available) {
            return PlasmaCore.Types.ActiveStatus;
        }
        return PlasmaCore.Types.PassiveStatus;
    }
    Plasmoid.icon: "headset"

    toolTipMainText: headsetcontrol.model
    toolTipSubText: headsetcontrol.status_text

    // DataSource for the user command execution results.
    Plasma5Support.DataSource {
        id: subprocess
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
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
        function onExited(sourceName, code, stdout) {
            parse(sourceName, code, stdout);
        }
    }

    // FIXME: ... a state machine would probably make this less confusing.
    function poll() {
        if (!headsetcontrol.present) {
            // Try detecting headset model before charge. We don't use the short
            // output because that won't give us the headset model.
            subprocess.exec(plasmoid.configuration.binaryPath + ' -?');
        } else {
            // Try detecting features before charge. We could try to get it all
            // at once along with the model, but using the short output here is
            // much easier.
            if (headsetcontrol.features == "") {
                subprocess.exec(plasmoid.configuration.binaryPath + ' -? -o STANDARD');
            } else {
                subprocess.exec(plasmoid.configuration.binaryPath + ' -b -o STANDARD');
            }
        }
    }

    // Reset internal state.
    function reset() {
        headsetcontrol.present = false;
        headsetcontrol.available = false;
        headsetcontrol.features = "";
        headsetcontrol.percent = 0;
        headsetcontrol.model = "Headset Control";
        headsetcontrol.status_text = "N/A"; // Use renamed status_text
    }

    // Parse the output of a polling command (which is either trying to detect
    // if the headset receiver is present, what model the headset is and what
    // it's charge level is, if available).
    function parse(cmd, code, status) {
        // Was the headset receiver detected at all?
        if (!headsetcontrol.present) {
            // We're trying to detect the receiver/model.
            if (code == 0) {
                // Receiver is present, we hould have a model name.
                headsetcontrol.present = true;
                headsetcontrol.model = parseModel(status);

                // Poll again immediately to get features.
                poll();
            } else {
                // No receiver detected at all. Reset everything.
                reset();

                // Wait a little before polling again.
                timer.running = true;
            }

            // Stop here, we need more polling to get the features.
            return;
        }

        // Have we detected the headset's features?
        if (headsetcontrol.features == "") {
            // Receiver is present, read the headset's features.
            if (code == 0) {
                // Parse the capabilities from the new output format
                headsetcontrol.features = parseFeatures(status);

                // Poll again immediately to get battery state.
                poll();
            } else {
                // Most likely the receiver was unplugged.
                reset();

                // Wait a little before polling again.
                timer.running = true;
            }

            // Stop here, we need more polling to get the charge.
            return;
        }

        // If we got here, we know the model and features. We just need the
        // headset itself to be on so we can get its battery level.
        if (code == 0) {
            // Mark headset as available and grab charge level from new output format
            headsetcontrol.available = true;
            headsetcontrol.percent = parseBatteryLevel(status);
        } else {
            // Reset charge and availability.
            headsetcontrol.available = false;
            headsetcontrol.percent = 0;

            // Reset the features list. This will cause another round of
            // polling that will also detect whether the receiver itself is
            // still there.
            headsetcontrol.features = "";
        }

        // Update text with charge status.
        headsetcontrol.status_text = updatedStatus(); // Use renamed status_text

        // Wait a little before polling again.
        timer.running = true;
    }

    function updatedStatus() {
        if (!headsetcontrol.available || !headsetcontrol.present) {
            return i18n("N/A");
        }
        if (headsetcontrol.batteryStatus === "BATTERY_CHARGING") {
            return i18n("Charging... (%1%)", headsetcontrol.percent);
        }
        return i18n("Charge: %1%", headsetcontrol.percent);
    }

    // Extract the headset model from "-? -o STANDARD" output.
    function parseModel(output) {
        var lines = output.split("\n");
        
        if (lines.length >= 2) {
            var deviceLine = lines[1].trim();
            // Extract everything before the hexadecimal ID in square brackets
            var bracketIndex = deviceLine.indexOf("[");
            if (bracketIndex !== -1) {
                return deviceLine.substring(0, bracketIndex).trim();
            }
        }
        return "Unknown Model";
    }
    
    // Extract features from "-? -o STANDARD" output
    function parseFeatures(output) {
        var featureString = "";
        var lines = output.split("\n");
        var capabilitiesIndex = output.indexOf("Capabilities:");
        
        if (capabilitiesIndex !== -1) {
            // Process capabilities
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.startsWith("* ")) {
                    var feature = line.substring(2).trim();
                    
                    // Map the verbose feature names to single-letter codes
                    if (feature === "sidetone") featureString += "s";
                    else if (feature === "battery") featureString += "b";
                    else if (feature === "lights" || feature.includes("led")) featureString += "l";
                    else if (feature === "voice prompt" || feature.includes("voice")) featureString += "v";
                    else if (feature === "rotate to mute" || feature.includes("rotate")) featureString += "r";
                    else if (feature === "chatmix") featureString += "c";
                    else if (feature.includes("equalizer")) featureString += "e";
                    else if (feature.includes("microphone")) featureString += "m";
                    else if (feature.includes("volume")) featureString += "v";
                }
            }
        }
        
        return featureString;
    }
    
    // Extract battery level from "-b -o STANDARD" output
    function parseBatteryLevel(output) {
        var lines = output.split("\n");
        var batteryLevelLine = "";
        var batteryStatusLine = "";
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.startsWith("Level:")) {
                batteryLevelLine = line;
            } else if (line.startsWith("Status:")) {
                batteryStatusLine = line;
            }
        }
        
        if (batteryStatusLine) {
            // Extract status from "Status: BATTERY_XXX"
            var statusMatch = batteryStatusLine.match(/Status:\s*(.+)/);
            if (statusMatch && statusMatch[1]) {
                headsetcontrol.batteryStatus = statusMatch[1].trim();
            }
        }
        
        if (batteryLevelLine) {
            // Extract percentage number from "Level: XX%"
            var percentMatch = batteryLevelLine.match(/Level:\s*(\d+)%/);
            if (percentMatch && percentMatch[1]) {
                return parseInt(percentMatch[1]);
            }
        }
        
        return 0;
    }
}
