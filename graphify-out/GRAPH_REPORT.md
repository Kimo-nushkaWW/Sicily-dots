# Graph Report - /home/kimo/Sicily-dots  (2026-08-22)

## Corpus Check
- 210 files · ~400,737 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1166 nodes · 2345 edges · 65 communities (62 shown, 3 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 112 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Plugin System Tests
- Video Editor Tests
- Digimon Game State Tests
- Video Editor Layer Tests
- Video Editor Core (editar.py)
- Video Editor I/O and Graph
- Video Effects and Filters
- Audio Layer Tests
- Installer and Setup
- Digivice Battle Rules (JS)
- Digimon Balance Engine
- Video Shape and Animation
- Video Audio Compositing Tests
- AI Agent Token Tracking
- Video Camera and Probing
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63

## God Nodes (most connected - your core abstractions)
1. `igual()` - 134 edges
2. `con_capas()` - 67 edges
3. `igual()` - 63 edges
4. `plan()` - 47 edges
5. `capa()` - 38 edges
6. `grafo()` - 24 edges
7. `fichero()` - 24 edges
8. `carpeta()` - 24 edges
9. `manifiesto_base()` - 23 edges
10. `cerca()` - 22 edges

## Surprising Connections (you probably didn't know these)
- `validar_carpeta()` --calls--> `mal()`  [INFERRED]
  k4/tools/plugins.py → k4/instalar  _Bridges community 8 → community 21_
- `main()` --indirect_call--> `orden_proponer()`  [INFERRED]
  k4/tools/editar.py → k4/tools/editar.py  _Bridges community 14 → community 5_
- `main()` --indirect_call--> `orden_camara()`  [INFERRED]
  k4/tools/editar.py → k4/tools/editar.py  _Bridges community 4 → community 5_
- `estadoQueInflige()` --calls--> `arquetipoDe()`  [EXTRACTED]
  k4/services/DigiviceReglas.js → k4/services/DigiviceReglas.js  _Bridges community 33 → community 19_
- `statsDe()` --calls--> `topeEntreno()`  [EXTRACTED]
  k4/services/DigiviceReglas.js → k4/services/DigiviceReglas.js  _Bridges community 32 → community 33_

## Import Cycles
- None detected.

## Communities (65 total, 3 thin omitted)

### Community 0 - "Plugin System Tests"
Cohesion: 0.07
Nodes (84): arbol(), carpeta(), con_ficheros(), contiene(), DestinoAparte, dice(), formulario(), _git() (+76 more)

### Community 1 - "Video Editor Tests"
Cohesion: 0.05
Nodes (76): cerca(), con_rastro(), plan(), prueba_a_lienzo(), prueba_a_linea_deshace_el_mapa(), prueba_atempo_se_encadena_por_debajo_de_medio(), prueba_clics_a_tiempo_de_linea(), prueba_clics_apagados() (+68 more)

### Community 2 - "Digimon Game State Tests"
Cohesion: 0.03
Nodes (63): a1, a2, adultos, adultos2, adultosCrudos, atascados, atascos, aTope (+55 more)

### Community 3 - "Video Editor Layer Tests"
Cohesion: 0.05
Nodes (64): capa(), con_capas(), prueba_aspecto_va_antes_de_la_opacidad(), prueba_bandas_conserva_el_orden_dentro(), prueba_bandas_los_planes_viejos_no_se_mueven(), prueba_bandas_manda_la_banda(), prueba_capa_centro_y_tamano(), prueba_capa_opacidad() (+56 more)

### Community 4 - "Video Editor Core (editar.py)"
Cohesion: 0.06
Nodes (52): a_lienzo(), a_linea(), adelgazar(), cadena_atempo(), caja(), clics_de(), dentro_de(), dibujar_anillo() (+44 more)

### Community 5 - "Video Editor I/O and Graph"
Cohesion: 0.09
Nodes (44): abrir_entradas(), cargar(), carpeta_de(), entradas(), es_local(), escribir_grafo(), exigir_dentro(), exigir_local() (+36 more)

### Community 6 - "Video Effects and Filters"
Cohesion: 0.08
Nodes (40): alfa_texto(), caja_recorte_fuente(), capa_animada(), color_ffmpeg(), curvar(), desplazamiento_sombra(), efecto_de(), efectos_video() (+32 more)

### Community 7 - "Audio Layer Tests"
Cohesion: 0.06
Nodes (37): igual(), pista_audio(), prueba_audio_en_una_previa_no_entra(), prueba_audio_entra_con_retardo_y_volumen(), prueba_audio_no_pinta_nada(), prueba_audio_se_suma_sin_bajar_lo_de_debajo(), prueba_audio_sin_retardo_no_pone_adelay(), prueba_carpeta_adjunta_de_los_dos_nombres() (+29 more)

### Community 8 - "Installer and Setup"
Cohesion: 0.21
Nodes (27): instalar script, aviso(), ayuda(), bien(), clonar_y_seguir(), diagnosticar(), en_lista(), ficheros_hypr() (+19 more)

### Community 9 - "Digivice Battle Rules (JS)"
Cohesion: 0.09
Nodes (13): armorConLoQueTienes(), armoresDe(), comidaDe(), cumpleRequisitos(), faltaPara(), jogressCon(), jogressDe(), objetoDe() (+5 more)

### Community 10 - "Digimon Balance Engine"
Cohesion: 0.07
Nodes (18): bitsObjetivos, comb, comidas, cuenta, ENF, etapasReales, filas, fs (+10 more)

### Community 11 - "Video Shape and Animation"
Cohesion: 0.08
Nodes (27): caja_zona(), capas_de(), dibujar_forma(), duraciones_transicion(), expresion(), filtro_color(), filtros_fundido(), fuerza_zona() (+19 more)

### Community 12 - "Video Audio Compositing Tests"
Cohesion: 0.08
Nodes (24): fichero(), prueba_agachado_cruzado_no_hace_bucle(), prueba_agacharse_con_otra_capa(), prueba_capa_de_audio_con_escoba(), prueba_capa_de_audio_con_recorte(), prueba_capa_de_audio_que_se_agacha(), prueba_capa_de_audio_sin_recorte_sigue_igual(), prueba_capas_por_defecto_a_la_dos() (+16 more)

### Community 13 - "AI Agent Token Tracking"
Cohesion: 0.13
Nodes (22): epoca(), lee_claude(), lee_codex(), limites_claude(), mira(), primero(), Un instante ISO-8601 en segundos desde la época, o None., La lista `limits` de Claude, en la forma de la casa. (+14 more)

### Community 14 - "Video Camera and Probing"
Cohesion: 0.11
Nodes (22): capa_camara(), correr_sondeo(), describir_fuente(), describir_imagen(), duracion_linea(), duracion_sonda(), es_imagen(), migrar() (+14 more)

### Community 15 - "Community 15"
Cohesion: 0.15
Nodes (21): buscar(), cargar_usuario(), comprobar(), _contexto(), _decir(), instalados(), json_buscar(), json_comprobar() (+13 more)

### Community 16 - "Community 16"
Cohesion: 0.17
Nodes (19): carpeta(), etiqueta_audio(), hacer_foto(), listar_audios(), main(), medir(), nombre(), Ancho y alto leídos de la cabecera PNG, sin abrir la imagen entera. (+11 more)

### Community 17 - "Community 17"
Cohesion: 0.16
Nodes (19): main(), miembros_de(), ordenes_ipc(), Todas las funciones que publica algún IpcHandler, por objetivo., Los ficheros y carpetas del repositorio que se citan, entre comillas., Los atajos que la guía promete tienen que estar en hypr/k4.lua., Que los ejemplos en QML de la guía compilen de verdad., Todo motivo que alguien emita tiene que tener frase en `Idioma`. Un motivo sin… (+11 more)

### Community 18 - "Community 18"
Cohesion: 0.24
Nodes (6): donde(), main(), A una posición de pantalla, corrigiendo con lo que diga Hyprland., Un arrastre de verdad, en tramos. Los tramos no son por realismo: un salto…, Dónde está el cursor según Hyprland, o None., Raton

### Community 19 - "Community 19"
Cohesion: 0.15
Nodes (19): aplicarEstado(), bonusVigor(), chocar(), conEstados(), dañoDe(), estadoQueInflige(), formaDe(), formaSinManos() (+11 more)

### Community 20 - "Community 20"
Cohesion: 0.20
Nodes (16): describir(), ficheros(), hasta_cierre(), leer(), leer_fichero(), literal(), main(), partir() (+8 more)

### Community 21 - "Community 21"
Cohesion: 0.15
Nodes (15): host_compatible(), medida_png(), nuevo(), quitar(), Un plugin que ya arranca, para no empezar por una carpeta vacía., Las banderas en inglés, pasadas a las de dentro., `>=x.y.z` contra la versión de la barra. Sin requisito, compatible., Ancho y alto de un PNG leyendo su cabecera. Nada de dependencias: son… (+7 more)

### Community 22 - "Community 22"
Cohesion: 0.33
Nodes (15): borrar(), carga(), copiar(), es_secreto(), etiqueta(), fijar(), guarda(), guardar() (+7 more)

### Community 23 - "Community 23"
Cohesion: 0.24
Nodes (15): bloques_de_texto(), envolver(), envolver_linea(), estado(), ficheros(), literales(), main(), plantilla() (+7 more)

### Community 24 - "Community 24"
Cohesion: 0.20
Nodes (15): carga_estado(), cosecha(), ficheros(), guarda_estado(), lee_claude(), lee_codex(), main(), mide() (+7 more)

### Community 25 - "Community 25"
Cohesion: 0.34
Nodes (14): Any, CompletedProcess, apply(), atomic_write(), clean_payload(), hypr_json(), lua_string(), main() (+6 more)

### Community 26 - "Community 26"
Cohesion: 0.14
Nodes (15): pip(), pip_sonoro(), prueba_pip_con_sonido_entra_en_la_mezcla(), prueba_pip_escala_y_centro(), prueba_pip_mudo_por_defecto_en_planes_viejos(), prueba_pip_no_trae_su_audio(), prueba_pip_no_trunca_el_video(), prueba_pip_se_coloca_en_su_instante() (+7 more)

### Community 27 - "Community 27"
Cohesion: 0.24
Nodes (13): bajar(), cromatismo(), elegir(), esColor(), main(), medir(), ¿Es un sprite de aparato y no otra cosa? Se descarta lo que mide más de…, Conservador a propósito: SOLO se cambia un sprite monocromo por uno en color.… (+5 more)

### Community 28 - "Community 28"
Cohesion: 0.15
Nodes (11): _carpeta_del_clon(), _commit_de(), _ir_al_commit(), En qué commit ha quedado el clon, o cadena vacía si no se sabe., Dejar el clon EXACTAMENTE en ese commit. ¿Se ha podido?, Dónde está el plugin dentro de lo clonado. Se acepta el plugin.json en la raíz…, Lo que sale de traerse un repo y mirarlo: un plugin válido, o el porqué. El…, Para una persona en una terminal, que sí quiere la frase entera. (+3 more)

### Community 29 - "Community 29"
Cohesion: 0.23
Nodes (12): anadir(), campos(), envio(), examinar(), informe(), main(), Lo que dice `plugins.py --examine` de ese commit exacto., Markdown para comentar en la incidencia, y el veredicto. (+4 more)

### Community 30 - "Community 30"
Cohesion: 0.28
Nodes (12): disco(), gpu(), lee_cpu(), lee_procesos(), lee_red(), main(), memoria(), La interfaz que más se mueve, que es la que de verdad estás usando. (+4 more)

### Community 31 - "Community 31"
Cohesion: 0.31
Nodes (4): codigo(), main(), (código, ¿hace falta shift?) para un carácter suelto., Teclado

### Community 32 - "Community 32"
Cohesion: 0.18
Nodes (12): _aBits(), codificarEquipo(), _deBits(), descodificarEquipo(), entrenoDe(), montarCaza(), pistasDeCaza(), _suma() (+4 more)

### Community 33 - "Community 33"
Cohesion: 0.18
Nodes (11): aliadoDe(), arquetipoDe(), auraDeAtributo(), bitsDe(), excesoDePeso(), golpeVistaDe(), pesoBaseDe(), poderDeEtapa() (+3 more)

### Community 34 - "Community 34"
Cohesion: 0.33
Nodes (10): id_higienizado(), leer(), main(), plan_revisado(), Toda invocación de ffmpeg/ffprobe lleva la lista blanca de protocolos., Ningún ffprobe puede quedarse esperando para siempre., El id de una capa no entra crudo en un nombre de fichero., Cargar un plan comprueba sus rutas. (+2 more)

### Community 35 - "Community 35"
Cohesion: 0.36
Nodes (10): buscar_binario(), buscar_modelos(), leer_srt(), main(), orden_comprobar(), orden_hacer(), Los modelos que haya, del más grande al más pequeño. Del más grande primero…, Los segmentos de un SRT: [{t0, t1, texto}]. Se parsea aquí y no en el QML por… (+2 more)

### Community 36 - "Community 36"
Cohesion: 0.29
Nodes (10): agendaDelDia(), _azarDe(), distanciaJefe(), estadoCarretera(), eventoDeHito(), hitosDe(), hitosEntre(), _pesoEvento() (+2 more)

### Community 37 - "Community 37"
Cohesion: 0.20
Nodes (10): plan_multipista(), prueba_capa_de_audio_con_su_pista(), prueba_capa_de_audio_no_se_lleva_la_mezcla(), prueba_capa_de_fichero_de_fuera_coge_la_primera(), prueba_pista_muda_apaga_su_capa(), Un plan con el trozo MUDO y una capa de audio, que es como queda un vídeo…, `[N:a]` a secas NO es «el audio del fichero»: ffmpeg lo resuelve a la primera…, La que sale de «separar el audio» dice de qué pista es, y es esa. (+2 more)

### Community 38 - "Community 38"
Cohesion: 0.33
Nodes (8): main(), Que todo lo que la API ofrece esté en la guía. Una API pública con tipos que no…, La regla inversa: un fichero de api/K4 no importa la barra. El módulo K4 se…, Quita los // para no delatar menciones en la documentación., revisar(), revisar_api(), revisar_documentacion(), sin_comentarios()

### Community 39 - "Community 39"
Cohesion: 0.22
Nodes (9): prueba_zona_modos(), prueba_zona_no_necesita_fichero(), prueba_zona_no_se_sale_del_fotograma(), prueba_zona_recorta_donde_toca(), prueba_zona_va_despues_del_zoom(), Como toda capa: si fuera antes, el zoom ampliaría el desenfoque., Arrastrada al borde, un crop negativo no es un aviso: tumba el render., Es la única capa que se hace con la propia imagen, sin abrir nada. (+1 more)

### Community 40 - "Community 40"
Cohesion: 0.36
Nodes (7): fuente(), main(), mapa(), Dice QUÉ DIBUJA cada glifo del Digivice, por su nombre real en la fuente.…, Los códigos que aparecen en el Digivice, con dónde salen., La misma que usa el tema: core/Theme.qml manda., usados()

### Community 41 - "Community 41"
Cohesion: 0.25
Nodes (8): capas_que_suenan(), pistas_vivas_de(), ramas_audio_extra(), Si un fichero trae flujo de audio. Hace falta preguntarlo antes de pedirle…, Las capas que aportan sonido: las de audio y los vídeos que lo pidan. Un vídeo…, De qué pistas del fichero sale el sonido de una capa, por su número dentro del…, Las capas de audio, mezcladas con el sonido del vídeo. Cada una entra con su…, suena()

### Community 42 - "Community 42"
Cohesion: 0.39
Nodes (7): autocomprobar(), main(), Que el detector detecta. Devuelve el motivo si no, o None si va bien., El fichero con comentarios y cadenas en blanco, del mismo largo. Llevan llaves…, Los sitios donde un hijo directo de un layout se coloca a mano., revisar(), sin_ruido()

### Community 43 - "Community 43"
Cohesion: 0.25
Nodes (8): actualizar(), _describir(), escribir_origen(), instalar(), Qué reglas incumple lo que hay en esa carpeta, con dónde., Clonar, validar y —con permiso— instalar un plugin de fuera. El orden importa y…, Reinstalar desde donde vino, y a la carpeta correcta. Lo de la carpeta no es un…, revisar_reglas()

### Community 44 - "Community 44"
Cohesion: 0.29
Nodes (8): enlazar_externos(), leer_catalogo(), listar(), probar(), Abre UN plugin en una instancia aparte, sin tocar la barra de verdad., El puente por el que la barra carga los de usuario: un enlace dentro del árbol…, Una carpeta nueva para una recarga en caliente. El truco de ponerle `?r1` a la…, recargar()

### Community 45 - "Community 45"
Cohesion: 0.33
Nodes (7): candidatosEvolucion(), candidatosRegresion(), _crudos(), escalonPrevio(), escalonSiguiente(), raizDe(), tieneSalida()

### Community 46 - "Community 46"
Cohesion: 0.29
Nodes (4): cuadrada(), Un tono cuadrado con sus bordes suavizados. Sin el suavizado, empezar y cortar…, Pseudoaleatorio con semilla fija: el mismo golpe cada vez., ruido()

### Community 47 - "Community 47"
Cohesion: 0.48
Nodes (6): buscar(), ficheros(), fuente(), nombres(), El fichero de la Nerd Font, preguntándoselo a fontconfig., revisar()

### Community 48 - "Community 48"
Cohesion: 0.29
Nodes (7): imagen_de_prueba(), png_de_prueba(), prueba_efecto_crecer_va_por_zoompan(), prueba_tamano_imagen(), Un PNG de verdad: `zoompan` necesita el alto en números, y eso se lee de la…, `scale` no sirve —sus expresiones no avanzan con el tiempo, medido—: el tamaño…, Un PNG mínimo de verdad, para lo que necesita leer cabeceras.

### Community 49 - "Community 49"
Cohesion: 0.29
Nodes (7): prueba_rotulo_caja(), prueba_rotulo_el_texto_va_a_un_fichero(), prueba_rotulo_sin_expansion(), prueba_rotulo_tamano_y_centro(), Nunca `text=`: lo escribe el usuario y un `:` rompería el grafo entero. No el…, `drawtext` se cree que el texto lleva formato y se come los `%`. Sin…, rotulo()

### Community 50 - "Community 50"
Cohesion: 0.43
Nodes (6): al_cortar(), main(), posicion(), preguntar(), Una consulta al compositor. Devuelve texto, o None si no contesta., El cursor, en coordenadas globales. `cursorpos` devuelve «582, 859».

### Community 51 - "Community 51"
Cohesion: 0.43
Nodes (6): fondo_por_inundacion(), limar_halo(), main(), procesar(), Máscara de fondo: lo que se alcanza desde el borde sin cambiar de color., Quita el borde antialiaseado que quedó a medio camino del fondo. El relleno se…

### Community 52 - "Community 52"
Cohesion: 0.53
Nodes (5): describir(), ejecutar(), main(), puntuar(), Lo que mejor encaja, arriba. Se mira solo el nombre del fichero, no la ruta…

### Community 53 - "Community 53"
Cohesion: 0.33
Nodes (6): ancho_texto(), citar(), rama_maquina(), Cuánto mide un rótulo en píxeles, con la MISMA fuente del render. Lo mide PIL…, El rótulo tecleándose: un drawtext por prefijo, anclado a la izquierda. Centrar…, Un valor para dentro de un filtro de ffmpeg, entre comillas simples. El parseo…

### Community 54 - "Community 54"
Cohesion: 0.33
Nodes (6): color_rgb(), expresion_redondeo(), filtros_aspecto(), Máscara redondeada —y su marco— en una sola pasada de `geq`. La cuenta es la…, Espejo, filtro de color, máscara y marco. Devuelve la lista de filtros.…, De «#rrggbb» a los tres números que quiere `geq`.

### Community 55 - "Community 55"
Cohesion: 0.47
Nodes (5): paquetes(), Biblioteca y minutos, de los .acf y localconfig.vdf de Steam., El inventario de pacman: cuántos hay y cuándo fue la última síncro., salir(), steam()

### Community 56 - "Community 56"
Cohesion: 0.40
Nodes (5): caracterDe(), caracterDeEspecie(), eligeRival(), _mezcla(), semillaDeVuelta()

### Community 58 - "Community 58"
Cohesion: 0.40
Nodes (5): main(), El registro es un PR de un desconocido: se revisa como tal. Se comprueba aquí,…, Los de casa: catálogo, name, carpeta y qmldir al día., validar_registro(), validar_repo()

### Community 59 - "Community 59"
Cohesion: 0.40
Nodes (5): con_imagen(), prueba_imagen_entra_en_bucle(), prueba_imagen_no_trae_audio(), Un plan con un trozo de vídeo y otro que es una imagen fija., Sin pistas, la rama de silencio que ya existe se encarga.

### Community 60 - "Community 60"
Cohesion: 0.60
Nodes (4): cuerpo(), main(), qmls(), El cuerpo del bloque que abre en `i`, contando llaves.

### Community 61 - "Community 61"
Cohesion: 0.67
Nodes (3): azarFijo(), medio(), reparto()

## Knowledge Gaps
- **82 isolated node(s):** `ask.sh script`, `fs`, `path`, `vm`, `raiz` (+77 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `igual()` connect `Audio Layer Tests` to `Video Editor Tests`, `Video Editor Layer Tests`, `Community 37`, `Community 39`, `Video Audio Compositing Tests`, `Community 48`, `Community 49`, `Community 26`, `Community 59`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `cargar()` connect `Video Editor I/O and Graph` to `Video Editor Core (editar.py)`, `Video Camera and Probing`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Why does `plan_multipista()` connect `Community 37` to `Video Editor Tests`, `Video Audio Compositing Tests`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `ask.sh script`, `fs`, `path` to the rest of the system?**
  _82 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Plugin System Tests` be split into smaller, more focused modules?**
  _Cohesion score 0.0658835546475996 - nodes in this community are weakly interconnected._
- **Should `Video Editor Tests` be split into smaller, more focused modules?**
  _Cohesion score 0.04628704628704629 - nodes in this community are weakly interconnected._
- **Should `Digimon Game State Tests` be split into smaller, more focused modules?**
  _Cohesion score 0.028169014084507043 - nodes in this community are weakly interconnected._