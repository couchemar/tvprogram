-module(date_utils).

-export([format/1,
         datetime_to_timestamp/1]).

format(UnixTime) ->
    Date = ec_date:format("Y-m-d\\TH:i:s", UnixTime),
    Date ++ "Z".

datetime_to_timestamp(DateTime) ->
    Seconds = calendar:datetime_to_gregorian_seconds(DateTime) - 62167219200,
    {Seconds div 1000000, Seconds rem 1000000, 0}.
