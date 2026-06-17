# sipcall

Erlang/OTP-приложение, реализующее **SIP-сервер** (на базе [NkSIP](https://github.com/NetComposer/nksip)) и **HTTP API** (на базе [Cowboy](https://github.com/ninenines/cowboy)) в одном Docker-контейнере.

## Назначение

1. SIP-клиент **Twinkle** регистрируется на сервере sipcall (REGISTER + AUTH).
2. Twinkle совершает звонок на любой номер (например, `3004`) — сервер **обрывает** входящий вызов, но **запоминает URI** абонента в ETS-таблице.
3. Внешний клиент (например, `curl`) выполняет `GET /api/call/<userid>` — sipcall совершает **исходящий звонок** на сохранённый URI этого абонента.

## Структура проекта

```
sipcall/
├── rebar.config             # зависимости и сборка
├── Dockerfile               # образ Erlang/OTP 26
├── config/
│   └── sys.config           # конфигурация приложений
├── priv/
│   └── users.json           # SIP-абоненты (3003/test)
├── src/
│   ├── sipcall.app.src      # OTP-app spec
│   ├── sipcall_app.erl      # точка входа приложения
│   ├── sipcall_sup.erl      # супервизор
│   ├── sipcall_registry.erl # ETS-хранилище URI
│   ├── sip_server.erl       # NkSIP-сервер + callbacks
│   ├── http_server.erl      # Cowboy-слушатель
│   ├── http_call_handler.erl# обработчик /api/call/<userid>
│   └── http_root_handler.erl# обработчик GET /
└── tools/
    ├── docker-build-image.sh
    └── docker-run-container.sh
```

## Сборка и запуск

```bash
# 1. Сборка Docker-образа
cd tools/
./docker-build-image.sh

# 2. Запуск контейнера (--network host — проброс всех портов)
./docker-run-container.sh
```

В логе появятся строки:

```
===> Booted cowboy
===> Booted nksip
===> Booted sipcall
NkSIP server sip_server started on {0,0,0,0}:5060 (udp/tcp)
Cowboy HTTP server started on {0,0,0,0}:8080 (GET /api/call/<userid>)
```

## Тестирование

### 1. Настройка Twinkle

Установите Twinkle с официального сайта: <http://twinkle.dolezel.info/>.

Создайте SIP-аккаунт:

| Поле              | Значение                |
|-------------------|-------------------------|
| Domain            | `localhost` (или IP хоста) |
| User              | `3003`                  |
| Password          | `test`                  |
| Transport         | UDP                     |

### 2. Звонок Twinkle → sipcall

1. В Twinkle отправьте `REGISTER`.
2. Позвоните на номер `3004` (или любой другой).
3. sipcall оборвёт вызов, в логе появится:
   ```
   sip_invite: stored URI for user 3003 -> sip:3003@192.168.x.x:5060
   ```

### 3. HTTP-вызов sipcall → Twinkle

```bash
curl http://localhost:8080/api/call/3003
```

Ожидаемый ответ:

```json
{"call_id":"...","message":"INVITE sent to Twinkle",
 "status":"ok","uri":"sip:3003@192.168.x.x:5060","userid":"3003"}
```

Twinkle примет входящий звонок от `sip_client`.

## Диагностика в Eshell

```erlang
%% Список запущенных приложений
application:which_applications().

%% Содержимое ETS-реестра URI абонентов
sipcall_registry:list().

%% Дерево супервизора
supervisor:which_children(sipcall_sup).

%% Ручной вызов абонента из Eshell
sip_server:make_call(<<"3003">>).
```

## Возможные проблемы

| Симптом | Причина | Решение |
|---------|---------|---------|
| `eaddrinuse` при старте NkSIP | порт 5060 занят | `sudo lsof -iUDP:5060` или `ss -lnp | grep 5060` |
| NkSIP несовместим с Erlang 26 | старая версия nksip v0.6.1 | использовать ветку `master` (как в rebar.config) |
| `404 not_found` от HTTP API | абонент ещё не звонил | сначала позвоните с Twinkle на 3004, чтобы сохранить URI |
| Twinkle не может зарегистрироваться | firewall блокирует UDP 5060 | `sudo ufw allow 5060/udp` |

## Лицензия

MIT.
