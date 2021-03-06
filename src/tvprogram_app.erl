-module(tvprogram_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% API
-export([dispatch_routes/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch = dispatch_routes(),
	{ok, _} = cowboy:start_http(
                http, 100,
                [{port, 9090}],
                [{env, [{dispatch, Dispatch}]}]),
    tvprogram_sup:start_link().

stop(_State) ->
    ok.

%% ===
%% API
%% ===

dispatch_routes() ->
    cowboy_router:compile(
                 [
                  {'_', [
                         {"/channel/", channel_handler, []},
                         {"/channel/[:channel_id]/program/", program_handler, []}
                        ]
                  }
                 ]).
