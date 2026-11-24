//  Заметки: маленький список дел и мыслей прямо в K4.
//
//  Данные живут в Markdown-файлах ~/Documents/Notes. Python здесь не
//  «приложение внутри приложения», а тонкий файловый адаптер: QML отвечает
//  за состояние интерфейса, адаптер — за безопасные атомарные записи.

import QtQuick
import K4 as K4
import "../../core"
import "../../services"

K4Plugin {
    id: self

    name: "notas"
    title: Idioma.t("Notas")
    priority: 84
    active: habilitado && open
    viewLoaded: open
    grabKeyboard: open
    islandWidth: 700
    islandHeight: 640

    property bool open: false
    property bool editing: false
    property string query: ""
    property var notes: []
    property var draft: ({})
    property bool dirty: false
    property string error: ""
    property bool loading: false
    property int draftRevision: 0
    property int savedRevision: -1
    property bool closeAfterSave: false
    property var queuedSave: null

    readonly property var filtered: {
        const q = query.trim().toLowerCase()
        return notes.filter(function (note) {
            if (q.length === 0)
                return true
            const haystack = [note.title, note.description, note.body,
                              (note.tags || []).join(" ")]
                .join(" ").toLowerCase()
            return haystack.indexOf(q) >= 0
        })
    }

    // Заголовок секции — обычная запись модели, поэтому два ListView не
    // расходятся при поиске, а завершённые всегда оказываются внизу.
    readonly property var list: {
        const active = filtered.filter(function (note) { return !note.completed })
        const done = filtered.filter(function (note) { return note.completed })
        const result = active.slice()
        if (done.length > 0)
            result.push({ _section: true, title: Idioma.t("Completadas") })
        return result.concat(done)
    }

    view: Component { NotasView { plugin: self } }

    function emptyDraft() {
        return { id: "", title: "", description: "", completed: false,
                 tags: [], created: 0, updated: 0, body: "" }
    }

    function copyNote(note) {
        return Object.assign({}, note, { tags: (note.tags || []).slice() })
    }

    function openNotes() {
        open = true
        editing = false
        query = ""
        error = ""
        reload()
    }

    function abrir() { openNotes() }
    function toggle() { open ? close() : openNotes() }
    function close() {
        if (dirty && editing && String(draft.title || "").trim().length > 0) {
            closeAfterSave = true
            saveDraft()
            return
        }
        editing = false
        open = false
    }

    function newNote() {
        draft = emptyDraft()
        dirty = false
        error = ""
        draftRevision += 1
        savedRevision = draftRevision
        editing = true
    }

    function editNote(note) {
        draft = copyNote(note)
        dirty = false
        error = ""
        draftRevision += 1
        savedRevision = draftRevision
        editing = true
    }

    function changeDraft(field, value) {
        const next = copyNote(draft)
        next[field] = field === "tags" ? String(value).split(",") : value
        draft = next
        dirty = true
        draftRevision += 1
        error = ""
        autoSave.restart()
    }

    function setBody(value) { changeDraft("body", value) }

    function reload() {
        if (listProcess.running)
            return
        loading = true
        listProcess.running = true
    }

    function applyList(raw) {
        loading = false
        try {
            const data = JSON.parse(raw)
            if (!data.ok)
                throw new Error(data.error || "list failed")
            notes = data.notes || []
            error = ""
        } catch (e) {
            error = Idioma.t("No se pudieron cargar las notas")
        }
    }

    function updateNote(note) {
        const result = notes.slice()
        let found = false
        for (let i = 0; i < result.length; ++i) {
            if (result[i].id === note.id) {
                result[i] = note
                found = true
                break
            }
        }
        if (!found)
            result.push(note)
        notes = result
    }

    function startSave(data, closeWhenDone, fromEditor) {
        saveProcess.command = ["python3", self.fichero("notas.py"), "save",
            "--payload", JSON.stringify(data)]
        closeAfterSave = closeWhenDone
        saveFromEditor = fromEditor
        savedRevision = draftRevision
        saveProcess.running = true
    }

    property bool saveFromEditor: false

    function queueSave(data, closeWhenDone, fromEditor) {
        if (saveProcess.running) {
            queuedSave = { data: data, closeWhenDone: closeWhenDone,
                           fromEditor: fromEditor }
            return
        }
        startSave(data, closeWhenDone, fromEditor)
    }

    function saveDraft() {
        if (!editing)
            return
        if (String(draft.title || "").trim().length === 0) {
            error = Idioma.t("El título es obligatorio")
            closeAfterSave = false
            return
        }
        queueSave(copyNote(draft), closeAfterSave, true)
    }

    function finishSave(raw) {
        let data
        try { data = JSON.parse(raw) } catch (e) { data = null }
        if (!data || !data.ok || !data.note) {
            error = Idioma.t("No se pudo guardar la nota")
            return
        }

        updateNote(data.note)
        error = ""
        if (saveFromEditor) {
            draft = copyNote(data.note)
            if (savedRevision === draftRevision)
                dirty = false
        }

        if (queuedSave !== null) {
            const next = queuedSave
            queuedSave = null
            startSave(next.data, next.closeWhenDone, next.fromEditor)
            return
        }

        if (closeAfterSave && !dirty) {
            editing = false
            closeAfterSave = false
        } else if (dirty) {
            autoSave.restart()
        }
    }

    function toggleDone(note) {
        const next = copyNote(note)
        next.completed = !next.completed
        queueSave(next, false, false)
    }

    function removeNote() {
        if (!draft.id) {
            editing = false
            return
        }
        deleteProcess.command = ["python3", self.fichero("notas.py"),
            "delete", "--id", draft.id]
        deleteProcess.running = true
    }

    function finishDelete(code) {
        if (code !== 0) {
            error = Idioma.t("No se pudo eliminar la nota")
            return
        }
        notes = notes.filter(function (note) { return note.id !== draft.id })
        editing = false
        dirty = false
        error = ""
    }

    Timer {
        id: autoSave
        interval: 850
        onTriggered: if (self.dirty) self.saveDraft()
    }

    K4.Process {
        id: listProcess
        command: ["python3", self.fichero("notas.py"), "list"]
        onSalida: function (texto) { self.applyList(texto) }
        onTerminado: function (codigo) { self.loading = false }
    }

    K4.Process {
        id: saveProcess
        onSalida: function (texto) { self.finishSave(texto) }
        onTerminado: function (codigo) {
            if (codigo !== 0 && self.error.length === 0)
                self.error = Idioma.t("No se pudo guardar la nota")
        }
        onLineaError: function (texto) { if (texto.length > 0) console.warn("notas:", texto) }
    }

    K4.Process {
        id: deleteProcess
        onTerminado: function (codigo) { self.finishDelete(codigo) }
        onLineaError: function (texto) { if (texto.length > 0) console.warn("notas:", texto) }
    }

    K4.Lanzador {
        plugin: "notas"
        onBuscando: function (texto) {
            const q = texto.trim().toLowerCase()
            if (q.length < 2) {
                resultados = []
                return
            }
            resultados = self.notes.filter(function (note) {
                return [note.title, note.description, note.body,
                        (note.tags || []).join(" ")].join(" ")
                    .toLowerCase().indexOf(q) >= 0
            }).slice(0, 8).map(function (note) {
                return { id: note.id, titulo: note.title,
                         desc: note.completed ? Idioma.t("Completada")
                                              : (note.description || Idioma.t("Nota")),
                         glifo: 0xF0FCE }
            })
        }
        onElegido: function (id) {
            for (let i = 0; i < self.notes.length; ++i) {
                if (self.notes[i].id === id) {
                    self.openNotes()
                    self.editNote(self.notes[i])
                    break
                }
            }
        }
    }

    K4.Ipc {
        target: "k4.notas"
        function toggle(): void { self.toggle() }
        function open(): void { self.openNotes() }
        function close(): void { self.close() }
        function newNote(): void { self.openNotes(); self.newNote() }
    }

    Component.onCompleted: reload()
}
