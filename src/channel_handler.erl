-module(channel_handler).

% REST Callbacks
-export([init/3,
         allowed_methods/2,
         options/2,
         content_types_provided/2]).

% Callback Callbacs
-export([channels/2]).

% REST Callbacks.

init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"OPTIONS">>], Req, State}.

options(Req, State) ->
    {ok, rest_utils:add_cors_headers(Req), State}.

content_types_provided(Req, State) ->
    {
      [
       {{<<"application">>, <<"json">>, []}, channels}
      ],
      Req, State
    }.

% =================
% Callbac Callbacks
% =================

channels(Req, State) ->
    Host = {localhost, 27017},
    {ok, Conn} = mongo:connect(Host),
    {ok, Cursor} = mongo:do(safe, master, Conn, tv,
                            fun() -> mongo:find(channels, {}, {}) end),
    Result = process(Cursor),
    Json = jsx:encode([{<<"channels">>, Result}]),
    {Json, rest_utils:add_cors_headers(Req), State}.

%% =======
%% Private
%% =======

process(Cursor) ->
    process(Cursor, []).

process(Cursor, Acc) ->
    case mongo:next(Cursor) of
        {} ->
            Acc;
        {Result} ->
            JResult = bson:fields(Result),
            process(Cursor, [JResult|Acc])
    end.
