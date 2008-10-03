%% @author Justin Sheehy <justin@basho.com>
%% @author Andy Gross <andy@basho.com>
%% @author Jeremy Latt <jeremy@basho.com>
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


%% @doc Some fairly minimal error message formatters.

-module(webmachine_error_handler).
-author('Justin Sheehy <justin@basho.com>').
-author('Andy Gross <andy@basho.com>').
-author('Jeremy Latt <jeremy@basho.com>').

-export([render_error/3]).

render_error(404, Req, _Reason) ->
    Req:add_response_header("Content-Type", "text/html"),
    <<"<HTML><HEAD><TITLE>404 Not Found</TITLE></HEAD><BODY><H1>Not Found</H1>The requested document was not found on this server.<P><HR><ADDRESS>mochiweb+webmachine web server</ADDRESS></BODY></HTML>">>;

render_error(500, Req, Reason) ->
    Req:add_response_header("Content-Type", "text/html"),
    error_logger:error_msg("webmachine error: path=~p~n~p~n", [Req:path(), Reason]),
    STString = io_lib:format("~p", [Reason]),
    ErrorStart = "<html><head><title>500 Internal Server Error</title></head><body><h1>Internal Server Error</h1>The server encountered an error while processing this request:<br><pre>",
    ErrorEnd = "</pre><P><HR><ADDRESS>mochiweb+webmachine web server</ADDRESS></body></html>",
    ErrorIOList = [ErrorStart,STString,ErrorEnd],
    erlang:iolist_to_binary(ErrorIOList).

