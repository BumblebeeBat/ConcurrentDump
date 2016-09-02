-module(concurrent_dump_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Size = 32,
    Threads = 16,
    %start_dumps(Threads, kv, S),
    concurrent_dump_sup:start_link(Threads, Size, dump).
%start_dumps(0, _, _) -> ok;
%start_dumps(N, ID, S) ->
%    I = atom_to_list(ID),
%    A = list_to_atom(I++integer_to_list(N)),
%    dump_sup:start_link(A, S),
%    start_dumps(N-1, ID, S).
    

stop(_State) ->
    ok.
