:- module(song_history, [
    build_project/8,
    initialize_history/3,
    refresh_project/5,
    record_revision/4,
    undo_project/2,
    redo_project/2
]).

:- use_module(library(uuid)).
:- use_module(song_model).
:- use_module(song_spec_parser).

build_project(TitleSeed, Prompt, Spec, Inspirations, Lyrics, Song, Outputs, song_project([
    id(Id),
    title(Title),
    original_prompt(Prompt),
    interpreted_spec(Spec),
    inspirations(Inspirations),
    form(Form),
    lyrics(Lyrics),
    melody(Melody),
    harmony(Harmony),
    rhythm(Rhythm),
    instruments(Instruments),
    production(Production),
    song(Song),
    outputs(Outputs),
    revisions(history([], none, []))
])) :-
    uuid(Id),
    title_from_seed(TitleSeed, Title),
    spec_value(Spec, form, Form),
    spec_value(Spec, melody, Melody),
    spec_value(Spec, harmony, Harmony),
    spec_value(Spec, rhythm, Rhythm),
    spec_value(Spec, instrumentation, Instruments),
    spec_value(Spec, production, Production).

initialize_history(Project0, Instruction, Project) :-
    project_snapshot(Project0, Snapshot),
    uuid(RevisionId),
    put_field(Project0, revisions, history([], revision(RevisionId, none, Instruction, Snapshot), []), Project).

refresh_project(Project0, Spec, Lyrics, Song, Project) :-
    spec_value(Spec, form, Form),
    spec_value(Spec, melody, Melody),
    spec_value(Spec, harmony, Harmony),
    spec_value(Spec, rhythm, Rhythm),
    spec_value(Spec, instrumentation, Instruments),
    spec_value(Spec, production, Production),
    put_field(Project0, interpreted_spec, Spec, P1),
    put_field(P1, form, Form, P2),
    put_field(P2, lyrics, Lyrics, P3),
    put_field(P3, melody, Melody, P4),
    put_field(P4, harmony, Harmony, P5),
    put_field(P5, rhythm, Rhythm, P6),
    put_field(P6, instruments, Instruments, P7),
    put_field(P7, production, Production, P8),
    put_field(P8, song, Song, Project).

record_revision(ProjectBefore, ProjectAfterNoHistory, Instruction, Project) :-
    field_value(ProjectBefore, revisions, history(Past, Current, _)),
    Current = revision(CurrentId, _, _, _),
    project_snapshot(ProjectAfterNoHistory, Snapshot),
    uuid(NewId),
    History = history([Current|Past], revision(NewId, CurrentId, Instruction, Snapshot), []),
    put_field(ProjectAfterNoHistory, revisions, History, Project).

undo_project(Project, Undone) :-
    field_value(Project, revisions, history([Previous|Past], Current, Future)),
    Previous = revision(_, _, _, Snapshot),
    apply_snapshot(Project, Snapshot, history(Past, Previous, [Current|Future]), Undone).

redo_project(Project, Redone) :-
    field_value(Project, revisions, history(Past, Current, [Next|Future])),
    Next = revision(_, _, _, Snapshot),
    apply_snapshot(Project, Snapshot, history([Current|Past], Next, Future), Redone).

project_snapshot(Project, snapshot(Fields)) :-
    container_fields(Project, Fields0),
    exclude(is_revisions, Fields0, Fields).

apply_snapshot(Project, snapshot(Fields), History, Updated) :-
    _ = Project,
    Updated = song_project([revisions(History)|Fields]).

is_revisions(revisions(_)).

title_from_seed(Seed, Title) :-
    text_string(Seed, Text),
    split_string(Text, " ", ".,!?;:'\"()", Parts),
    exclude(=(""), Parts, NonEmpty),
    prefix_length(NonEmpty, Head, 4),
    atomic_list_concat(Head, ' ', TitleAtom),
    atom_string(TitleAtom, Title),
    !.
title_from_seed(_, "Song Writer Draft").

prefix_length(List, Prefix, N) :-
    length(Prefix, N),
    append(Prefix, _, List),
    !.
prefix_length(List, List, _).

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).
