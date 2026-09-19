:- module(song_evaluator, [
    professional_rule/1,
    evaluate_song/2,
    evaluate_appeal/2
]).

:- use_module(song_model).

professional_rule(section_contrast).
professional_rule(memorable_hook).
professional_rule(controlled_repetition).
professional_rule(tension_release).
professional_rule(register_balance).
professional_rule(rhythmic_coherence).
professional_rule(arrangement_space).
professional_rule(dynamic_arc).
professional_rule(motif_development).
professional_rule(sectional_identity).

evaluate_song(Song, Analysis) :-
    evaluate_appeal(Song, Analysis).

evaluate_appeal(Song, analysis(score(Score), strengths(Strengths), weaknesses(Weaknesses), heuristics(Heuristics))) :-
    findall(Rule, professional_rule(Rule), Heuristics),
    song_strengths(Song, Strengths),
    song_weaknesses(Song, Weaknesses),
    score_song(Strengths, Weaknesses, Score).

song_strengths(Song, Strengths) :-
    findall(Strength, song_strength(Song, Strength), Strengths0),
    sort(Strengths0, Strengths).

song_strength(Song, recurring_hooks) :-
    field_value(Song, hooks, Hooks),
    Hooks \= [].
song_strength(Song, clear_form) :-
    field_value(Song, sections, Sections),
    length(Sections, Count),
    Count >= 4.
song_strength(Song, section_contrast) :-
    field_value(Song, sections, [section(_, _, DensityA, _), section(_, _, DensityB, _)|_]),
    DensityA \= DensityB.
song_strength(Song, lyrics_music_alignment) :-
    field_value(Song, aligned_support, Support),
    Support \= [].

song_weaknesses(Song, Weaknesses) :-
    findall(Weakness, song_weakness(Song, Weakness), Weaknesses0),
    sort(Weaknesses0, Weaknesses).

song_weakness(Song, no_hooks) :-
    \+ field_value(Song, hooks, [_|_]).
song_weakness(Song, limited_section_development) :-
    field_value(Song, sections, Sections),
    length(Sections, Count),
    Count < 4.

score_song(Strengths, Weaknesses, Score) :-
    length(Strengths, SCount),
    length(Weaknesses, WCount),
    Score is max(1, SCount * 2 - WCount).

