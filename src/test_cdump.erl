-module(test_cdump).
-export([test/1,test1/1,test2/1,test3/1]).
%timer:tc(test_cdump, test, []).
%{6353978,success}
test(Threads) ->
    ID = kv3,
    Size = 100,
    IDS = cdump:make_ids(ID, Threads),
    concurrent_dump_sup:start_link(Threads, Size, ID),
    V1 = <<0:(8*Size)>>,
    V2 = <<2:(8*Size)>>,
    V3 = <<3:(8*Size)>>,
    [{V1, A1}] = cdump:put([V1], ID, IDS),
    V1 = cdump:get(A1, IDS),
    [{V2, A2}] = cdump:put([V2], ID, IDS),
    V1 = cdump:get(A1, IDS),
    V2 = cdump:get(A2, IDS),
    [{V3, A3}] = cdump:put([V3], ID, IDS),
    V1 = cdump:get(A1, IDS),
    V2 = cdump:get(A2, IDS),
    V3 = cdump:get(A3, IDS),
    cdump:delete(A2, IDS),
    %A2 = cdump:put(V1, ID, IDS),
    cdump:put([V1], ID, IDS),
    Times = 100000,
    D = data_times(Times, Size),
    cdump:put(D, ID, IDS),
    success.
%test_times(Times, Size, ID, IDS).
data_times(A, B) ->
    data_times(A, B, []).
data_times(0, _, C) -> C;
data_times(N, Size, C) -> 
    data_times(N-1, Size, [<<0:(8*Size)>>|C]).
%test_times(0, _, _, _) -> success;
%test_times(N, Size, ID, IDS) -> 
%    cdump:put(<<0:(8*Size)>>, ID, IDS),
%    test_times(N-1, Size, ID, IDS).
test1(Threads) ->
    timer:tc(test_cdump, test, [Threads]).
test2(Threads) ->
    cprof:start(),
    test(Threads),
    cprof:pause(),
    cprof:analyse(cdump).
test3(Threads) ->
    eprof:start(),
    eprof:start_profiling([self()]),
    test(Threads),
    eprof:stop_profiling(),
    eprof:analyze(total).
    
    

