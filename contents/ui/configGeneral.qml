import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_vpnInterface: vpnInterfaceField.text
    property alias cfg_vpnConnectionName: vpnConnectionNameField.text
    property alias cfg_checkInterval: checkIntervalSpin.value
    property alias cfg_activeIcon: activeIconField.text
    property alias cfg_inactiveIcon: inactiveIconField.text

    TextField {
        id: vpnInterfaceField
        Kirigami.FormData.label: i18n("VPN Interface (e.g. wg0):")
        placeholderText: "wg0"
    }

    TextField {
        id: vpnConnectionNameField
        Kirigami.FormData.label: i18n("NetworkManager Connection Name:")
        placeholderText: "PureVPN"
    }

    SpinBox {
        id: checkIntervalSpin
        Kirigami.FormData.label: i18n("Check Interval (seconds):")
        from: 1
        to: 60
        stepSize: 1
    }

    TextField {
        id: activeIconField
        Kirigami.FormData.label: i18n("Active Icon:")
        placeholderText: "network-vpn-activated"
    }

    TextField {
        id: inactiveIconField
        Kirigami.FormData.label: i18n("Inactive Icon:")
        placeholderText: "network-vpn-disconnected"
    }
}
