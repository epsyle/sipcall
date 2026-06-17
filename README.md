# sipcall

Erlang/OTP приложение: SIP-сервер (NkSIP) + HTTP REST API (Cowboy) в одном Docker-контейнере.

## Структура проекта

-----
sipcall/
├── config
│   └── sys.config
├── Dockerfile
├── LICENSE.md
├── priv
│   └── users.json
├── README.md
├── rebar.config
└── src
    ├── http_call_handler.erl
    ├── sipcall_app.erl
    ├── sipcall.app.src
    ├── sipcall_sup.erl
    └── sip_server.erl


```erl

## Сборка и запуск
docker build -t sipcall .
docker run --network host -e TZ=Asia/Novosibirsk -it --rm sipcall

## Тестирование
Настраиваем Twinkle: domain=192.168.0.140, user=3003, password=test, UDP
Регистрируем Twinkle
Звоним на 3004 — sipcall обрывает вызов, сохраняет URI
Выполняем url http://localhost:8080/api/call/3003 — sipcall перезванивает
Twinkle звонит
