# Cartas para dos

App de juegos de cartas para parejas: clásicos (UNO, Chinchón, Escoba del 15,
Truco) + juegos de conexión (En Palabras, Conectados, Climax Club).

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.22+
- Android Studio (o solo el Android SDK vía command-line tools) para compilar el APK
- Un dispositivo/emulador Android, o `flutter run -d chrome` para probar en el navegador mientras desarrollás

## Correr en desarrollo

```bash
flutter pub get
flutter run
```

## Generar el .apk

```bash
flutter build apk --release
# el archivo queda en build/app/outputs/flutter-apk/app-release.apk
```

Si no querés instalar Android Studio localmente, podés compilar en la nube con
[Codemagic](https://codemagic.io) o [EAS Build](https://docs.expo.dev/build/introduction/)
(este último es de Expo/React Native, no aplica si te quedás con Flutter — para
Flutter, Codemagic tiene un free tier y es la opción más directa).

## Estado actual

| Juego | Estado |
|---|---|
| UNO | ✅ Jugable (pasar y jugar, 2 jugadores) |
| En Palabras | ✅ Jugable (contrarreloj) |
| Chinchón | 🚧 Módulo registrado, falta motor de reglas |
| Escoba del 15 | 🚧 Módulo registrado, falta motor de reglas |
| Truco | 🚧 Módulo registrado, falta motor de reglas (el más complejo) |
| Conectados | 🚧 Módulo registrado, falta contenido y pantalla |
| Climax Club | 🚧 Módulo registrado, falta contenido y pantalla |

## Cómo agregar un juego nuevo

1. Creá una carpeta en `lib/games/classic/` o `lib/games/couples/`.
2. Si el juego tiene reglas de mesa, separá la lógica pura (sin Flutter) en un
   `*_engine.dart`, como `uno_engine.dart`. Esto te permite testearlo sin UI.
3. Si el juego usa mazos de contenido (preguntas, frases), poné los datos en
   un JSON dentro de `assets/data/` y cargalo con un `*_deck.dart`, como
   `en_palabras_deck.dart`. Así podés editar/agregar cartas sin tocar Dart.
4. Armá la pantalla (`*_screen.dart`) que consume el engine o el deck.
5. Creá el `*_module.dart` implementando `GameModule` (ver `core/game_module.dart`).
6. Agregalo a la lista en `core/game_registry.dart`. Listo, ya aparece en el catálogo.

Ver `ARCHITECTURE.md` para las decisiones de fondo (por qué Flutter, manejo de
estado, contenido adulto, roadmap de multijugador online, etc).
