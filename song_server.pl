:- module(song_server, [
    start_server/1,
    stop_server/0
]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(song_writer).
:- use_module(song_editor).
:- dynamic server_port/1.

:- http_handler(root(api/health), health_handler, []).
:- http_handler(root(api/generate), generate_handler, []).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    asserta(server_port(Port)).

stop_server :-
    retract(server_port(Port)),
    http_stop_server(Port, []).

health_handler(_Request) :-
    reply_json_dict(_{status: "ok"}).

generate_handler(Request) :-
    http_parameters(Request, [prompt(Prompt, [string])]),
    song_writer(Prompt, Project),
    with_output_to(string(String), write_term(Project, [quoted(true)])),
    reply_json_dict(_{project: String}).

