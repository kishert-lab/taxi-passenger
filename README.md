# taxi-passenger

Постепенная миграция пассажирского приложения с Flutter на Expo / React Native / TypeScript.
Текущий этап: минимальный запускаемый каркас с Expo Router и development client.
Единственный экран содержит название приложения. Функциональность пассажира пока не перенесена.

## Требования

- Node.js >= 22.13 (проверено с 22.19.0), npm.
- Для локального Android development build: JDK, Android SDK 36, NDK 27.1.12297006, настроенный
  `ANDROID_HOME`, USB debugging и устройство в выводе `adb devices`.
- Основная цель — физический телефон Android 9.

Версии Expo SDK 57 / React Native 0.86 / React 19.2 согласованы с
[таблицей совместимости Expo](https://docs.expo.dev/versions/latest/).
Router подключён по [инструкции Expo](https://docs.expo.dev/router/installation/).
`react-dom`, Reanimated и Worklets закреплены в совместимых с SDK версиях:
Router подтягивает их как peer dependencies; автоматический выбор npm приводил
к несовместимым версиям React DOM и Worklets.

## Запуск на Android (PowerShell)

```powershell
npm ci
# Укажите собственный путь к Android SDK, если ANDROID_HOME ещё не настроен:
$env:ANDROID_HOME = 'C:\develop\sdk'
adb devices
npm run android
```

`npm run android` генерирует native-проект, собирает и устанавливает development
build на выбранное устройство, затем запускает Metro. Первая сборка требует
интернета для Gradle и Android-зависимостей. Каталоги `android/` и `ios/`
генерируются Expo и не хранятся в Git.

Для повторного запуска с уже установленным development build:

```powershell
adb reverse tcp:8081 tcp:8081
npm start -- --localhost
```

Откройте development build на телефоне. При необходимости укажите в нём
`http://127.0.0.1:8081`. Этот адрес относится только к Metro через USB.
Backend находится отдельно: `http://192.168.0.50:8080`.
Подключение API и `EXPO_PUBLIC_API_URL` относятся к следующей фазе.

Временно каркас также можно открыть через совместимый Expo Go:

```powershell
npm run start:go
```

## Проверки

```powershell
npm run typecheck
npm run check:dependencies
npx expo-doctor
npm run export:android
```

Экспорт проверяет сборку JavaScript для Android; проверка native-сборки и запуска
на телефоне выполняется отдельно через `npm run android`.

Проверено при инициализации: TypeScript без ошибок, совместимость зависимостей,
Expo Doctor (21/21), Android export, запуск Metro и выдача development bundle
с HTTP 200. `npm audit` сообщает о 13 moderate предупреждениях в цепочке
зависимостей Expo; high/critical отсутствуют. Автоматический `audit fix --force`
не применялся, поскольку предлагает несовместимую смену Expo SDK.

Native Android debug APK также собран успешно (`BUILD SUCCESSFUL`, arm64-v8a).
Установка на подключённый Android 9 остановилась с
`INSTALL_FAILED_UPDATE_INCOMPATIBLE`: уже установленное приложение
`ru.it59com.taxi.passenger` подписано другим ключом. Приложение и его данные
не удалялись; отображение экрана на устройстве пока не подтверждено.

## Структура

```text
app/
  _layout.tsx       # корневой Stack Expo Router
  index.tsx         # минимальный стартовый экран
src/
  api/             # будущие API-клиент и DTO
  entities/        # модели
  features/        # функциональность по областям
  services/        # mobile/platform services
  shared/          # общие элементы
app.json
package.json
package-lock.json
tsconfig.json
swagger-doc.json   # существующий контракт backend
```

Пустые разделы `src/` сохранены через `.gitkeep`. Конкретные feature-папки,
TanStack Query и SecureStore добавляются при реализации соответствующих фаз.

## Flutter reference и API

Flutter-файлы удалены из рабочей копии пользователем перед инициализацией Expo.
Reference доступен в Git, коммит `84cff041a88ff427fb98d8a4630a9d03c2ae985f`:

```powershell
git show 84cff041a88ff427fb98d8a4630a9d03c2ae985f:lib/core/constants/api_endpoints.dart
git show 84cff041a88ff427fb98d8a4630a9d03c2ae985f:lib/data/api/api_client.dart
```

Изучены маршруты Flutter, HTTP-клиент с refresh, auth/profile API и подписки
WebSocket. Актуальный контракт работающего backend:
[Swagger UI](http://192.168.0.50:8080/swagger/index.html),
[Swagger JSON](http://192.168.0.50:8080/swagger/doc.json).

Проверено 16.09.2026: серверный Swagger имеет `basePath: /api/v1` и содержит
`/passenger/me`, `/passenger/push/token`, passenger auth и `/ws`, что подтверждает
пути из Flutter. Также присутствуют `/passenger/profile` и `/passenger/push-tokens`.
Локальный `swagger-doc.json` отличается от серверного контракта и не должен
использоваться для генерации клиента без обновления в фазе API.

## Следующие этапы

1. Config, API, secure storage, authentication, refresh, профиль.
2. Геолокация, поиск адреса, классы авто, расчёт маршрута.
3. Создание и состояние заказа.
4. WebSocket, reconnect и REST-синхронизация.
5. История, рейтинг, профиль, чаты.
6. Push, lifecycle и доступность backend.

Переход к следующей фазе — после подтверждения первой.
