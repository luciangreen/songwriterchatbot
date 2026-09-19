:- module(song_writer, [
    song_writer/2,
    song_writer/3,
    edit_song/3,
    generate_song/2,
    write_lyrics/2,
    strip_lyrics/2,
    add_lyrics/3,
    interesting_language/2,
    find_inspiration/2,
    originality_check/3,
    evaluate_song/2,
    improve_song/2,
    improve_song/3,
    export_song/3,
    interpret_song_spec/2,
    expand_song_idea/2,
    dramatise_spec/2,
    song_spec_to_music_composer/2,
    generate_candidates/3,
    evaluate_candidates/2,
    select_candidate/3
]).

:- use_module(library(lists)).
:- use_module(song_language).
:- use_module(song_hooks).
:- use_module(song_spec_parser).
:- use_module(song_structure).
:- use_module(song_lyrics).
:- use_module(song_inspiration).
:- use_module(song_originality).
:- use_module(song_evaluator).
:- use_module(song_export).
:- use_module(song_editor).
:- use_module(song_history).
:- use_module(song_model).
:- use_module(music_composer_adapter).

song_writer(Sentence, Project) :-
    song_writer(Sentence, [], Project).

song_writer(Sentence, _Options, Project) :-
    interpret_song_spec(Sentence, Spec0),
    expand_song_idea(Spec0, Spec1),
    dramatise_spec(Spec1, Spec),
    find_inspiration(Spec, Inspirations),
    write_lyrics(Spec, Lyrics),
    generate_song(Spec, Song0),
    align_lyrics_music(Lyrics, Song0, aligned_song(Lyrics, Song0, Support)),
    inject_alignment(Song0, Support, Song),
    build_project(Sentence, Sentence, Spec, Inspirations, Lyrics, Song, [], Project0),
    initialize_history(Project0, Sentence, Project).

generate_song(Spec, Song) :-
    song_spec_to_music_composer(Spec, MCSpec),
    music_composer_generate(MCSpec, Song0),
    generate_hooks(Spec, Hooks),
    put_field(Song0, hooks, Hooks, Song).

strip_lyrics(Project, NewProject) :-
    song_editor:edit_song(Project, "instrumental", NewProject).

add_lyrics(Project, _Instruction, NewProject) :-
    song_editor:edit_song(Project, "add lyrics", NewProject).

improve_song(Song, ImprovedSong) :-
    improve_song(Song, 1, ImprovedSong).

improve_song(Song, Iterations, ImprovedSong) :-
    evaluate_song(Song, analysis(_, _, weaknesses(Weaknesses), _)),
    improve_from_weaknesses(Weaknesses, Song, Iterations, ImprovedSong).

improve_from_weaknesses([], Song, _, Song).
improve_from_weaknesses(_, Song, 0, Song).
improve_from_weaknesses([no_hooks|_], song(Fields0), _, song(Fields)) :-
    put_field(song(Fields0), hooks,
        [hook(melodic, motif([rise, hold, release]), recurrence([chorus, final_chorus]), variation(last_repeat)),
         hook(rhythmic, figure([push, answer]), recurrence([verse_1, chorus]), variation(accent_shift))],
        song(Fields)).
improve_from_weaknesses([limited_section_development|_], song(Fields0), _, song(Fields)) :-
    field_value(song(Fields0), sections, Sections0),
    append(Sections0, [section(outro_extension, 4, transformed, release)], Sections),
    put_field(song(Fields0), sections, Sections, song(Fields)).
improve_from_weaknesses(_, Song, _, Song).

generate_candidates(Spec, N, Songs) :-
    findall(Song,
        (between(1, N, Index),
         candidate_variant(Spec, Index, VariantSpec),
         generate_song(VariantSpec, Song)),
        Songs).

evaluate_candidates(Songs, Analyses) :-
    maplist(evaluate_song, Songs, Analyses).

select_candidate([Song|Songs], [Analysis|Analyses], Selected) :-
    analysis_score(Analysis, Score),
    select_candidate_(Songs, Analyses, Score-Song, _BestScore-Selected).

select_candidate_([], [], Best, Best).
select_candidate_([Song|Songs], [Analysis|Analyses], BestScore-BestSong, Selected) :-
    analysis_score(Analysis, Score),
    (   Score > BestScore
    ->  NextBest = Score-Song
    ;   NextBest = BestScore-BestSong
    ),
    select_candidate_(Songs, Analyses, NextBest, Selected).

candidate_variant(Spec0, 1, Spec0) :- !.
candidate_variant(Spec0, Index, Spec) :-
    Tempo is 96 + Index * 6,
    set_spec_value(Spec0, tempo, bpm(Tempo), S1),
    set_spec_value(S1, production, [variant(Index), widened], Spec).

analysis_score(analysis(score(Score), _, _, _), Score).

inject_alignment(song(Fields0), Support, song(Fields)) :-
    put_field(song(Fields0), aligned_support, Support, song(Fields)).
