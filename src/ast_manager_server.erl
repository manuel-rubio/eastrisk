%%% ----------------------------------------------------------------------------
%%% @private
%%% @author Oscar Hellstr�m <oscar@erlang-consulting.com>
%%%
%%% @version 0.3, 2006-08-08
%%% @copyright 2006 Erlang Training and Consulting
%%%
%%% @doc
%%% Callback module which implements the manager behaviour.
%%% <p>
%%% Sends all events to the {@link ast_manager_events} to be processed further.
%%% </p>
%%% @end
%%% ----------------------------------------------------------------------------
-module(ast_manager_server).
-behaviour(ast_manager).

-export([start_link/4]).

-export([init/1, handle_event/2, terminate/2, code_change/3]).

start_link(Host, Port, Name, Secret) ->
	Result = ast_manager:start_link(?MODULE, Host, Port, nil),
	case Result of
	{ok, _} ->
		case ast_manager:login(Name, Secret) of
			{Else, Vars} -> exit({Else, Vars});
			ok           ->
                case application:get_env(eastrisk, mgr_server_events_level) of
                    {ok, Level} ->
                        ok = ast_manager:events(Level);
                    _NotSetted  ->
                        nop
                end,
                ok
		end;
	_       -> ok
	end,
	Result.

init(nil) ->
	{ok, nil}.

handle_event(Event, State) ->
	ast_manager_events:notify_event(Event),
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
