:- module(song_export, [
    export_song/3,
    save_project/2,
    load_project/2
]).

:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module(song_model).

export_song(Project, prolog, File) :-
    temp_path(File),
    save_project(Project, File).
export_song(Project, json, File) :-
    temp_path(File),
    with_output_to(string(ProjectString), write_term(Project, [quoted(true)])),
    setup_call_cleanup(
        open(File, write, Stream),
        json_write_dict(Stream, _{project: ProjectString}),
        close(Stream)
    ).
export_song(Project, text, File) :-
    temp_path(File),
    setup_call_cleanup(
        open(File, write, Stream),
        write_project_text(Stream, Project),
        close(Stream)
    ).

save_project(Project, File) :-
    setup_call_cleanup(
        open(File, write, Stream),
        write_term(Stream, Project, [quoted(true), fullstop(true), nl(true)]),
        close(Stream)
    ).

load_project(File, Project) :-
    setup_call_cleanup(
        open(File, read, Stream),
        read_term(Stream, Project, []),
        close(Stream)
    ).

temp_path(File) :-
    tmp_file_stream(text, File, Stream),
    close(Stream),
    true.

write_project_text(Stream, Project) :-
    field_value(Project, title, Title),
    field_value(Project, form, Form),
    field_value(Project, lyrics, Lyrics),
    format(Stream, "Title: ~w~nForm: ~w~nLyrics: ~w~n", [Title, Form, Lyrics]).
