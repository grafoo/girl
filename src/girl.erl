-module(girl).
-export([]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
sha_hexdigest_test() ->
    ?assertEqual("da39a3ee5e6b4b0d3255bfef95601890afd80709", sha_hexdigest("")).
-endif.

%% Use Nibble as offset to decimal values of 0 and W in the ASCII character set
%% for producing characters of [0-9a-f].
%% See `man ascii` for a nice table.
sha_hexdigest(Data) ->
    [if Nibble < 10 -> 48 + Nibble;
        Nibble >  9 -> 87 + Nibble
     end || <<Nibble:4>> <= crypto:hash(sha, Data)].
