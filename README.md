# taxi-passenger

Постепенная миграция пассажирского приложения с Flutter на Expo / React Native / TypeScript.
Текущий этап: Expo Router, development client, авторизация пассажира по SMS и расчёт поездки.

Домашний экран запрашивает foreground-разрешение и отображает текущие координаты;
данные геолокации пока не отправляются на backend.

Экран заказа ищет адреса, получает доступные классы автомобиля, рассчитывает
маршрут и создаёт заказ только после явного нажатия «Подтвердить заказ».
Домашний экран проверяет активный заказ; отдельный экран показывает его
состояние, данные назначенного водителя и доступную сервером отмену.

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
`src/shared/config/environment.ts` проверяет URL при запуске.
Переменные `EXPO_PUBLIC_*` попадают в приложение, поэтому не должны содержать секреты.

Для этой фазы Android package — `ru.it59com.taxi.passenger.development`.
Development build устанавливается рядом с прежним `ru.it59com.taxi.passenger`,
подписанным другим ключом. Его данные сохраняются. Это идентификатор разработки;
настройка production-сборки относится к отдельной задаче.

## Авторизация пассажира

Реализованы существующие endpoint'ы passenger API:

- `POST /api/v1/passenger/auth/request-code`;
- `POST /api/v1/passenger/auth/confirm-code` — для нового телефона сервер создаёт
  passenger, поэтому это же регистрация;
- `POST /api/v1/passenger/auth/refresh` для восстановления сессии;
- `POST /api/v1/passenger/auth/logout`;
- хранение access/refresh token и профиля в `expo-secure-store`.

Поле телефона принимает `8 999 123-45-67`, `+7 999 123-45-67`, `7...` или
десятизначный номер. Перед запросом клиент приводит его к `+79991234567`.
Имя на экране кода необязательно и передаётся серверу только для нового аккаунта.
Реальный код не логируется и не хранится в приложении.

Проверено 16.09.2026: backend отдаёт действующие документы `Согласие на
обработку персональных данных` и `Лицензионное Соглашение`, обе версии `2.0`.
Passenger SMS-контракт пока не принимает версии согласий и не создаёт audit event;
для серверной фиксации принятия потребуется отдельное изменение backend API.

## OpenAPI-контракт

`src/api/generated/openapi.ts` генерируется из актуального server Swagger:

```powershell
npm run generate:api
```

Сервер пока публикует Swagger 2.0, поэтому `scripts/generate-openapi.mjs`
сначала конвертирует его в OpenAPI 3. Сгенерированный файл хранится в Git и
является источником типов transport-слоя; ручные DTO для API не создаются.

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
  index.tsx         # восстановление маршрута по сессии
  (auth)/phone.tsx  # номер и запрос SMS-кода
  (auth)/code.tsx   # подтверждение кода / регистрация
  (main)/home.tsx   # экран активной сессии
src/
  shared/config/environment.ts
  features/auth/    # API, SecureStore и состояние сессии
legacy/flutter/    # исходная Flutter implementation
docs/MOBILE_GIS_CONTRACT.md
.env.example
app.json
package.json
package-lock.json
tsconfig.json
swagger-doc.json   # существующий контракт backend
```

Feature-папки и TanStack Query добавляются при реализации соответствующих фаз.
Пустые разделы заранее не создаются.

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

1. Экран состояния заказа и отмена.
2. WebSocket, reconnect и REST-синхронизация.
3. История, рейтинг, профиль, чаты.
4. Push, lifecycle и доступность backend.

Переход к следующей фазе — после подтверждения первой.
