import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    toolTipMainText: ""
    toolTipSubText: ""

    property bool vpnActive: false
    property string currentStatusText: i18n("Checking VPN...")
    property string pendingToggleCmd: ""

    function shellQuote(val) {
        return "'" + String(val || "").replace(/'/g, "'\\''") + "'"
    }

    readonly property string safeIface: (plasmoid.configuration.vpnInterface || "").trim()
    readonly property string safeConn: (plasmoid.configuration.vpnConnectionName || "").trim()

    readonly property string checkCommand: {
        var qi = shellQuote(safeIface)
        var qc = shellQuote(safeConn)
        var checks = []
        if (safeIface.length > 0) checks.push("[ -d /sys/class/net/" + qi + " ]")
        if (safeConn.length > 0) checks.push("nmcli -t -f NAME connection show --active 2>/dev/null | grep -Fxiq -- " + qc)
        if (checks.length === 0) return "echo inactive"
        return "if " + checks.join(" || ") + "; then echo active; else echo inactive; fi"
    }

    readonly property string toggleCommand: {
        var qi = shellQuote(safeIface)
        var qc = shellQuote(safeConn)
        var isUpCheck = []
        var downCmds = []
        var upCmds = []
        if (safeIface.length > 0) isUpCheck.push("[ -d /sys/class/net/" + qi + " ]")
        if (safeConn.length > 0) {
            isUpCheck.push("nmcli -t -f NAME connection show --active 2>/dev/null | grep -Fxiq -- " + qc)
            downCmds.push("nmcli connection down " + qc)
            upCmds.push("nmcli connection up " + qc)
        }
        if (safeIface.length > 0) {
            downCmds.push("ip link set dev " + qi + " down")
            downCmds.push("wg-quick down " + qi)
            upCmds.push("ip link set dev " + qi + " up")
            upCmds.push("wg-quick up " + qi)
        }
        if (isUpCheck.length === 0) return "exit 1"
        return "if " + isUpCheck.join(" || ") + "; then (" + downCmds.join(" || ") + "); else (" + upCmds.join(" || ") + "); fi"
    }

    PlasmaNM.NetworkStatus {
        id: nmStatus
        onActiveConnectionsChanged: root.refreshStatus()
    }

    // Fallback poll only when checking a non-NM sysfs interface, or slow periodic verification
    Timer {
        id: pollTimer
        interval: Math.max(5, plasmoid.configuration.checkInterval || 60) * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }

    function refreshStatus() {
        executableDataSource.exec(root.checkCommand)
    }

    // React to configuration changes
    Connections {
        target: plasmoid.configuration
        function onVpnInterfaceChanged() { root.refreshStatus(); }
        function onVpnConnectionNameChanged() { root.refreshStatus(); }
        function onCheckIntervalChanged() {
            pollTimer.interval = Math.max(5, plasmoid.configuration.checkInterval || 60) * 1000;
            pollTimer.restart();
        }
    }

    Plasma5Support.DataSource {
        id: executableDataSource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source);

            if (source === root.pendingToggleCmd) {
                root.pendingToggleCmd = "";
                var exitCode = data["exit code"];
                if (exitCode !== undefined && exitCode !== 0) {
                    var err = (data["stderr"] || "").trim();
                    root.currentStatusText = err.length > 0 ? i18n("Toggle failed: %1", err) : i18n("Toggle failed (exit %1)", exitCode);
                } else {
                    root.refreshStatus();
                }
                return;
            }

            if (source !== root.checkCommand) {
                return;
            }

            var output = (data["stdout"] || "").trim();
            var isActive = (output === "active");
            root.vpnActive = isActive;
            root.currentStatusText = isActive
                ? i18n("VPN Active (%1)", root.safeIface || root.safeConn)
                : i18n("VPN Disconnected");
        }

        function exec(cmd) {
            connectSource(cmd);
        }
    }

    function toggleVpn() {
        root.currentStatusText = i18n("Toggling VPN...");
        root.pendingToggleCmd = root.toggleCommand;
        executableDataSource.exec(root.pendingToggleCmd);
    }

    // Panel representation
    compactRepresentation: Item {
        id: compactRoot
        implicitWidth: Kirigami.Units.gridUnit * 1.5
        implicitHeight: Kirigami.Units.gridUnit * 1.5

        Kirigami.Icon {
            id: iconItem
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) - Kirigami.Units.smallSpacing * 1.5
            height: width
            source: root.vpnActive ? plasmoid.configuration.activeIcon : plasmoid.configuration.inactiveIcon
            isMask: true

            // Color active state positive green or highlight, inactive as disabled gray
            color: root.vpnActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor

            Behavior on color {
                ColorAnimation { duration: Kirigami.Units.longDuration }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // Toggles the full popup layout rather than a blind background script
                plasmoid.expanded = !plasmoid.expanded
            }
        }
    }

    // Expanded / Desktop representation
    fullRepresentation: Item {
        id: fullRoot
        // Match popup size to the layout contents cleanly
        implicitWidth: mainLayout.implicitWidth + Kirigami.Units.gridUnit * 2
        implicitHeight: mainLayout.implicitHeight + Kirigami.Units.gridUnit * 2

        Kirigami.Card {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            contentItem: Item {
                ColumnLayout {
                    id: mainLayout
                    anchors.centerIn: parent
                    spacing: Kirigami.Units.largeSpacing

                    RowLayout {
                        spacing: Kirigami.Units.mediumSpacing
                        Layout.alignment: Qt.AlignHCenter

                        Kirigami.Icon {
                            source: root.vpnActive ? plasmoid.configuration.activeIcon : plasmoid.configuration.inactiveIcon
                            implicitWidth: Kirigami.Units.iconSizes.large
                            implicitHeight: Kirigami.Units.iconSizes.large
                            isMask: true
                            color: root.vpnActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                        }

                        ColumnLayout {
                            spacing: 2
                            PlasmaComponents.Label {
                                text: plasmoid.configuration.vpnConnectionName
                                font.bold: true
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
                            }
                            PlasmaComponents.Label {
                                text: root.currentStatusText
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
                                opacity: 0.85
                            }
                        }
                    }

                    PlasmaComponents.Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.vpnActive ? i18n("Disconnect VPN") : i18n("Connect VPN")
                        icon.name: root.vpnActive ? "network-disconnect" : "network-connect"
                        onClicked: {
                            root.toggleVpn();
                        }
                    }
                }
            }
        }
    }
}
