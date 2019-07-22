-module(girl).
-export([hash_object/1]).


-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

% printf '' | sha1sum | awk '{print $1}'
sha_hexdigest_test() ->
    ?assertEqual("da39a3ee5e6b4b0d3255bfef95601890afd80709", sha_hexdigest("")).

% test $(printf '' | git hash-object --stdin) = $(printf 'blob 0\0' | sha1sum | awk '{print $1}'); echo $?
% test $(printf 'foo\n' | git hash-object --stdin) = $(printf 'blob 4\0foo\n' | sha1sum | awk '{print $1}'); echo $?
hash_object_test() ->
    ?assertEqual("e69de29bb2d1d6434b8b29ae775ad8c2e48c5391", hash_object({blob, <<"">>})),
    ?assertEqual("257cc5642cb1a054f08cc83f2d943e56fd3ebe99", hash_object({blob, <<"foo\n">>})).
-endif.


%% Use Nibble as offset to decimal values of 0 and W in the ASCII character set
%% for producing characters of [0-9a-f].
%% See `man ascii` for a nice table.
sha_hexdigest(Data) ->
    [if Nibble < 10 -> 48 + Nibble;
        Nibble >  9 -> 87 + Nibble
     end || <<Nibble:4>> <= crypto:hash(sha, Data)].

%% git hash-object
hash_object({blob, Data}) ->
    %% TODO: This seems kinda ridiculous, maybe there's a better way to stringify the size.
    BitstringifiedSize = list_to_binary(integer_to_list(byte_size(Data))),
    %% Blob information in the form of e.g. 'blob 4\0foo\n'.
    Blobinfo = << <<"blob">>/bytes, <<" ">>/bytes, BitstringifiedSize/bytes, <<0>>/bytes, Data/bits >>,
    sha_hexdigest(Blobinfo).
