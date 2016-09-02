-module(concurrent_dump_sup).

-behaviour(supervisor).

%% API
-export([start_link/3]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link(Threads, Size, ID) ->
    SID = atom_to_list(ID),
    S = list_to_atom(SID ++ "_sup"),
    supervisor:start_link({local, S}, ?MODULE, [ID, Threads, Size]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([ID, Threads, Size]) ->
    IDS = atom_to_list(ID),
    A2 = list_to_atom(IDS ++ "_bits"), 
    Children = [
		{ID, {cdump, start_link, [Threads, Size, ID]}, permanent, 5000, worker, [cdump]},
		{A2, {dump_bits, start_link, [A2]}, permanent, 5000, worker, [dump_bits]}
	       ] 
	++ files(ID, Threads),
    {ok, { {one_for_one, 5, 10}, Children} }.

files(ID, T) ->
    files(ID, T, T, []).
files(_, 0, _, L) -> L;
files(ID, Threads, TotalThreads, L) ->
    {_, A} = cdump:make_id(ID, Threads, TotalThreads),
    S = atom_to_list(A)++"_file",
    A2 = list_to_atom(S),
    File = S ++ ".db",
    Child = {A2, {file_manager, start_link, [File, A2]}, permanent, 5000, worker, [file_manager]},
    files(ID, Threads - 1, TotalThreads, [Child|L]).
