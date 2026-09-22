import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: guidePage

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        Layout.fillWidth: true

        Kirigami.Heading {
            level: 2
            text: i18n("Configuration Examples")
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.05
            lineHeight: 1.4
            text: i18n("In the <b>General</b> tab, set <b>VPN Interface</b> (or Connection Name) for your provider:<br><br>"
                + "• <b>NordVPN:</b> <code>nordlynx</code><br>"
                + "• <b>WireGuard:</b> <code>wg0</code><br>"
                + "• <b>OpenVPN:</b> <code>tun0</code><br>"
                + "• <b>Tailscale:</b> <code>tailscale0</code><br>"
                + "• <b>Mullvad:</b> <code>wg-mullvad</code><br>"
                + "• <b>ProtonVPN:</b> <code>proton0</code><br>"
                + "• <b>KDE / NetworkManager:</b> Enter your exact connection name (e.g. <code>PureVPN</code>)")
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Information
            text: i18n("<b>Connect / Disconnect Button:</b><br>"
                + "Works with NetworkManager VPNs and standard WireGuard. Provider apps (Nord, Mullvad, Tailscale) are detected automatically, but should be connected through their own app.")
        }
    }
}
