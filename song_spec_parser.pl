:- module(song_spec_parser, [
    interpret_song_spec/2,
    spec_value/3,
    set_spec_value/4,
    source_terms/3,
    add_source_terms/4
]).

:- use_module(library(lists)).
:- use_module(song_model).
:- use_module(song_language).

interpret_song_spec(Text, SongSpec) :-
    nonvar(Text),
    text_string(Text, String),
    normalize_space(string(Trimmed), String),
    Trimmed \= "",
    string_lower(Trimmed, Lower),
    explicit_attributes(Lower, Explicit),
    inferred_attributes(Lower, Explicit, Inferred),
    build_attributes(Trimmed, Explicit, Inferred, Attributes),
    SongSpec = song_spec(Attributes).

spec_value(Spec, Name, Value) :-
    field_value(Spec, Name, Value).

set_spec_value(Spec0, Name, Value, Spec) :-
    put_field(Spec0, Name, Value, Spec).

source_terms(Spec, Source, Terms) :-
    field_value(Spec, attribute_sources, Sources),
    member(SourceTerm, Sources),
    SourceTerm =.. [Source, Terms].

add_source_terms(Spec0, Source, NewTerms, Spec) :-
    field_value(Spec0, attribute_sources, Sources0),
    update_source_list(Sources0, Source, NewTerms, Sources),
    put_field(Spec0, attribute_sources, Sources, Spec).

build_attributes(Text, Explicit, Inferred, [
    prompt(Text),
    concept(Concept),
    subject(Subject),
    narrative(Narrative),
    mood(Mood),
    genre(Genre),
    energy(Energy),
    tempo(Tempo),
    key(Key),
    mode(Mode),
    meter(Meter),
    form(Form),
    sections([]),
    melody(unassigned),
    harmony(unassigned),
    rhythm(unassigned),
    instrumentation(Instrumentation),
    texture(unassigned),
    dynamics(unassigned),
    effects([]),
    lyrics(LyricsMode),
    originality(prioritise_distinctive_combinations),
    production(Production),
    ending(open_for_dramatisation),
    attribute_sources([
        explicit(Explicit),
        inferred(Inferred),
        creative([])
    ])
]) :-
    resolve_or_default(Explicit, mood, evocative, Mood),
    resolve_or_default(Explicit, genre, pop, Genre),
    resolve_or_default(Explicit, energy, medium, Energy),
    resolve_or_default(Explicit, lyrics, auto, LyricsMode),
    resolve_or_default(Explicit, subject, general_story, Subject),
    resolve_or_default(Explicit, instrumentation, [], Instrumentation),
    resolved_value(Inferred, tempo, Tempo),
    resolved_value(Inferred, key, Key),
    resolved_value(Inferred, mode, Mode),
    resolved_value(Inferred, meter, Meter),
    resolved_value(Inferred, form, Form),
    resolved_value(Inferred, narrative, Narrative),
    resolved_value(Inferred, production, Production),
    concept_from(Text, Genre, Mood, Subject, Concept).

resolved_value(Terms, Name, Value) :-
    member(Term, Terms),
    Term =.. [Name, Value],
    !.

explicit_attributes(Text, Terms) :-
    findall(Term, explicit_attribute(Text, Term), Terms0),
    sort(Terms0, Terms).

explicit_attribute(Text, genre(Genre)) :-
    genre_keyword(Keyword, Genre),
    sub_string(Text, _, _, _, Keyword).
explicit_attribute(Text, mood(Mood)) :-
    mood_keyword(Keyword, Mood),
    sub_string(Text, _, _, _, Keyword).
explicit_attribute(Text, energy(high)) :-
    sub_string(Text, _, _, _, "exhilarating").
explicit_attribute(Text, energy(high)) :-
    sub_string(Text, _, _, _, "energetic").
explicit_attribute(Text, energy(high)) :-
    sub_string(Text, _, _, _, "big").
explicit_attribute(Text, energy(low)) :-
    sub_string(Text, _, _, _, "mysterious").
explicit_attribute(Text, energy(low)) :-
    sub_string(Text, _, _, _, "quiet").
explicit_attribute(Text, subject(Subject)) :-
    subject_from_about(Text, Subject).
explicit_attribute(Text, instrumentation(Instrumentation)) :-
    findall(Instrument, instrumentation_keyword(Text, Instrument), Instruments0),
    Instruments0 \= [],
    sort(Instruments0, Instrumentation).
explicit_attribute(Text, lyrics(sectional([chorus(short)]))) :-
    sub_string(Text, _, _, _, "instrumental"),
    sub_string(Text, _, _, _, "except"),
    sub_string(Text, _, _, _, "chorus").
explicit_attribute(Text, lyrics(off)) :-
    sub_string(Text, _, _, _, "instrumental"),
    \+ sub_string(Text, _, _, _, "except").
explicit_attribute(Text, lyrics(off)) :-
    sub_string(Text, _, _, _, "remove the lyrics").
explicit_attribute(Text, lyrics(on)) :-
    sub_string(Text, _, _, _, "with lyrics").
explicit_attribute(Text, lyrics(on)) :-
    sub_string(Text, _, _, _, "lyrics about").

inferred_attributes(Text, Explicit, Terms) :-
    resolve_or_default(Explicit, genre, pop, Genre),
    resolve_or_default(Explicit, mood, evocative, Mood),
    resolve_or_default(Explicit, energy, medium, Energy),
    resolve_or_default(Explicit, lyrics, auto, LyricsMode),
    resolve_or_default(Explicit, subject, general_story, Subject),
    tempo_for(Genre, Energy, Tempo),
    key_mode_for(Mood, Key, Mode),
    form_for(Genre, LyricsMode, Form),
    narrative_for(Text, Subject, Mood, Narrative),
    production_for(Genre, Mood, Production),
    Terms = [
        tempo(Tempo),
        key(Key),
        mode(Mode),
        meter('4/4'),
        form(Form),
        narrative(Narrative),
        production(Production)
    ].

resolve_or_default(Terms, Name, Default, Value) :-
    (   member(Term, Terms),
        Term =.. [Name, Value0]
    ->  Value = Value0
    ;   Value = Default
    ).

tempo_for(electronic_pop, high, bpm(126)).
tempo_for(dance, high, bpm(128)).
tempo_for(cinematic, _, bpm(102)).
tempo_for(pop, high, bpm(118)).
tempo_for(pop, medium, bpm(108)).
tempo_for(_, low, bpm(84)).
tempo_for(_, _, bpm(100)).

key_mode_for(mysterious, e, minor).
key_mode_for(dark, d, minor).
key_mode_for(melancholic, a, minor).
key_mode_for(uplifting, g, major).
key_mode_for(happy, c, major).
key_mode_for(exhilarating, d, major).
key_mode_for(_, c, major).

form_for(_, off, evolving_arc).
form_for(_, sectional(_), hook_spotlight).
form_for(cinematic, auto, cinematic_arc).
form_for(_, _, verse_chorus_bridge).

narrative_for(Text, Subject, Mood, arc(opening(Subject), turn(Mood), resolution_from(Text))).

production_for(cinematic, mysterious, [wide, nocturnal, evolving]).
production_for(electronic_pop, exhilarating, [bright, wide, pulsing]).
production_for(pop, happy, [clean, present, singalong]).
production_for(_, _, [balanced, adaptive]).

concept_from(Text, Genre, Mood, Subject, concept(Genre, Mood, Subject, inspired_by(Text))).

subject_from_about(Text, SubjectAtom) :-
    sub_string(Text, Start, _, _, "about "),
    SubjectStart is Start + 6,
    sub_string(Text, SubjectStart, _, 0, Rest),
    split_string(Rest, ",.!?;", " ", [Subject|_]),
    Subject \= "",
    atom_string(SubjectAtom, Subject).

genre_keyword("electronic pop", electronic_pop).
genre_keyword("electronic", electronic_pop).
genre_keyword("dance", dance).
genre_keyword("cinematic", cinematic).
genre_keyword("guitar pop", guitar_pop).
genre_keyword("pop", pop).
genre_keyword("orchestra", cinematic).

mood_keyword("mysterious", mysterious).
mood_keyword("happy", happy).
mood_keyword("dark", dark).
mood_keyword("uplifting", uplifting).
mood_keyword("exhilarating", exhilarating).
mood_keyword("futuristic", futuristic).
mood_keyword("melancholic", melancholic).

instrumentation_keyword(Text, strings) :-
    sub_string(Text, _, _, _, "strings").
instrumentation_keyword(Text, piano) :-
    sub_string(Text, _, _, _, "piano").
instrumentation_keyword(Text, guitar) :-
    sub_string(Text, _, _, _, "guitar").
instrumentation_keyword(Text, orchestra) :-
    sub_string(Text, _, _, _, "orchestra").
instrumentation_keyword(Text, lead_synth) :-
    sub_string(Text, _, _, _, "electronic").
instrumentation_keyword(Text, nightclub_drums) :-
    sub_string(Text, _, _, _, "nightclub").

update_source_list(Sources0, Name, NewTerms, Sources) :-
    select(Old, Sources0, Rest),
    Old =.. [Name, Existing],
    !,
    append(Existing, NewTerms, Combined0),
    sort(Combined0, Combined),
    New =.. [Name, Combined],
    Sources = [New|Rest].
update_source_list(Sources0, Name, NewTerms, [New|Sources0]) :-
    New =.. [Name, NewTerms].

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).
