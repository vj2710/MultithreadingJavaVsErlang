-module(main).
-export([main/1, getreq/1, getresp/0]).

%%caller code starts

getreq(Sndr) ->
    receive
        {initial, Master, Sendername ,ReceiveeList} ->
        lists:foreach(fun(Receivee) -> 
        whereis(Receivee) ! {intro, Master, Sendername, Receivee}
        end, ReceiveeList),
        getreq(Sndr);
        {intro, Master, SndrName ,RcvrName} ->
        { _, _, RcvTime} = erlang:now(),
        Master ! {intromsg, SndrName, RcvrName, RcvTime},
        whereis(SndrName) ! {reply, Master, SndrName, RcvrName, RcvTime},
        getreq(Sndr);
        {reply, Master, SndrName ,RcvrName, RcvTime} ->
        Master ! {replyMsg, SndrName, RcvrName, RcvTime},
        getreq(Sndr)
        
        after 1000 ->
        io:format("Process ~w has received no calls for 1 second, ending... ~n", [Sndr]),
        ok
    end.
    
%%caller code ends    
    
getresp() ->
    %io:fwrite("inside resp ~n"),
    receive
        {intromsg, SndrName, RcvrName, RcvTime} ->
        io:fwrite("~w received intro message from ~w [~p] ~n", [RcvrName, SndrName, RcvTime]),
        getresp();
        
        {replyMsg, SndrName, RcvrName, RcvTime} ->
        io:fwrite("~w received reply message from ~w [~p] ~n", [SndrName, RcvrName, RcvTime]),
        getresp()
        
        after 1500 ->
        io:format("Master has received no replies for 1.5 seconds, ending... ~n")
    end.

main([_]) ->
    %Hell = "sdsdsd",
    
    %io:fwrite("hello ~w ~n",[Zrand]),
    {Msg, List} = file:consult("calls.txt"),
    MasterPid = spawn(main, getresp, []),
    io:fwrite("** Calls to be made ** ~n"),
    lists:foreach(fun(N) -> {Sendername, ReceiveeList} = N,
        register(Sendername, spawn(main, getreq, [Sendername])),
        io:fwrite("~w: ~w ~n", [Sendername, ReceiveeList])
    end, List),
    
    lists:foreach(fun(N) -> {Sendername, ReceiveeList} = N,
        whereis(Sendername) ! {initial, MasterPid, Sendername, ReceiveeList}
    end, List),
   
init:stop() .



