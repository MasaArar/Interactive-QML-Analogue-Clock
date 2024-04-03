import QtQuick 2.0

Item {
    id: id_root

    property int hours: currentDate.getHours()
    property int minutes: currentDate.getMinutes()
    property int seconds: currentDate.getSeconds()
    property var currentDate: new Date()

    Timer {
        id: timer
        repeat: true
        interval: 1000
        running: true
        onTriggered: id_root.currentDate = new Date()
    }

    Rectangle {
        id: id_plate
        anchors.centerIn: parent
        height: Math.min(id_root.width, id_root.height)
        width: height
        radius: width / 2
        color: "white"
        border.color: "black"
        border.width: 2

        Repeater {
            model: 60
            Item {
                id: minuteMarker
                property int minute: index
                height: id_plate.height / 2
                transformOrigin: Item.Bottom
                rotation: index * 6
                x: id_plate.width / 2
                y: id_plate.height / 1000
                Rectangle {
                    width: minuteMarker.minute % 5 === 0 ? id_plate.height * 0.01 : id_plate.height * 0.005
                    height: id_plate.height * 0.02
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Repeater {
            model: 12
            Item {
                id: hourContainer
                property int hour: index
                height: id_plate.height / 2
                transformOrigin: Item.Bottom
                rotation: index * 30
                x: id_plate.width / 2
                y: 0
                Rectangle {
                    height: id_plate.height * 0.04
                    width: height / 2.5
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                }
                Text {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    x: 0
                    y: id_plate.height * 0.06
                    rotation: 360 - index * 30
                    text: hourContainer.hour == 0 ? 12 : hourContainer.hour
                    font.pixelSize: id_plate.height * 0.1
                    font.family: "Arial"
                }
            }
        }
    }

    MouseArea {
        id: hourHandMouseArea
        // Anchor the mouse area to the plate
        anchors.fill: id_plate
        cursorShape: Qt.OpenHandCursor

        onPressed: {
            hourHandMouseArea.cursorShape = Qt.ClosedHandCursor
        }

        onReleased: {
            hourHandMouseArea.cursorShape = Qt.OpenHandCursor
        }

        onPositionChanged: {
            var angle = getRotationAngle(mouseX, mouseY);

            // Calculate the rotation angle for the hour hand
            var currentHour = id_root.hours + id_root.minutes / 60; // Include minutes in current hour calculation
            var newHour = Math.floor(currentHour) % 12; // Get the integer part of current hour
            var nextHour = (newHour + 1) % 12; // Get the next hour

            // Calculate the angle corresponding to the next hour
            var nextHourAngle = (nextHour * 30) + (360 * (id_root.minutes / 60));

            // Smoothly transition the hour needle to the angle of the next hour
            hourNeedle.rotation = angle + (nextHourAngle - angle) * 0.05; // Adjust the transition speed as needed

            // Update the current hour
            id_root.hours = newHour;

            // Calculate the rotation angle for the minute hand
            var minuteAngle = angle * 12 / 360; // Convert angle to minute equivalent
            var newMinute = Math.floor(minuteAngle) % 60; // Get the integer part of current minute
            var nextMinute = (newMinute + 1) % 60; // Get the next minute

            // Calculate the angle corresponding to the next minute
            var nextMinuteAngle = (nextMinute * 6) + (360 * (minuteAngle % 1));

            // Smooth transition for minute hand (adjust factor as needed)
            minuteNeedle.rotation = nextMinuteAngle; // Set the rotation angle directly for smooth movement

            // Update the current minute
            id_root.minutes = newMinute;
        }

        function getRotationAngle(mouseX, mouseY) {
            var angle = Math.atan2(mouseY - id_plate.height / 2, mouseX - id_plate.width / 2) * 180 / Math.PI;
            if (angle < 0) angle += 360;
            return angle;
        }
    }

    Rectangle {
        id: id_center
        width: 6
        height: 6
        color: "black"
        radius: width / 2
        anchors.centerIn: parent
    }

    SecondNeedle {
        anchors {
            top: id_plate.top
            bottom: id_plate.bottom
            horizontalCenter: id_plate.horizontalCenter
        }
        value: id_root.seconds
    }

    MinuteNeedle {
        id: minuteNeedle
        anchors {
            top: id_plate.top
            bottom: id_plate.bottom
            horizontalCenter: id_plate.horizontalCenter
        }
        value: id_root.minutes
    }

    HourNeedle {
            id: hourNeedle
            anchors {
                top: id_plate.top
                bottom: id_plate.bottom
                horizontalCenter: id_plate.horizontalCenter
            }
            value: id_root.hours
            valueminute: id_root.minutes
        }
}
