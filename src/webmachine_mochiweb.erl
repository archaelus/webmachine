%% @author Justin Sheehy <justin@basho.com>
%% @author Andy Gross <andy@basho.com>
%% @copyright 2007-2008 Basho Technologies
%%
%%    Licensed under the Apache License, Version 2.0 (the "License");
%%    you may not use this file except in compliance with the License.
%%    You may obtain a copy of the License at
%%
%%        http://www.apache.org/licenses/LICENSE-2.0
%%
%%    Unless required by applicable law or agreed to in writing, software
%%    distributed under the License is distributed on an "AS IS" BASIS,
%%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%    See the License for the specific language governing permissions and
%%    limitations under the License.

%% @doc Mochiweb interface for webmachine.
-module(webmachine_mochiweb).
-author('Justin Sheehy <justin@basho.com>').
-author('Andy Gross <andy@basho.com>').
-export([start/1, stop/0, loop/1]).

start(Options) ->
    {DispatchList, Options1} = get_option(dispatch, Options),
    {ErrorHandler0, Options2} = get_option(error_handler, Options1),
    {EnablePerfLog, Options3} = get_option(enable_perf_logger, Options2),
    ErrorHandler = 
	case ErrorHandler0 of 
	    undefined ->
		webmachine_error_handler;
	    EH -> EH
	end,
    {LogDir, Options4} = get_option(log_dir, Options3),
    webmachine_sup:start_logger(LogDir),
    case EnablePerfLog of
	true ->
	    application:set_env(webmachine, enable_perf_logger, true),
	    webmachine_sup:start_perf_logger(LogDir);
	_ ->
	    ignore
    end,
    webmachine_sup:start_dispatcher(DispatchList),
    webmachine_dispatcher:set_error_handler(ErrorHandler),
    mochiweb_http:start([{name, ?MODULE}, {loop, fun loop/1} | Options4]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(MochiReq) ->
    Req = webmachine:new_request(mochiweb, MochiReq),
    case webmachine_dispatcher:dispatch(Req) of
        {no_dispatch_match, _UnmatchedPathTokens} ->
	    ErrorHandler = webmachine_dispatcher:get_error_handler(),
	    ErrorHTML = ErrorHandler:render_error(404, Req, {none, none, []}),
	    Req:append_to_response_body(ErrorHTML),
	    Req:send_response(404),
	    LogData = Req:log_data(),
	    spawn(webmachine_logger, log_access, [LogData]),
	    Req:stop();
        {Mod, ModOpts, Path, Bindings, AppRoot, StringPath} ->
	    %%NOTE: StringPath is only necessary for backwards
	    %% compatibility and will one day go away.
	    Req:load_dispatch_data(Bindings, Path, AppRoot),
	    Req:set_metadata('resource_module', Mod),
            {ok, Pid} = webmachine_resource:start_link(Mod, ModOpts),
            webmachine_decision_core:handle_request(Req, Pid, StringPath)
    end.

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.

