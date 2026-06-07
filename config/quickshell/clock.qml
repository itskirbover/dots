import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    
    SystemClock {
        id: clock
        precision: SystemClock.Minutes     }

    MatugenColors {
        id: theme
    }
       Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

                        WlrLayershell.layer: WlrLayer.Background

           
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Text {

                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: 100 
                    leftMargin: 120
                }
                text: Qt.formatDateTime(clock.date, "hh:mm")

                font.pixelSize: 100
                font.weight: 40
                font.family: "Poppins"
                color: theme.colorOnPrimaryContainer
                opacity: 1
            }
            Text {

                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: 210
                    leftMargin: 123 
                  }
                text: Qt.formatDateTime(clock.date, "dddd, MMMM d")

                font.pixelSize: 24
                font.weight: 40
                font.family: "Poppins"
                color: theme.colorOnPrimaryContainer
                opacity: 1
            }
        }
    }
}
