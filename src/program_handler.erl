-module(program_handler).

% REST Callbacs
-export([init/3,
         allowed_methods/2,
         options/2,
         content_types_provided/2,
         resource_exists/2]).

% Callback Callbacs
-export([program/2]).

init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
	{[<<"GET">>, <<"OPTIONS">>], Req, State}.

options(Req, State) ->
    {ok, rest_utils:add_cors_headers(Req), State}.

content_types_provided(Req, State) ->
    {
      [
       {{<<"application">>, <<"json">>, []}, program}
      ],
      Req, State
    }.

resource_exists(Req, State) ->
    case cowboy_req:binding(channel_id, Req) of
        {undefined, Req2} ->
            {false, Req2, State};
        {ChannelID, Req2} ->
            {true, Req2, ChannelID}
        end.

% ==================
% Callback Callbacks
% ==================

program(Req, ChannelID) ->
    {Limit, Req1} = cowboy_req:qs_val(<<"limit">>, Req),
    {StartDate, Req2} = cowboy_req:qs_val(<<"startDate">>, Req1),
    Date = date_utils:datetime_to_timestamp(iso8601:parse(StartDate)),

    Host = {localhost, 27017},
    {ok, Conn} = mongo:connect(Host),
    {ok, Cursor} = mongo:do(
                     safe, master, Conn, tv,
                     fun() -> prepare_find(Date, ChannelID) end
                    ),
    Result = process(Cursor, Limit),
    Json = jsx:encode([{<<"programs">>, Result}]),
    {Json, rest_utils:add_cors_headers(Req2), ChannelID}.

% =======
% PRIVATE
% =======

process(Cursor, Limit) ->
    process(Cursor, [], Limit).

process(Cursor, Acc, undefined) ->
    process_cursor(Cursor, Acc, undefined);
process(Cursor, Acc, Limit) when is_binary(Limit)->
    process(Cursor, Acc, erlang:binary_to_integer(Limit));
process(_Cursor, Acc, 0) ->
    Acc;
process(Cursor, Acc, Limit) ->
    process_cursor(Cursor, Acc, Limit - 1).

process_cursor(Cursor, Acc, Limit) ->
    case mongo:next(Cursor) of
        {} -> Acc;
        {Result} ->
            {SUT} = bson:lookup(start_date, Result),
            STS = date_utils:format(SUT),
            {EUT} = bson:lookup(end_date, Result),
            ETS = date_utils:format(EUT),
            Replaced1 = bson:update(start_date, list_to_binary(STS), Result),
            Replaced2 = bson:update(end_date, list_to_binary(ETS), Replaced1),
            JResult = bson:fields(Replaced2),
            process(Cursor, [JResult|Acc], Limit)
    end.

prepare_find(Date, ChannelID) ->
    Query = {end_date, {'$gt', Date}, channel_id, ChannelID},
    find(Query).

find(Query) ->
    mongo:find(afisha,
               {'$query', Query,
                '$orderby', {end_date, 1}},
               {'_id', false}).
