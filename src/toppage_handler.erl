-module(toppage_handler).

-export([init/3]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).

-export([program/2]).

init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.


allowed_methods(Req, State) ->
	{[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, []}, program}
     ], Req, State}.

program(Req, State) ->
    Host = {localhost, 27017},
    {ok, Conn} = mongo:connect(Host),
    {ok, Cursor} = mongo:do(safe, master, Conn, tv,
                            fun() ->
                                    mongo:find(afisha, {})
                            end),
    {Result} = mongo:next(Cursor),
    {<<"test">>, Req, State}.
