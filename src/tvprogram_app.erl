-module(tvprogram_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile(
                 [{'_', [{"/program", toppage_handler, []}]}]),
	{ok, _} = cowboy:start_http(
                http, 100,
                [{port, 9090}],
                [{env, [{dispatch, Dispatch}]}]),
    tvprogram_sup:start_link().

stop(_State) ->
    ok.
