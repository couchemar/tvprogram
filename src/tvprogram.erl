-module(tvprogram).

-export([start/0,
         reload_routes/0]).

start() ->
    ok = sync:go(),
    ok = application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowboy),
    ok = application:start(mongodb),
	ok = application:start(tvprogram).

reload_routes() ->
    cowboy:set_env(http, dispatch,
                   tvprogram_app:dispatch_routes()).
