-module(test_cdump).
-export([test/0,test2/0]).
%timer:tc(test_cdump, test, []).
%{6353978,success}


test() ->
    ID = kv3,
    Size = 100,
    concurrent_dump_sup:start_link(4, Size, ID),
    V1 = <<0:(8*Size)>>,
    V2 = <<2:(8*Size)>>,
    V3 = <<3:(8*Size)>>,
    A1 = cdump:put(V1, ID),
    V1 = cdump:get(A1, ID),
    A2 = cdump:put(V2, ID),
    V1 = cdump:get(A1, ID),
    V2 = cdump:get(A2, ID),
    A3 = cdump:put(V3, ID),
    V1 = cdump:get(A1, ID),
    V2 = cdump:get(A2, ID),
    V3 = cdump:get(A3, ID),
    cdump:delete(A2, ID),
    A2 = cdump:put(V1, ID),
    Times = 100000,
    test_times(Times, Size, ID).
test_times(0, _, _) -> success;
test_times(N, Size, ID) -> 
    cdump:put(<<0:(8*Size)>>, ID),
    test_times(N-1, Size, ID).


test2() ->
    cprof:start(),
    test(),
    cprof:pause(),
    cprof:analyse(cdump).
