-module(cdump).
-behaviour(gen_server).
-export([start_link/2,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2, delete/2,put/3,get/2,word/1,highest/1,make_id/3,next/1,make_ids/2,sizes/1,put2/3,put3/4]).
init({Threads}) -> {ok, {0, Threads}}.
start_link(Threads, Id) -> 
    gen_server:start_link({global, Id}, ?MODULE, {Threads}, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(_, X) -> {noreply, X}.
handle_call(next, _From, {Max, Max}) ->
    {reply, 0, {1, Max}};
handle_call(next, _From, {X, Max}) ->
    {reply, X, {X+1, Max}}.

sizes(IDS) -> 
    sizes(IDS, size(IDS)).
sizes(_, -1) -> 0;
sizes(IDS, N) -> 
    {IDN, _, _} = get_id(N, IDS),
    file_manager:size(IDN) + sizes(IDS, N-1).
delete(X,IDS) -> 
    {IDN, Div, _} = get_id(X, IDS),
    dump:delete(Div, IDN).
%gen_server:cast({global, ID}, {delete, X, ID}).
put_spawn([], _ID, _IDS, _S) -> ok;
put_spawn([D|Data], ID, IDS, S) ->
    spawn(cdump, put3, [D, ID, IDS, S]),
    put_spawn(Data, ID, IDS, S).
put(Data, ID, IDS) -> 
    put_spawn(Data, ID, IDS, self()),
    receive_spawn(length(Data)).
receive_spawn(0) -> [];
receive_spawn(N) -> 
    receive
	X -> [X|receive_spawn(N-1)]
    end.
put3(Data, ID, IDS, S) ->    
    X = put2(Data, ID, IDS),
    S!{Data, X}.
put2(Data, ID, IDS) -> 
    N = next(ID),
    {IDN, _, Rem} = get_id(N, IDS),
    Threads = size(IDS),
    Rem + (Threads * dump:put(Data, IDN)).
%gen_server:call({global, ID}, {write, Data}).
next(ID) -> gen_server:call({global, ID}, next).
get(X, IDS) -> 
    {IDN, Div, _} = get_id(X, IDS),
    dump:get(Div, IDN).
%gen_server:call({global, ID}, {read, X, ID}).
word(IDS) -> 
    dump:word(hd(IDS)).
highest([]) -> 0;
highest([H|IDS]) -> dump:highest(H) + highest(IDS).
make_ids(ID, Threads) -> 
    list_to_tuple(make_ids(ID, Threads-1, Threads)).
make_ids(_ID, -1, _Threads) -> [];
make_ids(ID, N, Threads) ->
    {_, X} = make_id(ID, N, Threads),
    [X|make_ids(ID, N-1, Threads)].
make_id(ID, Location, Threads) ->
    TR = Location,
    Rem = TR rem Threads,
    Div = TR div Threads,
    S = atom_to_list(ID),
    S2 = S ++ "_" ++ integer_to_list(Rem),
    {Div, list_to_atom(S2)}.
get_id(Location, IDS) ->
    Threads = size(IDS),
    N = Location rem Threads,
    IDN = element(N+1, IDS),
    Div = Location div Threads,
    {IDN, Div, N}.
    
