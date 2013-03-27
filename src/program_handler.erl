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
    Req1 = add_cors_headers(Req),
    {ok, Req1, State}.

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
            {true, Req2, erlang:binary_to_integer(ChannelID)}
        end.

% =================
% Callback Callbacs
% =================

program(Req, ChannelID) ->
    Req1 = add_cors_headers(Req),

    Host = {localhost, 27017},
    {ok, Conn} = mongo:connect(Host),
    Date = os:timestamp(),
    {ok, Cursor} = mongo:do(
                     safe, master, Conn, tv,
                     fun() -> find(Date, ChannelID) end
                    ),
    Result = process(Cursor),
    Json = jsx:encode([{<<"programs">>, Result}]),
    {Json, Req1, ChannelID}.


% =======
% PRIVATE
% =======

add_cors_headers(Req) ->
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, Req),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
    Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>,
                                      <<"content-type, accept, x-requested-with, origin">>, Req2),
    cowboy_req:set_resp_header(<<"access-control-max-age">>, <<"600">>, Req3).

process(Cursor) ->
    process(Cursor, []).

process(Cursor, Acc) ->
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
            process(Cursor, [JResult|Acc])
    end.

find(Date, ChannelID) ->
    Query = {end_date, {'$gt', Date}, channel_id, ChannelID},
    mongo:find(afisha,
               {'$query', Query,
                '$orderby', {end_date, -1}},
               {'_id', false}).
