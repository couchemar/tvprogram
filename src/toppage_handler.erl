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
    Date = os:timestamp(),
    {ok, Cursor} = mongo:do(
                     safe, master, Conn, tv,
                     fun() ->
                             mongo:find(afisha,
                                     %   {'$or', [{start_date, {'$lte', Date}},
                                     %             {end_date, {'$gt', Date}}]},
                                        {start_date, {'$gte', Date}},
                                        %{end_date, {'$gt', Date}},
                                        {'_id', false,
                                         channel_id, false})
                     end),
    Result = process(Cursor),
    io:format("Result: ~p~n", [Result]),
    JResult = bson:fields(Result),
    io:format("Json: ~p~n", [JResult]),
    Json = jsx:encode(JResult),
    {Json, Req, State}.

process(Cursor) ->
    process(Cursor, []).
process(Cursor, Acc) ->
    io:format("Acc: ~p~n", [Acc]),
    case mongo:next(Cursor) of
        {} -> Acc;
        {Result} ->
            io:format("Res: ~p~n", [Result]),
            {SUT} = bson:lookup(start_date, Result),
            STS = date_utils:format(SUT),
            {EUT} = bson:lookup(end_date, Result),
            ETS = date_utils:format(EUT),
            Replaced1 = bson:update(start_date, list_to_binary(STS), Result),
            Replaced2 = bson:update(end_date, list_to_binary(ETS), Replaced1),
            process(Cursor, [Replaced2|Acc])
    end.
