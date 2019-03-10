-module(calling).
-export([getreq/1, gotosleep/0]).

getreq(Sndr) ->
    receive
        {initial, Master, Sendername ,ReceiveeList} ->
        lists:foreach(fun(Receivee) -> 
        whereis(Receivee) ! {intro, Master, Sendername, Receivee}
        end, ReceiveeList),
        getreq(Sndr);
        
		{intro, Master, SndrName ,RcvrName} ->
        { _, _, RcvTime} = erlang:now(),
		gotosleep(),
        Master ! {intromsg, SndrName, RcvrName, RcvTime},
        whereis(SndrName) ! {reply, Master, SndrName, RcvrName, RcvTime},
        getreq(Sndr);
        
		{reply, Master, SndrName ,RcvrName, RcvTime} ->
		gotosleep(),
        Master ! {replyMsg, SndrName, RcvrName, RcvTime},
        getreq(Sndr)
        
        after 1000 ->
        io:format("~nProcess ~w has received no calls for 1 second, ending... ~n", [Sndr])
    end.
	
gotosleep() ->
	random:seed(now()),
    Zrand = random:uniform(100),
    timer:sleep(Zrand).