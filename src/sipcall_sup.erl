%%%-------------------------------------------------------------------
%%% @doc Главный супервизор sipcall.
%%%-------------------------------------------------------------------
-module(sipcall_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy => one_for_one,
        intensity => 10,
        period => 60
    },

    ChildSpecs = [
        %% SIP-сервер на порту 5060
        nksip:get_sup_spec(sip_server, #{
            sip_local_host => "localhost",
            plugins => [nksip_registrar],
            sip_listen => "sip:all:5060"
        })
    ],

    {ok, {SupFlags, ChildSpecs}}.
