# GoDare

App social de **retos de fitness** hecha en Flutter. Recibes retos, los completas grabándote en vídeo, la comunidad vota si son válidos y vas subiendo de rango.

Proyecto del CFGS **Desarrollo de Aplicaciones Multiplataforma (DAM)** · Nota: **9,4 / 10**

Backend (Spring Boot): [kreatimes/godare-backend](https://github.com/kreatimes/godare-backend)

## Funcionalidades

- **Cuenta:** registro, login, recuperación y cambio de contraseña, edición de perfil
- **Retos:** reto diario, mis retos, abrir y completar retos subiendo un vídeo o una imagen, transferir retos a otros usuarios
- **Tienda:** packs de retos que se compran con las monedas ganadas
- **Feed:** global y de seguidos con scroll infinito, reacciones (doble toque con animación de corazón), comentarios, reportes y compartir
- **Social:** seguidores y seguidos, búsqueda de usuarios, perfiles públicos y notificaciones
- **Ranking:** global y entre amigos, con insignias de rango
- Reproductor de vídeo, zoom de imágenes e interfaz adaptable a distintos tamaños de pantalla

## Stack

| Área | Tecnología |
|---|---|
| Framework | Flutter (Dart 3) |
| Estado | Provider |
| HTTP | Dio con interceptores (inyecta el JWT en cada petición) |
| Seguridad | flutter_secure_storage para guardar el token |
| Multimedia | video_player, image_picker, photo_view, Cloudinary |
| Otros | intl (i18n), share_plus, url_launcher, flutter_dotenv |

## Estructura

```
lib/
├── core/        Cliente HTTP, constantes, almacenamiento seguro
├── models/      Modelos de datos (usuario, post, reto, pack…)
├── services/    Llamadas a la API por dominio
├── providers/   Estado global (usuario)
├── pages/       Pantallas y fragments con pestañas
├── widgets/     Componentes reutilizables (tarjetas, menú, formularios)
├── common/      Rutas de navegación
└── l10n/        Textos traducibles
```

## Ejecutar en local

Requisitos: Flutter SDK 3.3 o superior.

1. Crea `assets/.env` (no se sube al repositorio) con:

```
CLOUDINARY_CLOUD_NAME=tu_cloud_name
CLOUDINARY_UPLOAD_PRESET=tu_upload_preset
```

2. Por defecto la app apunta al backend de producción. Para usar uno local, cambia `apiBaseUrl` en `lib/core/constants.dart` (ahí están las URLs para el emulador de Android, el simulador de iOS y un dispositivo físico).
3. Arranca:

```bash
flutter pub get
flutter run
```

## Autor

**Felipe López Escarpa** · Cofundador de Dev-licius · [Apps en Google Play](https://play.google.com/store/search?q=devlicius&c=apps)
