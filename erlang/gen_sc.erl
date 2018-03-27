-module(gen_sc).

-compile(export_all).

% gen_server:start_link -----> Module:init/1
% gen_server:stop       -----> Module:terminate/2
% gen_server:multi_call -----> Module:handle_call/3
% gen_server:abcast     -----> Module:handle_cast/2
% -                     -----> Module:handle_info/2
% -                     -----> Module:terminate/2
% -                     -----> Module:code_change/3

%% API

start_link(Module, Args, _Opts) -> 
  Pid = spawn_link(?MODULE, init, [Module, Args]),
  {ok, Pid}.

call(Pid, Request) ->
  Ref = make_ref(),
  Pid ! {call, {Ref, self()}, Request},
  receive
    {response, Ref, Response} ->  {ok, Response}
  end.


cast(Pid, Request) ->
  Pid ! {cast, Request},
  ok.

%% internal

init(Module, Args) ->
  {ok, State} = Module:init(Args),
  loop(Module, State).

loop(Module, State) ->
  receive
    {call, {Ref, Pid} = From, Request} ->
      {reply, Response, NewState} = Module:handle_call(Request, From, State),
      Pid ! {response, Ref, Response},
      loop(Module, NewState);
    {cast, Request} ->
      {noreply, NewState} = Module:handle_cast(Request, State),
      loop(Module, NewState);
    Msg ->
      {noreply, NewState} = Module:handle_info(Msg, State),
      loop(Module, NewState)
  end.
