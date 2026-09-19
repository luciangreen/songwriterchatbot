:- module(song_hooks, [
    generate_hooks/2
]).

:- use_module(song_spec_parser).

generate_hooks(Spec, Hooks) :-
    spec_value(Spec, genre, Genre),
    spec_value(Spec, mood, Mood),
    spec_value(Spec, lyrics, LyricsMode),
    melodic_hook_for(Genre, Mood, Melodic),
    rhythmic_hook_for(Genre, Rhythmic),
    optional_lyrical_hook(LyricsMode, Lyrical),
    include(nonvar, [Melodic, Rhythmic, Lyrical], Hooks).

melodic_hook_for(electronic_pop, exhilarating,
    hook(melodic, motif([rise, leap, hold]), recurrence([chorus, final_chorus]), variation(invert_tail))).
melodic_hook_for(_, mysterious,
    hook(melodic, motif([step, hover, fall]), recurrence([intro, chorus, outro]), variation(register_shift))).
melodic_hook_for(_, _,
    hook(melodic, motif([rise, hold, fall]), recurrence([chorus, final_chorus]), variation(rhythmic_displacement))).

rhythmic_hook_for(dance,
    hook(rhythmic, figure([kick, rest, clap, kick]), recurrence([intro, chorus, bridge]), variation(extra_pickup))).
rhythmic_hook_for(electronic_pop,
    hook(rhythmic, figure([pulse, pulse, lift]), recurrence([verse_1, chorus, final_chorus]), variation(density_build))).
rhythmic_hook_for(_,
    hook(rhythmic, figure([push, answer]), recurrence([verse_1, chorus]), variation(accent_shift))).

lyrical_hook_for(off, _) :- !, fail.
lyrical_hook_for(sectional(_),
    hook(lyrical, phrase(short_refrain), recurrence([chorus]), variation(harmony_swap))).
lyrical_hook_for(_,
    hook(lyrical, phrase(core_title_line), recurrence([chorus, final_chorus]), variation(last_word_extension))).

optional_lyrical_hook(LyricsMode, Hook) :-
    (   lyrical_hook_for(LyricsMode, Hook)
    ->  true
    ;   Hook = _
    ).
