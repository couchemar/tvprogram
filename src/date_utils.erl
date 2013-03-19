-module(date_utils).

-export([format/1]).

format(UnixTime) ->
    ec_date:format("Y-m-dTG:i:s", UnixTime).
