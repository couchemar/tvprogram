-module(date_utils).

-export([datetime_to_timestamp/1]).

datetime_to_timestamp(DateTime) ->
    Seconds = calendar:datetime_to_gregorian_seconds(DateTime) - 62167219200,
    {Seconds div 1000000, Seconds rem 1000000, 0}.
