%%%-------------------------------------------------------------------
%%% @doc Cowboy 2.x handler для GET /api/call/<userid>.
%%%-------------------------------------------------------------------
-module(http_call_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req, State) ->
    UserId = cowboy_req:binding(userid, Req),
    lager:info("HTTP GET /api/call/~s", [UserId]),

    case sip_server:make_call(UserId) of
        {ok, _, _} ->
            %% nksip_uac:invite/3 возвращает {ok, Code, Meta}
            Body = jsx:encode(#{
                status => <<"ok">>,
                userid => UserId,
                message => <<"INVITE sent to Twinkle">>
            }),
            Req2 = reply_json(200, Body, Req);
        {ok, _Result} ->
            %% На случай, если возвращается 2-tuple
            Body = jsx:encode(#{
                status => <<"ok">>,
                userid => UserId,
                message => <<"INVITE sent to Twinkle">>
            }),
            Req2 = reply_json(200, Body, Req);
        {error, Reason} ->
            Body = jsx:encode(#{
                status => <<"error">>,
                userid => UserId,
                reason => atom_to_binary(Reason, utf8)
            }),
            Req2 = reply_json(404, Body, Req)
    end,

    {ok, Req2, State}.

reply_json(Code, Body, Req) ->
    cowboy_req:reply(Code,
        #{<<"content-type">> => <<"application/json; charset=utf-8">>},
        Body, Req).
