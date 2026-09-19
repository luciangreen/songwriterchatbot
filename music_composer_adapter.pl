:- module(music_composer_adapter, [
    song_spec_to_music_composer/2,
    music_composer_generate/2
]).

:- use_module(song_hooks).
:- use_module(song_model).
:- use_module(song_spec_parser).

song_spec_to_music_composer(Spec, mc_spec([
    form(Form),
    sections(Sections),
    melody(Melody),
    harmony(Harmony),
    rhythm(Rhythm),
    instrumentation(Instrumentation),
    production(Production),
    effects(Effects),
    lyrics_mode(LyricsMode)
])) :-
    spec_value(Spec, form, Form),
    spec_value(Spec, sections, Sections),
    spec_value(Spec, melody, Melody),
    spec_value(Spec, harmony, Harmony),
    spec_value(Spec, rhythm, Rhythm),
    spec_value(Spec, instrumentation, Instrumentation),
    spec_value(Spec, production, Production),
    spec_value(Spec, effects, Effects),
    spec_value(Spec, lyrics, LyricsMode).

music_composer_generate(mc_spec(Fields), song([
    form(Form),
    sections(Sections),
    melody(Melody),
    harmony(Harmony),
    rhythm(Rhythm),
    instrumentation(Instrumentation),
    production(Production),
    effects(Effects),
    hooks(Hooks),
    tracks(Tracks),
    aligned_support([])
])) :-
    member(form(Form), Fields),
    member(sections(Sections), Fields),
    member(melody(Melody), Fields),
    member(harmony(Harmony), Fields),
    member(rhythm(Rhythm), Fields),
    member(instrumentation(Instrumentation), Fields),
    member(production(Production), Fields),
    member(effects(Effects), Fields),
    generate_hooks(song_spec([
        genre(pop),
        mood(evocative),
        lyrics(on)
    ]), Hooks),
    findall(track(Instrument, Role),
        (member(Instrument, Instrumentation), instrument_role(Instrument, Role)),
        Tracks).

instrument_role(sub_bass, bass).
instrument_role(bass, bass).
instrument_role(kick, rhythm).
instrument_role(snare, rhythm).
instrument_role(clap, rhythm).
instrument_role(lead_synth, lead).
instrument_role(arpeggiator, texture).
instrument_role(strings, texture).
instrument_role(piano, harmony).
instrument_role(electric_guitar, harmony).
instrument_role(pads, texture).
instrument_role(_, support).

