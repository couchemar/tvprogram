-module(rest_utils).

-export([add_cors_headers/1]).


add_cors_headers(Req) ->
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, Req),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
    Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>,
                                      <<"content-type, accept, x-requested-with, origin">>, Req2),
    cowboy_req:set_resp_header(<<"access-control-max-age">>, <<"600">>, Req3).
