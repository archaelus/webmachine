%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc TEMPLATE.

-module(skel).
-author('author <author@example.com>').
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
	ok ->
	    true;
	{error, {already_started, App}} ->
	    true;
        Else ->
            error_logger:error_msg("Couldn't start ~p: ~p", [App, Else]),
            Else
    end.
	
%% @spec start() -> ok
%% @doc Start the skel server.
start() ->
    skel_deps:ensure(),
    application:load(skel),
    {ok, Deps} = application:get_key(skel, applications),
    true = lists:all(fun ensure_started/1, Deps),
    application:start(skel).

%% @spec stop() -> ok
%% @doc Stop the skel server.
stop() ->
    Res = application:stop(skel),
    application:stop(webmachine),
    Res.
