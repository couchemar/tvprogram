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
                                    mongo:find(afisha,
                                               {},
                                               {'_id', false,
                                                start_time, false,
                                                end_time, false,
                                                channel_id, false})
                            end),
    {Result} = mongo:next(Cursor),
    io:format("Res: ~p~n", [Result]),
    JResult = bson:fields(Result),
    io:format("Json: ~p~n", [JResult]),
    Json = jsx:encode(JResult),
    {Json, Req, State}.
