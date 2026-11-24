import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import K4 as K4
import "../../core"
import "../../services"

FadeIn {
    id: view
    required property var plugin

    property Item objetivoFoco: plugin.editing ? titulo : busqueda

    FocoInicial {
        id: foco
        objetivo: view.objetivoFoco
    }

    Component.onCompleted: foco.reclamar()
    Connections {
        target: view.plugin
        function onEditingChanged() { Qt.callLater(function () { foco.reclamar() }) }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 12
        anchors.bottomMargin: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            spacing: 8

            IconGlyph {
                text: String.fromCodePoint(0xF0FCE)
                color: Theme.blue
                font.pixelSize: 17
                Layout.alignment: Qt.AlignVCenter
            }

            IslandLabel {
                text: view.plugin.editing
                    ? (view.plugin.draft.id ? Idioma.t("Editar nota")
                                            : Idioma.t("Nueva nota"))
                    : Idioma.t("Notas")
                font.pixelSize: 15
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignVCenter
            }

            IslandLabel {
                visible: !view.plugin.editing
                text: String(view.plugin.notes.length)
                color: Theme.dim
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            MediaButton {
                visible: !view.plugin.editing
                glyph: String.fromCodePoint(0xF0415)
                glyphSize: 17
                glyphColor: Theme.blue
                onActivated: view.plugin.newNote()
                Layout.alignment: Qt.AlignVCenter
            }

            MediaButton {
                visible: view.plugin.editing
                glyph: Theme.ico.back
                glyphSize: 15
                glyphColor: Theme.muted
                onActivated: {
                    view.plugin.closeAfterSave = false
                    view.plugin.editing = false
                }
                Layout.alignment: Qt.AlignVCenter
            }

            MediaButton {
                glyph: Theme.ico.close
                glyphSize: 15
                glyphColor: Theme.muted
                onActivated: view.plugin.close()
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // ── список ────────────────────────────────────────────────
        ColumnLayout {
            visible: !view.plugin.editing
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 10
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    IconGlyph {
                        text: Theme.ico.search
                        color: Theme.muted
                        font.pixelSize: 15
                    }

                    TextInput {
                        id: busqueda
                        Layout.fillWidth: true
                        text: view.plugin.query
                        color: Theme.ink
                        font.family: Theme.uiFont
                        font.pixelSize: 13
                        clip: true
                        cursorDelegate: IslandCursor {}
                        onTextEdited: view.plugin.query = text

                        IslandLabel {
                            anchors.fill: parent
                            visible: busqueda.text.length === 0
                            text: Idioma.t("Buscar notas…")
                            color: Theme.dim
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Escape) {
                                view.plugin.close(); event.accepted = true
                            } else if (event.key === Qt.Key_Return
                                       || event.key === Qt.Key_Enter) {
                                if (view.plugin.filtered.length > 0)
                                    view.plugin.editNote(view.plugin.filtered[0])
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            ListView {
                id: lista
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: view.plugin.list
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: IslandScrollBar {}

                delegate: Item {
                    id: fila
                    required property var modelData
                    required property int index
                    readonly property bool seccion: !!modelData._section
                    width: ListView.view.width
                    height: seccion ? 25 : 64

                    IslandLabel {
                        visible: fila.seccion
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: fila.modelData.title
                        color: Theme.dim
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        id: tarjeta
                        visible: !fila.seccion
                        anchors.fill: parent
                        radius: 11
                        color: raton.containsMouse ? Theme.surfaceHi : Theme.surface

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 9

                            Rectangle {
                                Layout.preferredWidth: 21
                                Layout.preferredHeight: 21
                                Layout.alignment: Qt.AlignVCenter
                                radius: 6
                                color: fila.modelData.completed ? Theme.green : "transparent"
                                border.width: fila.modelData.completed ? 0 : 1
                                border.color: Theme.dim

                                IconGlyph {
                                    anchors.centerIn: parent
                                    visible: fila.modelData.completed
                                    text: Theme.ico.check
                                    color: Theme.islandBg
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: view.plugin.toggleDone(fila.modelData)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                IslandLabel {
                                    text: fila.modelData.title
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    font.strikeout: fila.modelData.completed
                                    color: fila.modelData.completed ? Theme.dim : Theme.ink
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                IslandLabel {
                                    visible: String(fila.modelData.description || "").length > 0
                                    text: fila.modelData.description || ""
                                    color: Theme.muted
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    visible: (fila.modelData.tags || []).length > 0
                                    spacing: 5

                                    Repeater {
                                        model: (fila.modelData.tags || []).slice(0, 4)
                                        delegate: IslandLabel {
                                            required property string modelData
                                            text: "#" + modelData
                                            color: Theme.blue
                                            font.pixelSize: 9
                                        }
                                    }
                                }
                            }

                            MediaButton {
                                glyph: Theme.ico.forward
                                glyphSize: 13
                                glyphColor: Theme.dim
                                onActivated: view.plugin.editNote(fila.modelData)
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: raton
                            anchors.fill: parent
                            z: -1
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: view.plugin.editNote(fila.modelData)
                        }
                    }
                }
            }

            IslandLabel {
                visible: view.plugin.loading
                text: Idioma.t("Cargando…")
                color: Theme.dim
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            IslandLabel {
                visible: !view.plugin.loading && view.plugin.list.length === 0
                text: view.plugin.query.length > 0
                    ? Idioma.t("No se encontraron notas")
                    : Idioma.t("Todavía no hay notas — añade la primera")
                color: Theme.muted
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        // ── редактор ─────────────────────────────────────────────
        ColumnLayout {
            id: editor
            visible: view.plugin.editing
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 7

                TextField {
                    id: titulo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    text: view.plugin.draft.title || ""
                    placeholderText: Idioma.t("Título (obligatorio)")
                    color: Theme.ink
                    font.family: Theme.uiFont
                    font.pixelSize: 14
                    selectByMouse: true
                    background: Rectangle {
                        radius: 10
                        color: Theme.surface
                    }
                    onTextEdited: view.plugin.changeDraft("title", text)
                }

                MediaButton {
                    glyph: view.plugin.dirty ? String.fromCodePoint(0xF05DF)
                                             : Theme.ico.check
                    glyphSize: 17
                    glyphColor: view.plugin.dirty ? Theme.blue : Theme.green
                    enabledAction: String(view.plugin.draft.title || "").trim().length > 0
                    onActivated: {
                        view.plugin.closeAfterSave = true
                        view.plugin.saveDraft()
                    }
                    Layout.alignment: Qt.AlignVCenter
                }

                IslandLabel {
                    text: Idioma.t("Listo")
                    color: Theme.green
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: view.plugin.draft.description || ""
                placeholderText: Idioma.t("Descripción (opcional)")
                color: Theme.ink
                font.family: Theme.uiFont
                font.pixelSize: 12
                selectByMouse: true
                background: Rectangle {
                    radius: 9
                    color: Theme.surface
                }
                onTextEdited: view.plugin.changeDraft("description", text)
            }

            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                text: (view.plugin.draft.tags || []).join(", ")
                placeholderText: Idioma.t("Etiquetas separadas por comas")
                color: Theme.blue
                font.family: Theme.uiFont
                font.pixelSize: 11
                selectByMouse: true
                background: Rectangle {
                    radius: 9
                    color: Theme.surface
                }
                onTextEdited: view.plugin.changeDraft("tags", text)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                IslandLabel {
                    text: Idioma.t("Texto de la nota")
                    color: Theme.dim
                    font.pixelSize: 10
                    Layout.fillWidth: true
                }

                MediaButton {
                    glyph: String.fromCodePoint(0xF0359)
                    glyphSize: 14
                    glyphColor: Theme.muted
                    onActivated: editor.preview = !editor.preview
                }

                MediaButton {
                    glyph: Theme.ico.close
                    glyphSize: 14
                    glyphColor: Theme.red
                    onActivated: view.plugin.removeNote()
                }
            }

            property bool preview: false

            TextArea {
                id: bodyEditor
                visible: !editor.preview
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: view.plugin.draft.body || ""
                placeholderText: Idioma.t("Texto en Markdown…")
                color: Theme.ink
                selectionColor: Theme.blue
                font.family: Theme.uiFont
                font.pixelSize: 12
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                background: Rectangle {
                    radius: 11
                    color: Theme.surface
                }
                onTextEdited: view.plugin.setBody(text)
            }

            Rectangle {
                visible: editor.preview
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 11
                color: Theme.surface

                TextEdit {
                    anchors.fill: parent
                    anchors.margins: 12
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.Wrap
                    textFormat: TextEdit.MarkdownText
                    text: view.plugin.draft.body || Idioma.t("Nota vacía")
                    color: Theme.ink
                    selectionColor: Theme.blue
                    font.family: Theme.uiFont
                    font.pixelSize: 13
                }
            }

            IslandLabel {
                visible: view.plugin.error.length > 0
                text: view.plugin.error
                color: Theme.red
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            IslandLabel {
                text: view.plugin.dirty
                    ? Idioma.t("Se guarda automáticamente")
                    : Idioma.t("Markdown · notas en Documents/Notes")
                color: Theme.dim
                font.pixelSize: 9
                Layout.fillWidth: true
            }
        }
    }
}
