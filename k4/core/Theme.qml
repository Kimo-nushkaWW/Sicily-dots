pragma Singleton

//  Tokens de diseño de la island (macOS Dynamic Island / Atoll).
//  No depende de nada: es la base del grafo de imports.

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: tema

    readonly property string uiFont: "Adwaita Sans"
    //  La variante Mono, a propósito: en la Nerd Font 3.5 el build
    //  proporcional trae varios iconos con la tinta más ancha que su caja
    //  (el wifi se salía +2px por la derecha del círculo); en la Mono cada
    //  glifo está clavado a su celda.
    readonly property string iconFont: "MesloLGS Nerd Font Mono"
    readonly property var locale: Qt.locale("es_ES")

    //  El andamio neutro sale de estas bases y del tinte de más abajo. La
    //  tinta, los apagados y los colores con significado (verde, rojo, azul,
    //  amarillo) no se tiñen: el texto tiene que leerse y un rojo de alerta
    //  tiene que seguir siendo rojo bajo cualquier ambiente.
    property color paletteBackground: "#000000"
    property color paletteForeground: "#ffffff"
    property color wallpaperAccent: "#0a84ff"

    readonly property color _islandBgBase: paletteBackground
    readonly property color _surfaceBase: Qt.tint(paletteBackground,
        Qt.rgba(wallpaperAccent.r, wallpaperAccent.g, wallpaperAccent.b, 0.22))
    readonly property color _surfaceHiBase: Qt.tint(paletteBackground,
        Qt.rgba(wallpaperAccent.r, wallpaperAccent.g, wallpaperAccent.b, 0.36))
    readonly property color _trackBase: Qt.tint(paletteBackground,
        Qt.rgba(paletteForeground.r, paletteForeground.g, paletteForeground.b, 0.24))

    readonly property color islandBg: _tinta(_islandBgBase)
    readonly property color ink: paletteForeground
    readonly property color muted: Qt.rgba(paletteForeground.r, paletteForeground.g,
        paletteForeground.b, 0.62)
    readonly property color dim: Qt.rgba(paletteForeground.r, paletteForeground.g,
        paletteForeground.b, 0.32)
    readonly property color surface: _tinta(_surfaceBase)
    readonly property color surfaceHi: _tinta(_surfaceHiBase)
    readonly property color track: _tinta(_trackBase)
    readonly property color green: "#30d158"
    readonly property color red: "#ff453a"
    readonly property color blue: wallpaperAccent
    // Para el audio añadido. Es el amarillo del sistema en su versión oscura,
    // de la misma familia que el verde y el rojo de arriba.
    readonly property color yellow: "#ffd60a"

    readonly property string paletaWal: Quickshell.env("HOME")
        + "/.cache/wal/colors.json"

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

        const special = d.special || ({})
        const colors = d.colors || ({})
        if (colorValido(special.background))
            paletteBackground = special.background
        if (colorValido(special.foreground))
            paletteForeground = special.foreground
        if (colorValido(colors.color4))
            wallpaperAccent = colors.color4
    }

    // colors.json is replaced atomically by k4-palette.  Explicit reload is
    // needed because a watcher can otherwise remain attached to the old inode.
    function recargarPaleta() {
        paleta.reload()
    }

    FileView {
        id: paleta
        path: tema.paletaWal
        watchChanges: true
        onLoaded: tema.cargarPaleta(text())
        onFileChanged: reload()
    }

    // ── tinte ─────────────────────────────────────────────────────
    //
    //  El ambiente de la barra, prestado a los plugins: un juego puede teñir
    //  el andamio entero —island, superficies, carriles— y todo lo que pinta
    //  con el tema se recolorea solo, por reactividad. Los límites los pone
    //  la casa: la fuerza se recorta para que la barra siga siendo la barra,
    //  el tinte tiene dueño, y al deshabilitar al dueño se destiñe solo
    //  (PluginManager llama a destintar al destruir).
    property string tinteDueno: ""
    property color tinteColor: "transparent"
    property real tinteFuerza: 0

    //  Suave al entrar y al salir: un cambio de ambiente, no un fogonazo.
    Behavior on tinteFuerza { NumberAnimation { duration: 420 } }
    Behavior on tinteColor { ColorAnimation { duration: 420 } }

    function _tinta(base) {
        return tinteFuerza <= 0 ? base
            : Qt.tint(base, Qt.rgba(tinteColor.r, tinteColor.g,
                                    tinteColor.b, tinteFuerza))
    }

    //  `fuerza` 0..1 se recorta a 0.45; `duracionMs` 0 es «hasta destintar».
    //  Última llamada gana: el arbitraje fino no compensa aquí, porque teñir
    //  es cosmético y quien molesta se apaga en Ajustes.
    function tintar(dueno, color, fuerza, duracionMs) {
        if (!dueno)
            return
        tinteDueno = String(dueno)
        tinteColor = color
        tinteFuerza = Math.max(0, Math.min(0.45, Number(fuerza) || 0))
        if (duracionMs > 0)
            _destinte.armar(duracionMs)
        else
            _destinte.stop()
    }

    function destintar(dueno) {
        if (tinteDueno === "" || (dueno && dueno !== tinteDueno))
            return
        tinteDueno = ""
        tinteFuerza = 0
        _destinte.stop()
    }

    property var _destinte: Timer {
        onTriggered: tema.destintar(tema.tinteDueno)
        function armar(ms) { stop(); interval = ms; start() }
    }

    // Geometría de la island
    readonly property int wing: 16              // radio de la esquina invertida que funde con el borde
    readonly property int baseHeight: 34        // alto plegado, y franja reservada a las ventanas
    //  Techo de la superficie, ver PanelWindow.
    //
    //  Subió a 640 por el editor, que lleva vídeo dentro y con 520 se quedaba en
    //  una tira. Y a 880 cuando el editor empezó a crecer con las bandas de
    //  capas: con dos pedía 668 y el pie —los botones de añadir y de
    //  renderizar— quedaba cortado por debajo del borde de la island. El síntoma
    //  no señalaba aquí en absoluto, que es lo que costó encontrarlo.
    //
    //  880 en una pantalla de 1080 deja doscientos píxeles: sigue siendo una
    //  barra y no una ventana. El segundo módulo más alto es el juego, con 470.
    readonly property int maxIslandHeight: 880

    // Iconos Material Design de la Nerd Font (plano suplementario → fromCodePoint)
    readonly property var ico: ({
        play: String.fromCodePoint(0xF040A),
        pause: String.fromCodePoint(0xF03E4),
        next: String.fromCodePoint(0xF04AD),
        prev: String.fromCodePoint(0xF04AE),
        shuffle: String.fromCodePoint(0xF049D),
        repeat: String.fromCodePoint(0xF0456),
        repeatOne: String.fromCodePoint(0xF0458),
        output: String.fromCodePoint(0xF0F5F),
        music: String.fromCodePoint(0xF0387),
        wifi: String.fromCodePoint(0xF05A9),
        wifiOff: String.fromCodePoint(0xF05AA),
        bluetooth: String.fromCodePoint(0xF00AF),
        bluetoothOff: String.fromCodePoint(0xF00B2),
        volHigh: String.fromCodePoint(0xF057E),
        volMed: String.fromCodePoint(0xF0580),
        volOff: String.fromCodePoint(0xF0581),
        bell: String.fromCodePoint(0xF009A),
        bellOutline: String.fromCodePoint(0xF009C),
        search: String.fromCodePoint(0xF0349),
        chevronUp: String.fromCodePoint(0xF0143),
        chevronDown: String.fromCodePoint(0xF0140),
        cog: String.fromCodePoint(0xF0493),
        close: String.fromCodePoint(0xF0156),
        clearAll: String.fromCodePoint(0xF039F),
        apps: String.fromCodePoint(0xF003B),
        enter: String.fromCodePoint(0xF0311),
        ask: String.fromCodePoint(0xF0674),
        shot: String.fromCodePoint(0xF0E51),
        selection: String.fromCodePoint(0xF05E7),
        copy: String.fromCodePoint(0xF018F),
        alert: String.fromCodePoint(0xF0026),
        back: String.fromCodePoint(0xF0141),
        forward: String.fromCodePoint(0xF0142),
        loading: String.fromCodePoint(0xF0772),
        install: String.fromCodePoint(0xF03D4),
        uninstall: String.fromCodePoint(0xF09E7),
        package: String.fromCodePoint(0xF03D7),
        installed: String.fromCodePoint(0xF05E0),
        lock: String.fromCodePoint(0xF033E),
        check: String.fromCodePoint(0xF012C),
        linkOff: String.fromCodePoint(0xF0338),
        devices: String.fromCodePoint(0xF0FB0),
        headphones: String.fromCodePoint(0xF02CB),
        cellphone: String.fromCodePoint(0xF011C),
        mouse: String.fromCodePoint(0xF037D),
        keyboard: String.fromCodePoint(0xF030C),
        speaker: String.fromCodePoint(0xF04C3),
        watch: String.fromCodePoint(0xF0589),
        gamepad: String.fromCodePoint(0xF0EB5),
        laptop: String.fromCodePoint(0xF0322),
        printer: String.fromCodePoint(0xF042A),
        television: String.fromCodePoint(0xF0502),
        wifi0: String.fromCodePoint(0xF092D),
        wifi1: String.fromCodePoint(0xF091F),
        wifi2: String.fromCodePoint(0xF0922),
        wifi3: String.fromCodePoint(0xF0925),
        wifi4: String.fromCodePoint(0xF0928),
        // md-palette · md-border_all · md-blur · md-wallpaper · md-animation
        place: String.fromCodePoint(0xF034E),
        palette: String.fromCodePoint(0xF03D8),
        window: String.fromCodePoint(0xF00C7),
        effects: String.fromCodePoint(0xF00B5),
        wallpaper: String.fromCodePoint(0xF0E09),
        animation: String.fromCodePoint(0xF05D8),
        image: String.fromCodePoint(0xF02E9)
    })
}
