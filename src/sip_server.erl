%%%-------------------------------------------------------------------
%%% @doc SIP-сервер: callback-модуль для NkSIP v0.6.1.
%%%-------------------------------------------------------------------
-module(sip_server).

-include_lib("nksip/include/nksip.hrl").
-include_lib("nkserver/include/nkserver_module.hrl").

%% nksip callbacks
-export([
    sip_get_user_pass/4,
    sip_authorize/3,
    sip_route/5,
    sip_register/2,
    sip_invite/2
]).

%% API
-export([make_call/1]).

-define(SRV, sip_server).

%%====================================================================
%% API
%%====================================================================

-spec make_call(binary() | string()) -> {ok, term()} | {error, term()}.
make_call(UserId) when is_list(UserId) ->
    make_call(unicode:characters_to_binary(UserId));
make_call(UserId) when is_binary(UserId) ->
    case ets:lookup(users_table, UserId) of
        [{UserId, Uri}] ->
            UriBin = nklib_util:to_binary(Uri),
            lager:info("Making outbound INVITE to ~s (uri=~s)", [UserId, UriBin]),
            %% Пустой INVITE без SDP — Twinkle примет и начнёт звонить
            nksip_uac:invite(?SRV, UriBin, []);
        [] ->
            lager:warning("Cannot call ~s: URI not registered", [UserId]),
            {error, not_registered}
    end.

%%====================================================================
%% nksip callbacks
%%====================================================================

sip_get_user_pass(_User, _Realm, _Req, _Call) ->
    <<>>.

sip_authorize(AuthList, _Req, _Call) ->
    case lists:member(dialog, AuthList) orelse lists:member(register, AuthList) of
        true -> ok;
        false -> ok
    end.

sip_route(_Scheme, _User, _Domain, _Req, _Call) ->
    process.

sip_register(Req, _Call) ->
    lager:info("sip_register: REGISTER received"),
    {reply, nksip_registrar:request(Req)}.

sip_invite(Req, _Call) ->
    {ok, [{from_user, FromUser}]} = nksip_request:get_metas([from_user], Req),
    Contacts = nksip_sipmsg:get_meta(contacts, Req),
    lager:info("sip_invite: from_user=~s", [FromUser]),

    case Contacts of
        [Uri | _] ->
            ets:insert(users_table, {FromUser, Uri}),
            lager:info("sip_invite: stored URI for user ~s", [FromUser]),
            {reply, {487, []}};
        [] ->
            {reply, forbidden}
    end.
