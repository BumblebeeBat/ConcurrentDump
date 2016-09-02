-module(cdump).
-behaviour(gen_server).
-export([start_link/3,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2, delete/2,put/2,get/2,word/1,highest/1,make_id/3]).
init({WordSize, Threads, ID}) -> 
    IDS = make_ids(ID, Threads),
    {ok, {WordSize, Threads, ID, IDS}}.
start_link(Threads, WordSize, Id) -> 
    gen_server:start_link({global, Id}, ?MODULE, {WordSize, Threads, Id}, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({delete, Location, ID}, X) -> 
    {_,_,ID,_} = X,
    dump_bits:delete(ID, Location),
    {noreply, X};
handle_cast(_, X) -> {noreply, X}.
handle_call({write, Data}, _From, {Word, Threads, ID, IDS}) -> 
    Word = size(Data),
    Top = dump_bits:top(ID),
    {IDN, Div} = get_id(Top, Threads, IDS),
    file_manager:write(IDN, Div, Data),
    dump_bits:write(ID),
    {reply, Top, {Word, Threads, ID, IDS}};
handle_call({read, Location, ID}, _From, {Word, Threads, ID, IDS}) -> 
    {IDN, Div} = get_id(Location, Threads, IDS),
    Z = case file_manager:read(IDN, Div, Word) of
	    {ok, A} -> 
		A;
	    eof -> <<0:(Word*8)>>
	end,
    {reply, Z, {Word, Threads, ID, IDS}};
handle_call(word, _From, {Word, Threads, ID, IDS}) -> 
    {reply, Word, {Word, Threads, ID, IDS}};
handle_call({highest, ID}, _From, {Word, Threads, ID, IDS}) -> 
    S = sizes(IDS, Threads-1, Threads),
    {reply, S, {Word, Threads, ID, IDS}}.
sizes(_, -1, _) -> 0;
sizes(IDS, N, Threads) -> 
    {IDN, _} = get_id(N, Threads, IDS),
    file_manager:size(IDN) + sizes(IDS, N-1, Threads).
delete(X,ID) -> gen_server:cast({global, ID}, {delete, X, ID}).
put(Data, ID) -> 
    gen_server:call({global, ID}, {write, Data}).
get(X, ID) -> gen_server:call({global, ID}, {read, X, ID}).
word(ID) -> gen_server:call({global, ID}, word).
highest(ID) -> gen_server:call({global, ID}, {highest, ID}).
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
get_id(Location, Threads, IDS) ->
    N = Location rem Threads,
    IDN = element(N+1, IDS),
    Div = Location div Threads,
    {IDN, Div}.
    
