import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    property bool serverOnline: false

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkHealth()
    }

    function checkHealth() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "http://localhost:8080/v1/models")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            serverOnline = (xhr.status >= 200 && xhr.status < 300)
        }
        xhr.onerror = function() {
            serverOnline = false
        }
        xhr.send()
    }

    anchors {
        top: true
        left: true
        bottom: true
    }
    implicitWidth: 420
    color: "#0d0d0f"

    property string modelName: "TheStageAI/Qwen3.5-9B-GGUF:Q4_K_M"
    property color accent: "#7c6fff"
    property color userBubble: "#1f1f26"
    property color aiBubble: "#151517"
    property color textColor: "#e8e8ec"
    property color mutedText: "#7a7a85"

    ListModel {
        id: messages
    }

    property bool waitingForReply: false
    property int maxTokens: 7000   // headroom under the server's -c 8000 n_ctx, minus response budget (512) and estimation slack

    function estimateTokens(text) {
        return Math.ceil(text.length / 4)
    }

    function trimHistoryToBudget() {
        var total = 0
        var keepFrom = 0

        for (var i = messages.count - 1; i >= 0; i--) {
            var msg = messages.get(i)
            total += estimateTokens(msg.content)
            if (total > maxTokens) {
                keepFrom = i + 1
                break
            }
        }

        if (keepFrom > 0) {
            messages.remove(0, keepFrom)
        }
    }

    function clearChat() {
        messages.clear()
    }

    function sendMessage() {
        var text = input.text.trim()
        if (text === "" || waitingForReply)
            return

        var tokenEstimate = estimateTokens(text)
        if (tokenEstimate > maxTokens) {
            messages.append({
                role: "assistant",
                content: "That message is too long (~" + tokenEstimate + " tokens, limit " + maxTokens + "). Try shortening it or splitting it up."
            })
            return
        }

        messages.append({ role: "user", content: text })
        trimHistoryToBudget()
        input.clear()
        waitingForReply = true

        // placeholder assistant message we'll fill in as chunks arrive
        messages.append({ role: "assistant", content: "" })
        var assistantIndex = messages.count - 1
        var processedLength = 0
        var gotAnyChunk = false

        var xhr = new XMLHttpRequest()
        xhr.open("POST", "http://localhost:8080/v1/chat/completions")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.timeout = 30000

        xhr.onreadystatechange = function() {
            var fullLen = xhr.responseText ? xhr.responseText.length : -1
            console.log("[LocalAI] readyState:", xhr.readyState, "status:", xhr.status, "responseText.length:", fullLen, "processedLength:", processedLength)

            if (xhr.readyState === XMLHttpRequest.LOADING || xhr.readyState === XMLHttpRequest.DONE) {
                var newText = xhr.responseText.substring(processedLength)
                processedLength = xhr.responseText.length
                console.log("[LocalAI] newText (raw):", JSON.stringify(newText))
                if (newText.length > 0) {
                    gotAnyChunk = true
                    handleChunk(newText, assistantIndex)
                }
            }

            if (xhr.readyState === XMLHttpRequest.DONE) {
                waitingForReply = false
                if (xhr.status < 200 || xhr.status >= 300) {
                    messages.setProperty(assistantIndex, "content", "Server error: " + xhr.status + (xhr.responseText ? (" — " + xhr.responseText.substring(0, 200)) : ""))
                } else if (!gotAnyChunk) {
                    // DONE fired, status OK, but we never parsed any streamed content.
                    // Likely means readyState LOADING never fired incrementally on this Qt build —
                    // try parsing the full buffered response as SSE one last time.
                    var newText = xhr.responseText.substring(processedLength)
                    if (newText.length > 0) {
                        handleChunk(newText, assistantIndex)
                    } else {
                        messages.setProperty(assistantIndex, "content", "(no content received — see console log)")
                        console.log("[LocalAI] Empty response body. Raw:", xhr.responseText)
                    }
                }
            }
        }

        xhr.onerror = function() {
            console.log("[LocalAI] XHR onerror fired — request never reached the server")
            waitingForReply = false
            messages.setProperty(assistantIndex, "content", "Connection error — is the server running on localhost:8080?")
        }

        xhr.ontimeout = function() {
            console.log("[LocalAI] XHR timed out")
            waitingForReply = false
            messages.setProperty(assistantIndex, "content", "Request timed out.")
        }

        var history = []
        for (var i = 0; i < messages.count - 1; i++) {  // skip the empty placeholder
            var msg = messages.get(i)
            history.push({ role: msg.role, content: msg.content })
        }

        var payload = JSON.stringify({
            model: modelName,
            messages: history,
            max_tokens: 512,
            temperature: 0.7,
            stream: true
        })
        console.log("[LocalAI] Sending payload, approx tokens:", estimateTokens(payload))

        xhr.send(payload)
    }


    function handleChunk(raw, index) {
        var lines = raw.split("\n")
        console.log("[LocalAI] handleChunk: split into", lines.length, "line(s)")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "") {
                continue
            }
            if (!line.startsWith("data:")) {
                console.log("[LocalAI] skipped non-data line:", JSON.stringify(line))
                continue
            }

            var payload = line.substring(5).trim()
            if (payload === "[DONE]")
                continue

            try {
                var json = JSON.parse(payload)
                var delta = json.choices[0].delta
                console.log("[LocalAI] parsed delta:", JSON.stringify(delta))
                if (delta && delta.content) {
                    var current = messages.get(index).content
                    messages.setProperty(index, "content", current + delta.content)
                    console.log("[LocalAI] bubble content now:", JSON.stringify(messages.get(index).content))
                }
            } catch (e) {
                console.log("[LocalAI] JSON parse failed on payload:", JSON.stringify(payload), "error:", e)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: "#111114"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: waitingForReply ? "#e0a83c" : (serverOnline ? "#4cd97b" : "#e0463c")
                }

                Text {
                    text: "Local AI"
                    color: textColor
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: modelName.split("/").pop()
                    color: mutedText
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 150
                }

                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "🗑"
                        font.pixelSize: 13
                        color: mutedText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clearChat()
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#1f1f24"
            }
        }

        // Chat area
        ListView {
            id: chat
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            model: messages
            spacing: 10
            clip: true

            delegate: Item {
                width: chat.width
                height: bubble.height + 4

                Rectangle {
                    id: bubble
                    width: Math.min(messageText.implicitWidth + 28, chat.width * 0.82)
                    height: messageText.implicitHeight + 20
                    radius: 14
                    color: model.role === "user" ? userBubble : aiBubble
                    border.color: model.role === "user" ? Qt.lighter(userBubble, 1.6) : "#232327"
                    border.width: 1
                    anchors.right: model.role === "user" ? parent.right : undefined
                    anchors.left: model.role === "user" ? undefined : parent.left

                    Text {
                        id: messageText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: model.content
                        color: textColor
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                    }
                }
            }

            onCountChanged: {
                Qt.callLater(function() {
                    chat.positionViewAtEnd()
                })
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: messages.count === 0
                text: "Ask something to get started"
                color: mutedText
                font.pixelSize: 13
            }
        }

        // Typing indicator
        Text {
            Layout.leftMargin: 16
            Layout.bottomMargin: 4
            visible: waitingForReply
            text: "thinking…"
            color: mutedText
            font.pixelSize: 11
            font.italic: true
        }

        // Input bar
        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 12
            Layout.topMargin: waitingForReply ? 4 : 12
            height: 46
            radius: 23
            color: "#18181c"
            border.color: input.activeFocus ? accent : "#26262b"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 6
                spacing: 8

                TextField {
                    id: input
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    placeholderText: "Ask something..."
                    placeholderTextColor: mutedText
                    color: textColor
                    font.pixelSize: 13
                    background: Item {}
                    focus: true
                    onAccepted: sendMessage()

                    Component.onCompleted: forceActiveFocus()
                }

                Rectangle {
                    width: 34
                    height: 34
                    radius: 17
                    color: input.text.trim() !== "" ? accent : "#26262b"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "↑"
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sendMessage()
                    }
                }
            }
        }
    }
}
