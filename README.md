# taxi-passenger

Постепенная миграция пассажирского приложения с Flutter на Expo / React Native / TypeScript.
Текущий этап: минимальный запускаемый каркас с Expo Router и development client.
Единственный экран содержит `Taxi Passenger` и `Expo migration is running`.
Функциональность пассажира пока не перенесена.

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
Copy-Item .env.example .env
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
$env:REACT_NATIVE_PACKAGER_HOSTNAME = '127.0.0.1'
npm start -- --lan
```

Откройте development build на телефоне. При необходимости укажите в нём
`http://127.0.0.1:8081`. Этот адрес относится только к Metro через USB.
Backend находится отдельно: `http://192.168.0.50:8080`.
На этом Windows-хосте `--localhost` привязывал Metro только к IPv6 `::1`,
а ADB требовал IPv4. Поэтому для USB используется `--lan` с явно заданным
адресом `127.0.0.1` в manifest.
В `.env` задан `EXPO_PUBLIC_API_URL=http://192.168.0.50:8080`.
`src/shared/config/environment.ts` проверяет URL при запуске; сетевых вызовов нет.
Переменные `EXPO_PUBLIC_*` попадают в приложение, поэтому не должны содержать секреты.

Для этой фазы Android package — `ru.it59com.taxi.passenger.development`.
Development build устанавливается рядом с прежним `ru.it59com.taxi.passenger`,
подписанным другим ключом. Его данные сохраняются. Это идентификатор разработки;
настройка production-сборки относится к отдельной задаче.

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

Результат повторной проверки development build на Android 9 описан ниже.

## Структура

```text
app/
  _layout.tsx       # корневой Stack Expo Router
  index.tsx         # минимальный стартовый экран
src/
  shared/config/environment.ts
legacy/flutter/    # исходная Flutter implementation
docs/MOBILE_GIS_CONTRACT.md
.env.example
app.json
package.json
package-lock.json
tsconfig.json
swagger-doc.json   # существующий контракт backend
```

Feature-папки, TanStack Query и SecureStore добавляются при реализации
соответствующих фаз. Пустые разделы заранее не создаются.

## Flutter reference и API

Flutter-файлы были удалены перед инициализацией Expo. Для постепенной миграции
исходники восстановлены без изменений в `legacy/flutter/` из коммита
`84cff041a88ff427fb98d8a4630a9d03c2ae985f`: `lib`, тесты, платформенные проекты,
pubspec и настройки Flutter. Корневые IDE-файлы не копировались; README и Swagger
сохранены в корне. Flutter остаётся reference implementation:

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

1. API, secure storage, authentication, refresh, профиль.
2. Геолокация, поиск адреса, классы авто, расчёт маршрута.
3. Создание и состояние заказа.
4. WebSocket, reconnect и REST-синхронизация.
5. История, рейтинг, профиль, чаты.
6. Push, lifecycle и доступность backend.

Переход к следующей фазе — после подтверждения первой.
