//  Tematizar Hyprland desde la island: colores, ventanas, efectos y fondo.
//
//  Hyprland usa el parser hyprlang, así que los cambios en caliente van por
//  `hyprctl keyword`. `hyprctl eval` solo está disponible con el gestor Lua.
//
//  La configuración de Hyprland la gestiona Nix en hyprland.lua; K4 conserva solo
//  su estado de interfaz en ~/.local/state/k4.

import QtQuick
import K4 as K4
import "../../core"
import "../../services"

K4Plugin {
    id: self

    name: "hyprtheme"
    title: Idioma.t("Tema de Hyprland")
    priority: 65
    active: habilitado && open
    //  El teclado entero mientras está abierto: «opcional» es OnDemand y
    //  el compositor solo lo da si PINCHAS la superficie, así que abierto
    //  desde el centro de aplicaciones o por atajo no llegaba ni el ESC.
    //  Ver `tecladoOpcional` en api/K4/Plugin.qml.
    grabKeyboard: open

    property bool open: false
    property string tab: "ventanas"    // "ventanas" | "efectos" | "fondo"

    islandWidth: 880
    islandHeight: 470

    handlesBackgroundTap: true
    onBackgroundTapped: {}   // se traga el clic: cerrar es cosa del botón

    // Se abre con el ratón, así que se va al sacarlo. Con más margen que el
    // panel: aquí se arrastran deslizadores y es fácil pasarse del borde.
    closeOnHoverExit: true
    hoverExitDelay: 1000
    onHoverTimedOut: close()

    readonly property string stateFile: K4.Sistema.entorno("HOME") + "/.local/state/k4/hyprtheme.json"

    // ── ajustes ───────────────────────────────────────────────────
    property color accentFrom: "#82dccc"
    property color accentTo: "#007d6f"
    property color inactive: "#798bb2"
    property int angle: 45

    property int gapsIn: 3
    property int gapsOut: 8
    property int borderSize: 2
    property int rounding: 10

    property bool blur: true
    property int blurSize: 5
    property int blurPasses: 4
    property real activeOpacity: 0.95
    property real inactiveOpacity: 0.85
    property bool shadow: true

    property bool animEnabled: true
    property int animSpeed: 3

    property string wallpaper: ""

    readonly property string paletteFile: K4.Sistema.entorno("HOME")
        + "/.cache/wal/colors.json"

    // ── color → el formato que espera Hyprland ────────────────────
    // hl.config quiere "rgba(rrggbbaa)"; QML da "#rrggbb" o "#aarrggbb".
    function hypr(color) {
        const hex = String(color)
        if (hex.length === 9)                       // #aarrggbb
            return "rgba(" + hex.substring(3) + hex.substring(1, 3) + ")"
        return "rgba(" + hex.substring(1) + "ff)"   // #rrggbb
    }

    // ── paleta de wal → estado de HyprTheme ───────────────────────
    function colorValido(valor) {
        return typeof valor === "string"
            && /^#[0-9a-fA-F]{6}$/.test(valor)
    }

    function cargarPaleta(bruto) {
        let d
        try {
            d = JSON.parse(bruto)
        } catch (e) {
            return
        }

        const colors = d.colors || ({})
        const nuevoFrom = colorValido(colors.color4) ? colors.color4 : ""
        const nuevoTo = colorValido(colors.color12) ? colors.color12 : nuevoFrom
        const nuevoInactive = colorValido(colors.color8) ? colors.color8 : ""
        if (nuevoFrom.length === 0 || nuevoInactive.length === 0)
            return

        accentFrom = nuevoFrom
        accentTo = nuevoTo
        inactive = nuevoInactive
        saveState()
        apply()
    }

    // ── aplicar en caliente con el parser hyprlang ────────────────
    function keywordBody() {
        return "set -e\n"
            + "hyprctl keyword general:gaps_in " + gapsIn + "\n"
            + "hyprctl keyword general:gaps_out " + gapsOut + "\n"
            + "hyprctl keyword general:border_size " + borderSize + "\n"
            + "hyprctl keyword general:col.active_border '"
                + hypr(accentFrom) + " " + hypr(accentTo) + " " + angle + "deg'\n"
            + "hyprctl keyword general:col.inactive_border '" + hypr(inactive) + "'\n"
            + "hyprctl keyword decoration:rounding " + rounding + "\n"
            + "hyprctl keyword decoration:active_opacity " + activeOpacity.toFixed(2) + "\n"
            + "hyprctl keyword decoration:inactive_opacity " + inactiveOpacity.toFixed(2) + "\n"
            + "hyprctl keyword decoration:blur:enabled " + (blur ? "true" : "false") + "\n"
            + "hyprctl keyword decoration:blur:size " + blurSize + "\n"
            + "hyprctl keyword decoration:blur:passes " + blurPasses + "\n"
            + "hyprctl keyword decoration:shadow:enabled " + (shadow ? "true" : "false") + "\n"
            + "hyprctl keyword animations:enabled " + (animEnabled ? "true" : "false")
    }

    function apply() {
        applyProcess.command = ["sh", "-c", keywordBody()]
        applyProcess.running = true
        saveState()
    }

    // ── persistir ─────────────────────────────────────────────────
    function persist() { saveState() }

    function isPersisted() {
        return stateView.text().length > 0
    }

    // ── estado propio, para reabrir con los mismos valores ────────
    function saveState() {
        stateView.setText(JSON.stringify({
            accentFrom: String(accentFrom),
            accentTo: String(accentTo),
            inactive: String(inactive),
            angle: angle,
            gapsIn: gapsIn, gapsOut: gapsOut, borderSize: borderSize, rounding: rounding,
            blur: blur, blurSize: blurSize, blurPasses: blurPasses,
            activeOpacity: activeOpacity, inactiveOpacity: inactiveOpacity, shadow: shadow,
            animEnabled: animEnabled, animSpeed: animSpeed,
            wallpaper: wallpaper
        }, null, 2))
    }

    function loadState() {
        const raw = stateView.text()
        if (raw.length === 0)
            return

        let s
        try {
            s = JSON.parse(raw)
        } catch (e) {
            return
        }

        accentFrom = s.accentFrom !== undefined ? s.accentFrom : accentFrom
        accentTo = s.accentTo !== undefined ? s.accentTo : accentTo
        inactive = s.inactive !== undefined ? s.inactive : inactive
        angle = s.angle !== undefined ? s.angle : angle
        gapsIn = s.gapsIn !== undefined ? s.gapsIn : gapsIn
        gapsOut = s.gapsOut !== undefined ? s.gapsOut : gapsOut
        borderSize = s.borderSize !== undefined ? s.borderSize : borderSize
        rounding = s.rounding !== undefined ? s.rounding : rounding
        blur = s.blur !== undefined ? s.blur : blur
        blurSize = s.blurSize !== undefined ? s.blurSize : blurSize
        blurPasses = s.blurPasses !== undefined ? s.blurPasses : blurPasses
        activeOpacity = s.activeOpacity !== undefined ? s.activeOpacity : activeOpacity
        inactiveOpacity = s.inactiveOpacity !== undefined ? s.inactiveOpacity : inactiveOpacity
        shadow = s.shadow !== undefined ? s.shadow : shadow
        animEnabled = s.animEnabled !== undefined ? s.animEnabled : animEnabled
        animSpeed = s.animSpeed !== undefined ? s.animSpeed : animSpeed
        wallpaper = s.wallpaper !== undefined ? s.wallpaper : wallpaper
        apply()
        // Si el detector del daemon terminó antes de leer el estado, no
        // habrá cambio de wallTool que dispare la aplicación; cubrimos ese
        // orden de inicialización también.
        if (wallTool.length > 0 && wallpaper.length > 0)
            applyWallpaper(wallpaper)
    }

    // ── fondo de pantalla ─────────────────────────────────────────
    // El proyecto swww se renombró a awww, así que se acepta cualquiera de los
    // dos; swaybg es el plan C: sin transiciones y hay que relanzarlo.
    property string wallTool: ""       // "awww" | "swww" | "swaybg" | ""
    property var wallpapers: []

    readonly property var wallDirs: [
        K4.Sistema.entorno("HOME") + "/wallpapers",
        K4.Sistema.entorno("HOME") + "/Sicily-dots/wallpapers",
        K4.Sistema.entorno("HOME") + "/Imágenes",
        K4.Sistema.entorno("HOME") + "/Pictures",
        K4.Sistema.entorno("HOME") + "/Descargas",
        "/usr/share/wallpapers",
        "/usr/share/backgrounds"
    ]

    function applyWallpaper(path) {
        if (path.length === 0 || wallTool.length === 0)
            return false

        if (wallTool === "swaybg") {
            // swaybg no sabe recargar: se mata y se levanta otro.
            K4.Sistema.lanzar(["sh", "-c",
                "pkill -x swaybg 2>/dev/null || true; swaybg -i "
                + JSON.stringify(path) + " -m fill >/dev/null 2>&1 &"])
        } else {
            // awww y swww aceptan la misma orden. Si el daemon aún no está
            // levantado, se arranca y se reintenta la imagen.
            K4.Sistema.lanzar(["sh", "-c",
                wallTool + " img " + JSON.stringify(path)
                + " --transition-type grow --transition-fps 60 >/dev/null 2>&1"
                + " || { " + wallTool + "-daemon >/dev/null 2>&1 & sleep 1; "
                + wallTool + " img " + JSON.stringify(path) + " >/dev/null 2>&1; }"])
        }
        return true
    }

    function setWallpaper(path) {
        setWallpaperWithPalette(path, true)
    }

    function setWallpaperWithPalette(path, actualizarTema) {
        if (path.length === 0)
            return

        // El script externo ya ejecuta matugen y wal antes de llamar a este
        // IPC. Un clic en la cuadrícula no pasa por ese script, por eso aquí se
        // regenera la paleta solo en ese caso.
        if (actualizarTema) {
            // Un clic desde K4 debe usar exactamente la misma cadena que el
            // alias `wallpaper`: además de awww/matugen/wal, crea el include
            // de Foot y vuelve a entrar por este plugin mediante IPC.
            K4.Sistema.lanzar([
                K4.Sistema.entorno("HOME") + "/.local/bin/wallpaper", path
            ])
        }

        wallpaper = path
        saveState()
        applyWallpaper(path)
    }

    function recargarPaleta() {
        paletteView.reload()
        if (K4.Puente.tema)
            K4.Puente.tema.recargarPaleta()
    }

    function refreshWallpapers() {
        const args = ["find"]
        for (let i = 0; i < wallDirs.length; ++i)
            args.push(wallDirs[i])
        wallScan.command = args.concat([
            "-maxdepth", "3", "-type", "f",
            "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o",
            "-iname", "*.png", "-o", "-iname", "*.webp", ")"
        ])
        wallScan.running = true
    }

    function toggle() {
        open = !open
        if (open) {
            if (panel) panel.close()
            Notifs.dismissToast()
        }
    }

    // El escaneo va atado al estado, no a una función de entrada: así vale
    // igual abriendo desde el panel, por IPC o saltando directo a la pestaña.
    onOpenChanged: if (open) refreshWallpapers()
    onTabChanged: if (tab === "fondo") refreshWallpapers()
    onWallpaperChanged: if (open && tab === "fondo") refreshWallpapers()
    onWallToolChanged: if (wallTool.length > 0 && wallpaper.length > 0)
        applyWallpaper(wallpaper)

    function close() { open = false }

    // lo aparta al abrirse; lo inyecta el host
    property var panel: null

    // ── archivos ──────────────────────────────────────────────────
    K4.Fichero { id: stateView; path: self.stateFile; blockLoading: true }

    K4.Process { id: applyProcess }

    K4.Fichero {
        id: paletteView
        path: self.paletteFile
        watchChanges: true
        onLoaded: self.cargarPaleta(text())
        onFileChanged: reload()
    }

    K4.Process {
        // el estado vive en ~/.local/state/k4, que puede no existir aún
        command: ["mkdir", "-p", K4.Paths.estado]
        running: true
        onTerminado: self.loadState()
    }

    K4.Process {
        id: toolScan
        command: ["sh", "-c",
            "command -v awww || command -v swww || command -v swaybg || true"]
        running: true

        onSalida: function (texto) {
            const found = texto.trim().split("\n")[0]
            if (found.length === 0)
                return
            self.wallTool = found.substring(found.lastIndexOf("/") + 1)
        }
    }

    K4.Process {
        id: wallScan

        onSalida: function (texto) {
            const found = texto.trim().split("\n").filter(function (p) { return p.length > 0 })
            found.sort()
            self.wallpapers = found.slice(0, 120)
        }
    }

    K4.Ipc {
        target: "k4.theme"
        function toggle(): void { self.toggle() }
        function close(): void { self.close() }
        function apply(): void { self.apply() }
        function save(): void { self.persist() }
        function tab(name: string): void {
            self.open = true
            self.tab = name
        }
        function wallpaper(path: string): void {
            self.setWallpaperWithPalette(path, false)
            self.recargarPaleta()
        }
    }

    view: Component {
        HyprThemeView { plugin: self }
    }
}
