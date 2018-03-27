-module(logic).
-behaviour(gen_server).

-export([init/1, terminate/2]).
-export([handle_call/3, handle_cast/2, handle_info/2]).

init(Args) ->
  io:format("init::~p~n", [Args]),
  self() ! init_msg,
  {ok, Args}.

terminate(_Reason, _State) ->
  ok.

handle_call(Request, From, State) ->
  io:format("call::~p from:~p~n", [Request, From]),
  {reply, <<"reply value">>, State}.

handle_cast(Request, State) ->
  io:format("cast::~p~n", [Request]),
  {noreply, State}.

 handle_info(init_msg,  State) ->
  io:format("local state:~p~n", [State]),
  {noreply, State};
 handle_info(Info,  State) ->
  io:format("info::~p~n", [Info]),
  {noreply, State}.
