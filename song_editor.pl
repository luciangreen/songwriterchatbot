:- module(song_editor, [
    edit_song/3
]).

:- use_module(library(lists)).
:- use_module(song_history).
:- use_module(song_model).
:- use_module(song_lyrics).
:- use_module(song_spec_parser).
:- use_module(music_composer_adapter).

edit_song(Project, Instruction, UpdatedProject) :-
    text_string(Instruction, Text),
    string_lower(Text, Lower),
    (   member(Lower, ["undo", "redo"])
    ->  history_edit(Lower, Project, UpdatedProject)
    ;   field_value(Project, interpreted_spec, Spec0),
        field_value(Project, lyrics, Lyrics0),
        apply_edit(Lower, Project, Spec0, Lyrics0, Spec, Lyrics),
        song_spec_to_music_composer(Spec, MCSpec),
        music_composer_generate(MCSpec, Song),
        refresh_project(Project, Spec, Lyrics, Song, ProjectNoHistory),
        record_revision(Project, ProjectNoHistory, Text, UpdatedProject)
    ).

history_edit("undo", Project, UpdatedProject) :-
    undo_project(Project, UpdatedProject).
history_edit("redo", Project, UpdatedProject) :-
    redo_project(Project, UpdatedProject).

apply_edit(Lower, _Project, Spec0, _Lyrics0, Spec, Lyrics) :-
    sub_string(Lower, _, _, _, "add lyrics"),
    !,
    set_spec_value(Spec0, lyrics, on, Spec),
    write_lyrics(Spec, Lyrics).
apply_edit(Lower, Project, Spec0, Lyrics0, Spec0, Lyrics) :-
    sub_string(Lower, _, _, _, "rewrite lyrics"),
    !,
    rewrite_lyrics(Lower, Lyrics0, Lyrics),
    field_value(Project, interpreted_spec, Spec0).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "add strings"),
    !,
    spec_value(Spec0, instrumentation, Instruments0),
    sort([strings|Instruments0], Instruments),
    set_spec_value(Spec0, instrumentation, Instruments, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "more energetic"),
    !,
    set_spec_value(Spec0, energy, high, S1),
    set_spec_value(S1, tempo, bpm(128), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "less busy"),
    !,
    set_spec_value(Spec0, texture, spacious_and_selective, S1),
    set_spec_value(S1, rhythm, groove(spacious_backbeat, reduced_motion), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics) :-
    sub_string(Lower, _, _, _, "change the second verse into an instrumental section"),
    !,
    spec_value(Spec0, sections, Sections0),
    replace_section_name(Sections0, verse_2, instrumental_break, Sections),
    set_spec_value(Spec0, sections, Sections, Spec),
    remove_lyric_section(Lyrics0, verse_2, Lyrics).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "make the chorus bigger"),
    !,
    spec_value(Spec0, sections, Sections0),
    enlarge_chorus(Sections0, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "more futuristic without changing the melody"),
    !,
    spec_value(Spec0, instrumentation, Instruments0),
    sort([lead_synth, pads|Instruments0], Instruments),
    set_spec_value(Spec0, instrumentation, Instruments, S1),
    set_spec_value(S1, production, [glassy, filtered, wide], Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "give the bass more movement"),
    !,
    set_spec_value(Spec0, rhythm, groove(active_low_end, syncopated_bass), Spec).
apply_edit(Lower, _Project, Spec0, _Lyrics0, Spec, lyrics_sheet([])) :-
    (sub_string(Lower, _, _, _, "instrumental"); sub_string(Lower, _, _, _, "remove the lyrics")),
    !,
    set_spec_value(Spec0, lyrics, off, Spec).
apply_edit(_, _Project, Spec, Lyrics, Spec, Lyrics).

replace_section_name([], _, _, []).
replace_section_name([section(Name, Bars, Density, Function)|Rest], Name, NewName, [section(NewName, Bars, Density, Function)|Rest]) :- !.
replace_section_name([section(Name, Bars, Density)|Rest], Name, NewName, [section(NewName, Bars, Density)|Rest]) :- !.
replace_section_name([Section|Rest], Name, NewName, [Section|Updated]) :-
    replace_section_name(Rest, Name, NewName, Updated).

remove_lyric_section(lyrics_sheet(Sections0), Name, lyrics_sheet(Sections)) :-
    exclude(is_named_section(Name), Sections0, Sections).

is_named_section(Name, lyric_section(Name, _)).

enlarge_chorus([], []).
enlarge_chorus([section(chorus, Bars, Density)|Rest], [section(chorus, NewBars, bigger_than(Density))|Rest]) :-
    NewBars is Bars + 4,
    !.
enlarge_chorus([section(chorus_2, Bars, Density)|Rest], [section(chorus_2, NewBars, bigger_than(Density))|Rest]) :-
    NewBars is Bars + 4,
    !.
enlarge_chorus([Section|Rest], [Section|Updated]) :-
    enlarge_chorus(Rest, Updated).

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).
