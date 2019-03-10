-module(exchange).
-export([start/0, getresp/0]).

start() ->
    {_, List} = file:consult("calls.txt"),
    io:fwrite("** Calls to be made ** ~n"),
    lists:foreach(fun(N) -> {Sendername, ReceiveeList} = N,
        register(Sendername, spawn(calling, getreq, [Sendername])),
        io:fwrite("~w: ~w ~n", [Sendername, ReceiveeList])
    end, List),
	io:fwrite("~n"),
    lists:foreach(fun(N) -> {Sendername, ReceiveeList} = N,
        whereis(Sendername) ! {initial, self(), Sendername, ReceiveeList}
    end, List),
    getresp().
	
getresp() ->
    receive
        {intromsg, SndrName, RcvrName, RcvTime} ->
        io:fwrite("~w received intro message from ~w [~p] ~n", [RcvrName, SndrName, RcvTime]),
        getresp();
        
        {replyMsg, SndrName, RcvrName, RcvTime} ->
        io:fwrite("~w received reply message from ~w [~p] ~n", [SndrName, RcvrName, RcvTime]),
        getresp()
        
        after 1500 ->
        io:format("~nMaster has received no replies for 1.5 seconds, ending... ~n")
    end.	
   
   