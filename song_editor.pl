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
    (   sub_string(Lower, _, _, _, "add lyrics")
    ;   sub_string(Lower, _, _, _, "turn the instrumental into a lyric")
    ;   sub_string(Lower, _, _, _, "give the chorus words")
    ;   sub_string(Lower, _, _, _, "write lyrics")
    ;   sub_string(Lower, _, _, _, "put lyrics back")
    ;   sub_string(Lower, _, _, _, "add words")
    ),
    !,
    set_spec_value(Spec0, lyrics, on, Spec),
    write_lyrics(Spec, Lyrics).
apply_edit(Lower, Project, Spec0, Lyrics0, Spec0, Lyrics) :-
    sub_string(Lower, _, _, _, "rewrite lyrics"),
    !,
    rewrite_lyrics(Lower, Lyrics0, Lyrics),
    field_value(Project, interpreted_spec, Spec0).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "replace the piano with strings"),
    !,
    replace_instrument(Spec0, piano, strings, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "swap guitar for synths"),
    !,
    replace_instrument(Spec0, electric_guitar, lead_synth, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "remove the pads"),
    !,
    remove_instrument(Spec0, pads, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "add a lead synth"),
    !,
    add_instrument(Spec0, lead_synth, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "add strings"),
    !,
    add_instrument(Spec0, strings, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "add arpeggiators"),
    !,
    add_instrument(Spec0, arpeggiator, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "make the drums hit harder"),
    !,
    set_spec_value(Spec0, production, [hard_hitting_drums], Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "give the bass more movement"),
    !,
    set_spec_value(Spec0, rhythm, groove(active_low_end, syncopated_bass), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "change the percussion to club drums"),
    !,
    replace_instrument(Spec0, percussion, nightclub_drums, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "bring the orchestra forward"),
    !,
    set_spec_value(Spec0, production, [orchestra_forward, wide], Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "make the intro only piano and sub bass"),
    !,
    set_section_detail(Spec0, intro, instrumentation([piano, sub_bass]), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "turn the bridge into just piano and voice"),
    !,
    set_section_detail(Spec0, bridge, instrumentation([piano, voice]), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "use brass instead of pads"),
    !,
    replace_instrument(Spec0, pads, brass, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "replace the strings with a choir pad"),
    !,
    replace_instrument(Spec0, strings, choir_pad, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "give the outro a solo guitar line"),
    !,
    set_section_detail(Spec0, outro, instrumentation([electric_guitar]), Spec).
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
    sub_string(Lower, _, _, _, "add a breakdown before the final chorus"),
    !,
    insert_before_section(Spec0, final_chorus,
        section(breakdown, 4, sparse, suspension), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "shorten the intro"),
    !,
    adjust_section_bars(Spec0, intro, half, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "add a bridge after chorus two"),
    !,
    insert_after_section(Spec0, chorus_2,
        section(bridge, 8, contrast, development), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "double the final chorus"),
    !,
    adjust_section_bars(Spec0, final_chorus, double, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "cut verse two in half"),
    !,
    adjust_section_bars(Spec0, verse_2, half, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "start with the hook"),
    !,
    rename_section(Spec0, intro, cold_open, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "add a cold open intro"),
    !,
    set_section_detail(Spec0, intro, cold_open, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "make the ending more abrupt"),
    !,
    set_spec_value(Spec0, ending, abrupt, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "insert a silence before the climax"),
    !,
    insert_before_section(Spec0, climax,
        section(silence, 1, silent, suspension), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "through-composed"),
    !,
    set_spec_value(Spec0, form, through_composed, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "make the chorus bigger"),
    !,
    spec_value(Spec0, sections, Sections0),
    enlarge_chorus(Sections0, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    (sub_string(Lower, _, _, _, "change chorus");
     sub_string(Lower, _, _, _, "repeat this riff during the outro")),
    !,
    spec_value(Spec0, sections, Sections0),
    enlarge_chorus(Sections0, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "change melody"),
    !,
    spec_value(Spec0, melody, melodic_plan(Phrases)),
    append(Phrases, [variation], UpdatedPhrases),
    set_spec_value(Spec0, melody, melodic_plan(UpdatedPhrases), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "change chords"),
    !,
    set_spec_value(Spec0, harmony, progression([i, iii, iv, v]), Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "make it darker"),
    !,
    set_spec_value(Spec0, mood, dark, S1),
    set_spec_value(S1, harmony, progression([i, bvi, iv, v]), S2),
    set_spec_value(S2, production, [dark, filtered, restrained], Spec).
apply_edit(Lower, _Project, Spec0, Lyrics0, Spec, Lyrics0) :-
    sub_string(Lower, _, _, _, "more futuristic without changing the melody"),
    !,
    spec_value(Spec0, instrumentation, Instruments0),
    sort([lead_synth, pads|Instruments0], Instruments),
    set_spec_value(Spec0, instrumentation, Instruments, S1),
    set_spec_value(S1, production, [glassy, filtered, wide], Spec).
apply_edit(Lower, _Project, Spec0, _Lyrics0, Spec, lyrics_sheet([])) :-
    (   sub_string(Lower, _, _, _, "instrumental")
    ;   sub_string(Lower, _, _, _, "remove the lyrics")
    ;   sub_string(Lower, _, _, _, "strip the vocals")
    ;   sub_string(Lower, _, _, _, "delete the lyrics")
    ;   sub_string(Lower, _, _, _, "mute the words")
    ;   sub_string(Lower, _, _, _, "no lyrics")
    ;   sub_string(Lower, _, _, _, "take out all lyrics")
    ;   sub_string(Lower, _, _, _, "remove the chorus words")
    ),
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

add_instrument(Spec0, Instrument, Spec) :-
    spec_value(Spec0, instrumentation, Instruments0),
    sort([Instrument|Instruments0], Instruments),
    set_spec_value(Spec0, instrumentation, Instruments, Spec).

remove_instrument(Spec0, Instrument, Spec) :-
    spec_value(Spec0, instrumentation, Instruments0),
    exclude(=(Instrument), Instruments0, Instruments),
    set_spec_value(Spec0, instrumentation, Instruments, Spec).

replace_instrument(Spec0, Old, New, Spec) :-
    spec_value(Spec0, instrumentation, Instruments0),
    (   select(Old, Instruments0, Rest)
    ->  sort([New|Rest], Instruments)
    ;   sort([New|Instruments0], Instruments)
    ),
    set_spec_value(Spec0, instrumentation, Instruments, Spec).

set_section_detail(Spec0, Name, Detail, Spec) :-
    spec_value(Spec0, sections, Sections0),
    maplist(update_section_detail(Name, Detail), Sections0, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).

update_section_detail(Name, Detail, section(Name, Bars, _Density, Function),
        section(Name, Bars, Detail, Function)) :- !.
update_section_detail(Name, Detail, section(Name, Bars, _Density),
        section(Name, Bars, Detail)) :- !.
update_section_detail(_, _, Section, Section).

insert_before_section(Spec0, Name, NewSection, Spec) :-
    spec_value(Spec0, sections, Sections0),
    insert_before(Sections0, Name, NewSection, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).

insert_before([Section|Rest], Name, NewSection, [NewSection, Section|Rest]) :-
    Section = section(Name, _, _, _), !.
insert_before([Section|Rest], Name, NewSection, [NewSection, Section|Rest]) :-
    Section = section(Name, _, _), !.
insert_before([Section|Rest], Name, NewSection, [Section|Updated]) :-
    insert_before(Rest, Name, NewSection, Updated).
insert_before([], _, NewSection, [NewSection]).

insert_after_section(Spec0, Name, NewSection, Spec) :-
    spec_value(Spec0, sections, Sections0),
    insert_after(Sections0, Name, NewSection, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).

insert_after([Section|Rest], Name, NewSection, [Section, NewSection|Rest]) :-
    Section = section(Name, _, _, _), !.
insert_after([Section|Rest], Name, NewSection, [Section, NewSection|Rest]) :-
    Section = section(Name, _, _), !.
insert_after([Section|Rest], Name, NewSection, [Section|Updated]) :-
    insert_after(Rest, Name, NewSection, Updated).
insert_after([], _, NewSection, [NewSection]).

adjust_section_bars(Spec0, Name, Operation, Spec) :-
    spec_value(Spec0, sections, Sections0),
    maplist(adjust_section(Name, Operation), Sections0, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).

adjust_section(Name, Operation, section(Name, Bars, Density, Function),
        section(Name, UpdatedBars, Density, Function)) :-
    !,
    adjust_bars(Operation, Bars, UpdatedBars).
adjust_section(Name, Operation, section(Name, Bars, Density),
        section(Name, UpdatedBars, Density)) :-
    !,
    adjust_bars(Operation, Bars, UpdatedBars).
adjust_section(_, _, Section, Section).

adjust_bars(half, Bars, Updated) :-
    Updated is max(1, Bars // 2).
adjust_bars(double, Bars, Updated) :-
    Updated is Bars * 2.

rename_section(Spec0, OldName, NewName, Spec) :-
    spec_value(Spec0, sections, Sections0),
    maplist(rename_section_name(OldName, NewName), Sections0, Sections),
    set_spec_value(Spec0, sections, Sections, Spec).

rename_section_name(Old, New, section(Old, Bars, Density, Function),
        section(New, Bars, Density, Function)) :- !.
rename_section_name(Old, New, section(Old, Bars, Density),
        section(New, Bars, Density)) :- !.
rename_section_name(_, _, Section, Section).

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).
