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
                                                channel_id, false})
                            end),
    {Result} = mongo:next(Cursor),
    io:format("Res: ~p~n", [Result]),

    {SUT} = bson:lookup(start_date, Result),

    STS = date_utils:format(SUT),

    {EUT} = bson:lookup(end_date, Result),

    ETS = date_utils:format(EUT),

    Replaced1 = bson:update(start_date, list_to_binary(STS), Result),
    Replaced2 = bson:update(end_date, list_to_binary(ETS), Replaced1),

    JResult = bson:fields(Replaced2),
    io:format("Json: ~p~n", [JResult]),
    Json = jsx:encode(JResult),
    {Json, Req, State}.
