-module(date_utils).

-export([format/1]).

format(UnixTime) ->
    Date = ec_date:format("Y-m-dTG:i:s", UnixTime),
    Date ++ "Z".
