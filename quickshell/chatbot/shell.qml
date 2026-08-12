import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: root

    // ─────────────────────────────────────────────────────────────
    // Configuration
    // ─────────────────────────────────────────────────────────────

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        left: true
        bottom: true
    }

    implicitWidth: 420
    color: colors.background

    property string serverUrl: "http://localhost:8080"
    property string modelName: "TheStageAI/Qwen3.5-9B-GGUF:Q4_K_M"

    property int maxContextTokens: 7000
    property int maxResponseTokens: 512

    property bool serverOnline: false
    property bool waitingForReply: false

    property var colors: ({
        background: "#0d0d0f",
        header: "#111114",
        input: "#18181c",

        userBubble: "#1f1f26",
        aiBubble: "#151517",

        border: "#232327",
        inputBorder: "#26262b",

        text: "#e8e8ec",
        muted: "#7a7a85",

        accent: "#7c6fff",
        online: "#4cd97b",
        offline: "#e0463c",
        waiting: "#e0a83c"
    })


    // ─────────────────────────────────────────────────────────────
    // Data
    // ─────────────────────────────────────────────────────────────

    ListModel {
        id: messages
    }


    // ─────────────────────────────────────────────────────────────
    // Server health
    // ─────────────────────────────────────────────────────────────

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: checkServerHealth()
    }

    function checkServerHealth() {
        var xhr = new XMLHttpRequest()

        xhr.open("GET", serverUrl + "/v1/models")

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            serverOnline = xhr.status >= 200 && xhr.status < 300
        }

        xhr.onerror = function() {
            serverOnline = false
        }

        xhr.send()
    }


    // ─────────────────────────────────────────────────────────────
    // Token / history management
    // ─────────────────────────────────────────────────────────────

    function estimateTokens(text) {
        return Math.ceil(text.length / 4)
    }

    function trimHistoryToBudget() {
        var totalTokens = 0
        var firstMessageToKeep = 0

        for (var i = messages.count - 1; i >= 0; i--) {
            var message = messages.get(i)

            totalTokens += estimateTokens(message.content)

            if (totalTokens > maxContextTokens) {
                firstMessageToKeep = i + 1
                break
            }
        }

        if (firstMessageToKeep > 0)
            messages.remove(0, firstMessageToKeep)
    }

    function buildMessageHistory() {
        var history = []

        for (var i = 0; i < messages.count; i++) {
            var message = messages.get(i)

            history.push({
                role: message.role,
                content: message.content
            })
        }

        return history
    }

    function clearChat() {
        messages.clear()
    }


    // ─────────────────────────────────────────────────────────────
    // Sending messages
    // ─────────────────────────────────────────────────────────────

    function sendMessage() {
        var text = input.text.trim()

        if (text === "" || waitingForReply)
            return

        if (!validateMessageLength(text))
            return

        messages.append({
            role: "user",
            content: text
        })

        trimHistoryToBudget()

        input.clear()
        waitingForReply = true

        createAssistantPlaceholder()
    }

    function validateMessageLength(text) {
        var tokenEstimate = estimateTokens(text)

        if (tokenEstimate <= maxContextTokens)
            return true

        messages.append({
            role: "assistant",
            content:
                "That message is too long (~" +
                tokenEstimate +
                " tokens, limit " +
                maxContextTokens +
                "). Try shortening it or splitting it up."
        })

        return false
    }

    function createAssistantPlaceholder() {
        messages.append({
            role: "assistant",
            content: ""
        })

        var assistantIndex = messages.count - 1

        sendChatRequest(assistantIndex)
    }


    // ─────────────────────────────────────────────────────────────
    // Chat request
    // ─────────────────────────────────────────────────────────────

    function sendChatRequest(assistantIndex) {
        var xhr = new XMLHttpRequest()

        var processedLength = 0
        var receivedContent = false

        xhr.open("POST", serverUrl + "/v1/chat/completions")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.timeout = 30000

        xhr.onreadystatechange = function() {
            handleRequestState(
                xhr,
                assistantIndex,
                processedLength,
                function(newLength) {
                    processedLength = newLength
                },
                function() {
                    receivedContent = true
                }
            )
        }

        xhr.onerror = function() {
            console.log("[LocalAI] Connection error")

            waitingForReply = false

            setAssistantMessage(
                assistantIndex,
                "Connection error — is the server running on localhost:8080?"
            )
        }

        xhr.ontimeout = function() {
            console.log("[LocalAI] Request timed out")

            waitingForReply = false

            setAssistantMessage(
                assistantIndex,
                "Request timed out."
            )
        }

        var payload = buildChatPayload()

        console.log(
            "[LocalAI] Sending payload, approx tokens:",
            estimateTokens(payload)
        )

        xhr.send(payload)
    }

    function handleRequestState(
        xhr,
        assistantIndex,
        processedLength,
        updateProcessedLength,
        markReceived
    ) {
        var response = xhr.responseText || ""
        var newLength = response.length

        console.log(
            "[LocalAI] readyState:",
            xhr.readyState,
            "status:",
            xhr.status,
            "responseLength:",
            newLength,
            "processedLength:",
            processedLength
        )

        if (
            xhr.readyState === XMLHttpRequest.LOADING ||
            xhr.readyState === XMLHttpRequest.DONE
        ) {
            var newText = response.substring(processedLength)

            updateProcessedLength(newLength)

            if (newText.length > 0) {
                markReceived()
                handleChunk(newText, assistantIndex)
            }
        }

        if (xhr.readyState === XMLHttpRequest.DONE) {
            finishRequest(xhr, assistantIndex, processedLength)
        }
    }

    function finishRequest(xhr, assistantIndex, processedLength) {
        waitingForReply = false

        if (xhr.status < 200 || xhr.status >= 300) {
            setAssistantMessage(
                assistantIndex,
                "Server error: " +
                xhr.status +
                (xhr.responseText
                    ? " — " + xhr.responseText.substring(0, 200)
                    : "")
            )

            return
        }

        // Some Qt builds don't emit incremental LOADING events.
        // Parse the complete response as a final fallback.
        var remaining = xhr.responseText.substring(processedLength)

        if (remaining.length > 0)
            handleChunk(remaining, assistantIndex)
    }


    // ─────────────────────────────────────────────────────────────
    // Request payload
    // ─────────────────────────────────────────────────────────────

    function buildChatPayload() {
        return JSON.stringify({
            model: modelName,
            messages: buildMessageHistory(),
            max_tokens: maxResponseTokens,
            temperature: 0.7,
            stream: true
        })
    }


    // ─────────────────────────────────────────────────────────────
    // Streaming / SSE
    // ─────────────────────────────────────────────────────────────

    function handleChunk(raw, messageIndex) {
        var lines = raw.split("\n")

        console.log(
            "[LocalAI] Processing",
            lines.length,
            "line(s)"
        )

        for (var i = 0; i < lines.length; i++) {
            processSseLine(lines[i], messageIndex)
        }
    }

    function processSseLine(line, messageIndex) {
        line = line.trim()

        if (line === "")
            return

        if (!line.startsWith("data:")) {
            console.log(
                "[LocalAI] Skipped non-data line:",
                JSON.stringify(line)
            )

            return
        }

        var payload = line.substring(5).trim()

        if (payload === "[DONE]")
            return

        try {
            var json = JSON.parse(payload)
            var delta = json.choices[0].delta

            console.log(
                "[LocalAI] Parsed delta:",
                JSON.stringify(delta)
            )

            if (delta && delta.content)
                appendAssistantContent(messageIndex, delta.content)

        } catch (error) {
            console.log(
                "[LocalAI] JSON parse failed:",
                JSON.stringify(payload),
                "error:",
                error
            )
        }
    }

    function appendAssistantContent(messageIndex, content) {
        var current = messages.get(messageIndex).content

        messages.setProperty(
            messageIndex,
            "content",
            current + content
        )

        console.log(
            "[LocalAI] Bubble content:",
            JSON.stringify(messages.get(messageIndex).content)
        )
    }

    function setAssistantMessage(messageIndex, content) {
        messages.setProperty(
            messageIndex,
            "content",
            content
        )
    }


    // ─────────────────────────────────────────────────────────────
    // Main layout
    // ─────────────────────────────────────────────────────────────

    ColumnLayout {
        anchors.fill: parent
        spacing: 0


        // ─────────────────────────────────────────────────────────
        // Header
        // ─────────────────────────────────────────────────────────

        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: colors.header

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4

                    color: {
                        if (waitingForReply)
                            return colors.waiting

                        return serverOnline
                            ? colors.online
                            : colors.offline
                    }
                }

                Text {
                    text: "Local AI"

                    color: colors.text

                    font {
                        pixelSize: 16
                        weight: Font.DemiBold
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: modelName.split("/").pop()

                    color: colors.muted

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

                        color: colors.muted
                        font.pixelSize: 13
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


        // ─────────────────────────────────────────────────────────
        // Chat
        // ─────────────────────────────────────────────────────────

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

                    width: Math.min(
                        messageText.implicitWidth + 28,
                        chat.width * 0.82
                    )

                    height: messageText.implicitHeight + 20

                    radius: 14

                    color: model.role === "user"
                        ? colors.userBubble
                        : colors.aiBubble

                    border.color: model.role === "user"
                        ? Qt.lighter(colors.userBubble, 1.6)
                        : colors.border

                    border.width: 1

                    anchors.right: model.role === "user"
                        ? parent.right
                        : undefined

                    anchors.left: model.role === "user"
                        ? undefined
                        : parent.left

                    Text {
                        id: messageText

                        anchors.fill: parent
                        anchors.margins: 10

                        text: model.content

                        color: colors.text

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

            Text {
                anchors.centerIn: parent

                visible: messages.count === 0

                text: "Ask something to get started"

                color: colors.muted
                font.pixelSize: 13
            }
        }


        // ─────────────────────────────────────────────────────────
        // Typing indicator
        // ─────────────────────────────────────────────────────────

        Text {
            Layout.leftMargin: 16
            Layout.bottomMargin: 4

            visible: waitingForReply

            text: "thinking…"

            color: colors.muted

            font {
                pixelSize: 11
                italic: true
            }
        }


        // ─────────────────────────────────────────────────────────
        // Input
        // ─────────────────────────────────────────────────────────

        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 12

            Layout.topMargin: waitingForReply
                ? 4
                : 12

            height: 46

            radius: 23

            color: colors.input

            border.color: input.activeFocus
                ? colors.accent
                : colors.inputBorder

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
                    placeholderTextColor: colors.muted

                    color: colors.text

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

                    Layout.alignment: Qt.AlignVCenter

                    color: input.text.trim() !== ""
                        ? colors.accent
                        : colors.inputBorder

                    Text {
                        anchors.centerIn: parent

                        text: "↑"

                        color: "white"

                        font {
                            pixelSize: 16
                            bold: true
                        }
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
