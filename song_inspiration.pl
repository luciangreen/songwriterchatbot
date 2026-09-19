:- module(song_inspiration, [
    inspiration_mode/1,
    analyse_song_library/2,
    find_inspiration/2,
    find_inspiration/3,
    transform_inspiration/2
]).

:- use_module(song_language).
:- use_module(song_spec_parser).

inspiration_mode(off).
inspiration_mode(user_library).
inspiration_mode(reference).
inspiration_mode(mind_reader).

analyse_song_library(Songs, patterns([
    recurring_forms(Forms),
    common_instrumentation(Instruments)
])) :-
    findall(Form, (member(song(Fields), Songs), member(form(Form), Fields)), Forms),
    findall(Instrument, (member(song(Fields), Songs), member(instrumentation(Items), Fields), member(Instrument, Items)), Instruments).

find_inspiration(Spec, Inspirations) :-
    find_inspiration(Spec, patterns([]), Inspirations).

find_inspiration(Spec, _Patterns, Inspirations) :-
    spec_value(Spec, prompt, Prompt),
    spec_value(Spec, genre, Genre),
    interesting_language(Prompt, Features),
    text_string(Prompt, PromptString),
    findall(
        inspiration(source(sentence), feature(FeatureName), transformation(Transform)),
        (member(feature(FeatureName, Matches), Features),
         Matches \= [],
         inspiration_transform(Genre, FeatureName, Transform)),
        Inspirations0),
    (   sub_string(PromptString, _, _, _, "reference")
    ->  Extra = [
            inspiration(source(sentence), feature(reference_request), transformation(abstracted_before_use)),
            inspiration(source(reference_prompt), feature(reference_shape), transformation(abstracted_before_use))
        ]
    ;   Extra = []
    ),
    append(Inspirations0, Extra, Inspirations1),
    sort(Inspirations1, Inspirations).

transform_inspiration(inspiration(source(Source), feature(Feature), transformation(Transform)),
    transformed_inspiration(source(Source), feature(Feature), transformation(Transform), result(variation))).

inspiration_transform(electronic_pop, imagery, neon_hook_and_wide_drop).
inspiration_transform(cinematic, transformation, orchestral_to_club_crossfade).
inspiration_transform(_, movement, rhythmic_propulsion).
inspiration_transform(_, temporal_progression, sectional_growth).
inspiration_transform(_, _, motif_development).

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).
