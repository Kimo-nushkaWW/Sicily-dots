#!/usr/bin/env python3
"""Регрессионные проверки для недавних исправлений K4.

Запускать из корня репозитория:

    python3 k4/tools/prueba_regresiones.py

Тесты не требуют работающего Quickshell: проверка записи подменяет внешние
команды, а остальные проверки сверяют только публичные точки интеграции.
"""

import contextlib
import io
import json
import pathlib
import subprocess
import sys
import tempfile
from argparse import Namespace


ROOT = pathlib.Path(__file__).resolve().parents[2]
TOOLS = ROOT / "k4" / "tools"
sys.path.insert(0, str(TOOLS))
import captura  # noqa: E402
import atajos  # noqa: E402


def fail(message):
    raise AssertionError(message)


def test_physical_keybind_is_displayed():
    """The AI bind keeps the G key in K4's live list."""
    combo = atajos.combinacion_runtime({"modmask": 64, "key": "G", "keycode": 0})
    if combo != "SUPER+G":
        fail("AI bind is displayed as " + repr(combo))

    bind_source = (ROOT / "k4" / "hypr" / "k4.lua").read_text()
    if 'mod .. " + code:42"' not in bind_source:
        fail("AI bind is not attached to the physical G key")


def test_clipboard_copy_source():
    """Clipboard-only screenshots retain a source for the result card."""
    old_work = captura.TRABAJO
    with tempfile.TemporaryDirectory() as temp:
        temp_path = pathlib.Path(temp)
        captura.TRABAJO = str(temp_path / "work")
        ruta = temp_path / "captura.png"
        args = Namespace(
            ambito="pantalla", geometria="", desde="", ruta=str(ruta),
            salida="", cursor=False, destino="portapapeles",
        )

        def fake_run(command, **kwargs):
            if command[0] == "grim":
                ruta.write_bytes(
                    b"\x89PNG\r\n\x1a\n"
                    + b"\x00\x00\x00\x0dIHDR"
                    + b"\x00\x00\x00\x01\x00\x00\x00\x01"
                    + b"\x08\x02\x00\x00\x00"
                    + b"\x90wS\xde"
                )
            return subprocess.CompletedProcess(command, 0, "", "")

        original_run = captura.subprocess.run
        captura.subprocess.run = fake_run
        output = io.StringIO()
        try:
            with contextlib.redirect_stdout(output):
                try:
                    captura.hacer_foto(args)
                except SystemExit as exc:
                    if exc.code != 0:
                        fail("clipboard screenshot exited with failure")
        finally:
            captura.subprocess.run = original_run
            captura.TRABAJO = old_work

        result = json.loads(output.getvalue())
        if result["ruta"] != "":
            fail("clipboard-only screenshot must not expose a saved path")
        copy_path = pathlib.Path(result["copia"])
        if not copy_path.is_file():
            fail("clipboard-only screenshot has no reusable copy")


def test_capture_destinations():
    """Screenshot and recording destinations are explicit and created on use."""
    old_fotos = captura.CARPETA_FOTOS
    old_videos = captura.CARPETA_VIDEOS
    with tempfile.TemporaryDirectory() as temp:
        captura.CARPETA_FOTOS = str(pathlib.Path(temp) / "Pictures" / "Screenshots")
        captura.CARPETA_VIDEOS = str(pathlib.Path(temp) / "Videos" / "Recordings")
        if captura.carpeta("fotos") != captura.CARPETA_FOTOS:
            fail("screenshot destination is not the configured Screenshots directory")
        if captura.carpeta("videos") != captura.CARPETA_VIDEOS:
            fail("recording destination is not the configured Recordings directory")
        if not captura.nombre("foto").startswith(captura.CARPETA_FOTOS + "/"):
            fail("generated screenshot filename is outside Screenshots")
        if not captura.nombre("video").startswith(captura.CARPETA_VIDEOS + "/"):
            fail("generated recording filename is outside Recordings")
        if not pathlib.Path(captura.CARPETA_FOTOS).is_dir():
            fail("screenshot destination is not created")
        if not pathlib.Path(captura.CARPETA_VIDEOS).is_dir():
            fail("recording destination is not created")
    captura.CARPETA_FOTOS = old_fotos
    captura.CARPETA_VIDEOS = old_videos


def test_integrations_are_wired():
    nix = (ROOT / "home" / "k4.nix").read_text()
    for package in ("wf-recorder", "ffmpeg", "pulseaudio", "satty", "zenity"):
        if package not in nix:
            fail("missing runtime dependency: " + package)

    bind = (ROOT / "k4" / "hypr" / "k4.lua").read_text()
    if "grabarAlternar" not in bind or "SHIFT + C" not in bind:
        fail("screen-recording bind is not wired")

    captura_qml = (ROOT / "k4" / "services" / "Captura.qml").read_text()
    for marker in ("ultimaRutaCopia", "function copiar", "xdg-open"):
        if marker not in captura_qml:
            fail("screenshot action is not wired: " + marker)

    captura_view = (ROOT / "k4" / "plugins" / "Captura" / "CapturaView.qml").read_text()
    if "Captura.ultimaRutaCopia.length > 0" not in captura_view:
        fail("copy action is disabled for clipboard-only screenshots")
    if "Captura.carpetaFotos.length > 0" not in captura_view:
        fail("folder action is disabled before/without a saved screenshot")
    if "z: 3" not in captura_view or "acceptedButtons: Qt.LeftButton" not in captura_view:
        fail("screenshot result buttons are not protected from the card hit area")

    tool = (ROOT / "k4" / "tools" / "captura.py").read_text()
    for marker in ("/home/kimo/Pictures/Screenshots", "/home/kimo/Videos/Recordings"):
        if marker not in tool:
            fail("capture destination is not explicit: " + marker)

    plugin = (ROOT / "k4" / "plugins" / "Captura" / "CapturaPlugin.qml").read_text()
    if "modo === \"hecha\" ? 620" not in plugin:
        fail("capture result/menu width was not expanded")

    notifs = (ROOT / "k4" / "services" / "Notifs.qml").read_text()
    if "function dismissOne" not in notifs:
        fail("individual notification dismissal is missing")
    if "n.tracked = false" not in notifs or "dismissNotification" not in notifs:
        fail("individual notification dismissal does not remove the tracked row")
    for view in ("k4/widgets/NotifStrip.qml", "k4/plugins/Panel/PanelView.qml"):
        if "Notifs.dismissOne" not in (ROOT / view).read_text():
            fail("individual dismissal is not used in " + view)


def test_disabled_plugins_are_hidden_from_apps_but_remain_in_settings():
    """Disabling a plugin removes it from Apps without removing its setting."""
    manager = (ROOT / "k4" / "services" / "PluginManager.qml").read_text()
    apps_filter = (
        ".filter(function (m) {\n"
        "            return m.aplicacion === true && estaHabilitado(m.id)\n"
        "        })"
    )
    if apps_filter not in manager:
        fail("Apps still includes disabled plugins")

    settings_start = manager.index("readonly property var opcionesAjustes")
    settings_end = manager.index("readonly property var aplicaciones")
    settings_model = manager[settings_start:settings_end]
    if "filter(function (m) { return m.configurable !== false })" not in settings_model:
        fail("plugin settings no longer include disabled plugins")
    if "estaHabilitado(m.id)" in settings_model:
        fail("plugin settings are incorrectly filtered by enabled state")


def test_notes_plugin_is_registered_and_persistent():
    """The Notes plugin is a normal app and its store is wired into K4."""
    catalog = json.loads((ROOT / "k4" / "plugins" / "catalog.json").read_text())
    notes = next((item for item in catalog["plugins"] if item["id"] == "notas"), None)
    if not notes:
        fail("Notes plugin is missing from the catalog")
    if notes.get("entry") != "Notas/NotasPlugin.qml" or not notes.get("aplicacion"):
        fail("Notes plugin is not an application entry")

    plugin = (ROOT / "k4" / "plugins" / "Notas" / "NotasPlugin.qml").read_text()
    view = (ROOT / "k4" / "plugins" / "Notas" / "NotasView.qml").read_text()
    for marker in ("name: \"notas\"", "self.fichero(\"notas.py\")",
                   "function toggleDone", "function removeNote", "K4.Lanzador",
                   "onTerminado: function (codigo)"):
        if marker not in plugin:
            fail("Notes plugin is missing integration: " + marker)
    for marker in ("Título (obligatorio)", "Descripción (opcional)",
                   "font.strikeout", "onTextEdited: view.plugin.setBody(text)"):
        if marker not in view:
            fail("Notes UI is missing: " + marker)
    if "Completadas" not in plugin:
        fail("Notes UI is missing the completed section")

    store = (ROOT / "k4" / "plugins" / "Notas" / "notas.py").read_text()
    for marker in ("Documents", "os.replace", "NOTES_DIR", "def delete_note"):
        if marker not in store:
            fail("Notes store is missing: " + marker)

    home_k4 = (ROOT / "home" / "k4.nix").read_text()
    if 'plugins/Notas/NotasPlugin.qml' not in home_k4:
        fail("uncommitted Notes files are not explicitly packaged")


def test_desktop_and_gaming_integrations():
    hypr = (ROOT / "home" / "hyprland.nix").read_text()
    for marker in (
        'configType = "lua"',
        'mod .. " + F"',
        'mod .. " + D"',
        '"zen-beta --name zen-beta"',
        '"steam -silent"',
        'workspace = "special:comms"',
        'monitor = "DVI-D-1"',
    ):
        if marker not in hypr:
            fail("missing desktop integration: " + marker)

    k4 = (ROOT / "k4" / "hypr" / "k4.lua").read_text()
    if 'mod .. " + code:42"' not in k4:
        fail("the active Lua K4 configuration has no physical G bind")

    if "hl.dsp.workspace.toggle_special(\"comms\")" not in hypr:
        fail("SUPER+D still uses the legacy special-workspace dispatcher")
    if "hyprctl dispatch togglespecialworkspace comms" in hypr:
        fail("the broken legacy special-workspace dispatcher is still present")
    if 'target_monitor="DVI-D-1"' in hypr:
        fail("SUPER+D must not force the communications workspace onto one monitor")
    if 'hl.dsp.focus({ monitor = \\"$target_monitor\\" })' in hypr:
        fail("SUPER+D must use the monitor where it is invoked")

    gaming = (ROOT / "hosts" / "sicily" / "configuration.nix").read_text()
    for package in ("gamescope", "mangohud", "vulkan-tools"):
        if package not in gaming:
            fail("missing gaming tool: " + package)
    if "gamescopeSession.enable = true" not in gaming:
        fail("Steam gamescope session is not enabled")

    ask = (ROOT / "k4" / "plugins" / "Ask" / "AskPlugin.qml").read_text()
    if 'K4.Paths.enRaiz("gemini.sh")' not in ask:
        fail("SUPER+G is not wired to the Gemini adapter")
    gemini = ROOT / "k4" / "gemini.sh"
    if not gemini.is_file() or not gemini.stat().st_mode & 0o111:
        fail("Gemini adapter is not executable")
    result = subprocess.run(["bash", "-n", str(gemini)], capture_output=True, text=True)
    if result.returncode != 0:
        fail("Gemini adapter has shell syntax errors: " + result.stderr)
    ask_text = ask
    if "Отвечай по-русски" not in ask_text or "Responde en español" in ask_text:
        fail("SUPER+G still instructs Gemini to answer in Spanish")
    if "systemInstruction" not in gemini.read_text():
        fail("Gemini adapter has no default Russian language instruction")


def test_no_automatic_idle_actions():
    hyprlock = (ROOT / "home" / "hyprlock.nix").read_text()
    for marker in ("services.hypridle", "systemctl suspend", "brightnessctl -s", "timeout ="):
        if marker in hyprlock:
            fail("automatic idle action is still configured: " + marker)
    if "programs.hyprlock" not in hyprlock:
        fail("manual hyprlock configuration disappeared")


def test_wallpaper_theme_boundaries():
    """Wallpaper colors update K4, but never become the system app theme."""
    theme = (ROOT / "home" / "theme.nix").read_text()
    default = (ROOT / "home" / "default.nix").read_text()
    nautilus = (ROOT / "home" / "nautilus.nix").read_text()
    k4_theme = (ROOT / "k4" / "core" / "Theme.qml").read_text()
    hyprtheme = (ROOT / "k4" / "plugins" / "HyprTheme" / "HyprThemePlugin.qml").read_text()

    if "gtk-colors.css" in nautilus or "gtk_lines" in theme:
        fail("wallpaper palette is still wired into GTK")
    if 'GTK_THEME = ' in default or "QT_STYLE_OVERRIDE" in default:
        fail("wallpaper/system palette override leaked into global environment")
    if 'colorScheme = "light"' not in nautilus:
        fail("system GTK light/dark mode is not explicit")
    if "function recargarPaleta()" not in k4_theme:
        fail("K4 palette has no explicit reload path")
    if "self.recargarPaleta()" not in hyprtheme:
        fail("wallpaper IPC does not refresh K4 palette")
    wallpaper = (ROOT / "home" / "theme.nix").read_text()
    if 'text = \'\'#!/usr/bin/env bash' not in wallpaper:
        fail("wallpaper helper has leading indentation before its shebang")
    gemini = (ROOT / "k4" / "gemini.sh").read_text()
    if "model=${GEMINI_MODEL:-gemini-3.6-flash}" not in gemini:
        fail("Gemini adapter still uses the retired default model")


if __name__ == "__main__":
    test_physical_keybind_is_displayed()
    test_clipboard_copy_source()
    test_capture_destinations()
    test_integrations_are_wired()
    test_disabled_plugins_are_hidden_from_apps_but_remain_in_settings()
    test_notes_plugin_is_registered_and_persistent()
    test_desktop_and_gaming_integrations()
    test_no_automatic_idle_actions()
    test_wallpaper_theme_boundaries()
    print("K4 regressions: ok")
