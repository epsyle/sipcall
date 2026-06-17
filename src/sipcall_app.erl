%%%-------------------------------------------------------------------
%%% @doc Точка входа приложения sipcall.
%%%-------------------------------------------------------------------
-module(sipcall_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    %% Создаём ETS-таблицу для URI абонентов
    ets:new(users_table, [set, named_table, public]),
    lager:info("ETS table users_table created"),

    %% Запускаем Cowboy HTTP-сервер на порту 8080
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/api/call/:userid", http_call_handler, []}
        ]}
    ]),

    {ok, _} = cowboy:start_clear(
        sipcall_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    lager:info("Cowboy HTTP server started on port 8080"),

    sipcall_sup:start_link().

stop(_State) ->
    ets:delete(users_table),
    cowboy:stop_listener(sipcall_http_listener),
    ok.
