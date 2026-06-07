import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 46
    color: "transparent"

    MatugenColors {
        id: theme
    }

    Rectangle {
        id: barContainer
        anchors.fill: parent

        anchors.topMargin: 6
        anchors.bottomMargin: 2
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        radius: 25
        color: theme.background

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            RowLayout {
                Text {
                    id: titleText
                    text: Hyprland.activeToplevel?.title ?? "Desktop"
                    color: theme.colorOnSurface
                    font.family: "Poppins"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.maximumWidth: 300
                }
            }

            RowLayout {
                id: workspaceSection
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                // Computes the 5 visible slots reactively based on the active workspace
                readonly property var slots: {
                    var activeId = Hyprland.focusedWorkspace?.id ?? 1;
                    if (activeId > 5) {
                        return [1, 2, 3, 4, activeId];
                    } else {
                        return [1, 2, 3, 4, 5];
                    }
                }

                Repeater {
                    model: workspaceSection.slots

                    delegate: Rectangle {
                        required property var modelData // Represents the workspace ID for this slot

                        // Safe loop to find if this workspace is active/occupied in Hyprland's session
                        readonly property var ws: {
                            for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                                if (Hyprland.workspaces.values[i].id === modelData) {
                                    return Hyprland.workspaces.values[i];
                                }
                            }
                            return null;
                        }

                        // State evaluations
                        readonly property bool isFocused: Hyprland.focusedWorkspace?.id === modelData
                        readonly property bool isOccupied: ws !== null

                        // Dynamic capsule animation (expands when active)
                        implicitWidth: isFocused ? 30 : 10
                        implicitHeight: 10
                        radius: 5

                        // Color rules mapping to your Matugen module
                        color: {
                            if (isFocused) {
                                return theme.colorOnPrimaryContainer;
                            } else if (isOccupied) {
                                return theme.primaryContainer;
                            } else {
                                return theme.surfaceContainer;
                            }
                        }

                        // Smooth transition when transitioning workspace capsules
                        Behavior on implicitWidth {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.InOutQuad
                            }
                        }

                        // Handlers to catch click inputs and dispatch compositor shortcuts
                        // Change this block in shell.qml:
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor // [cite: 29]

                            onClicked: {
                                // Enclosing 'workspace' in single quotes and adding a comma
                                // forces the underlying Lua engine to compile it correctly.
                                Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData + " })");
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Rectangle {
                    id: systemTrayChip
                    implicitHeight: 28

                    // Filters out nm-applet by checking both its unique ID and descriptive title
                    readonly property var trayItems: SystemTray.items.values.filter(item => !item.id.toLowerCase().includes("nm-applet") && !item.title.toLowerCase().includes("network"))

                    implicitWidth: trayLayout.childrenRect.width + 20
                    radius: 14
                    color: theme.surfaceVariant
                    visible: trayItems.length > 0

                    RowLayout {
                        id: trayLayout
                        anchors.centerIn: parent
                        spacing: 10

                        Repeater {
                            model: systemTrayChip.trayItems
                            delegate: MouseArea {
                                required property var modelData
                                implicitWidth: 18
                                implicitHeight: 18
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                QsMenuAnchor {
                                    id: menuAnchor
                                    menu: modelData.menu
                                }

                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                }

                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        if (modelData.hasMenu) {
                                            menuAnchor.open();
                                        }
                                    } else {
                                        modelData.activate();
                                    }
                                }
                            }
                        }
                    }
                }

                // Clock Accent Chip
                Rectangle {
                    implicitHeight: 28
                    implicitWidth: clockText.implicitWidth + 24
                    radius: 14
                    color: theme.primaryContainer

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        color: theme.colorOnPrimaryContainer
                        font.family: "Poppins"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            triggeredOnStart: true
                            onTriggered: {
                                clockText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP");
                            }
                        }
                    }
                }
                // Power & Network Combined Pill
                Rectangle {
                    id: powerNetworkPill
                    implicitHeight: 28

                    // Scans the active system tray list to extract the nm-applet instance specifically
                    readonly property var nmItem: SystemTray.items.values.find(item => item.id.toLowerCase().includes("nm-applet") || item.title.toLowerCase().includes("network"))

                    // Dynamically adjusts width based on the visible layout children
                    implicitWidth: pillLayout.childrenRect.width + (nmItem ? 22 : 16)
                    radius: 14
                    color: theme.surfaceVariant

                    RowLayout {
                        id: pillLayout
                        anchors.centerIn: parent
                        spacing: 12

                        // Dedicated Network Manager Button (Text-Based)
                        MouseArea {
                            id: nmButton
                            visible: powerNetworkPill.nmItem !== undefined
                            implicitWidth: visible ? nmText.implicitWidth : 0
                            implicitHeight: visible ? nmText.implicitHeight : 0
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            QsMenuAnchor {
                                id: nmMenuAnchor
                                menu: powerNetworkPill.nmItem ? powerNetworkPill.nmItem.menu : null
                            }

                            Text {
                                id: nmText
                                anchors.centerIn: parent
                                text: "󰤢"
                                color: theme.colorOnSurfaceVariant
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }

                            onClicked: mouse => {
                                if (!powerNetworkPill.nmItem)
                                    return;

                                if (mouse.button === Qt.RightButton) {
                                    if (powerNetworkPill.nmItem.hasMenu) {
                                        nmMenuAnchor.open();
                                    }
                                } else {
                                    powerNetworkPill.nmItem.activate();
                                }
                            }
                        }

                        // Dedicated Power Button (Text-Based)
                        MouseArea {
                            implicitWidth: powerText.implicitWidth
                            implicitHeight: powerText.implicitHeight
                            cursorShape: Qt.PointingHandCursor

                            Text {
                                id: powerText
                                anchors.centerIn: parent
                                text: "" // Nerd Font Power (Alternative standard unicode: "⏻")
                                color: theme.colorOnSurfaceVariant
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }

                            onClicked: {
                                console.log("Power menu clicked");
                            }
                        }
                    }
                }
                Rectangle {
                    id: archIcon
                    implicitHeight: 28
                    // Dynamically adjusts width based on the visible layout children
                    implicitWidth: pillLayout.childrenRect.width + (nmItem ? 22 : 16)
                    radius: 14
                    Layout.rightMargin: 16

                    color: theme.surfaceVariant
                    RowLayout {
                        MouseArea {
                            implicitWidth: 28
                            implicitHeight: 28
                            Text {
                                id: arch
                                anchors.centerIn: parent
                                text: ""
                                color: theme.colorOnSurfaceVariant
                                font.family: "JetBrains Mono"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }
                        }
                    }
                }
            }
        }
    }
}
