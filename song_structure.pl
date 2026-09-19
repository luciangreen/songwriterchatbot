:- module(song_structure, [
    expand_song_idea/2,
    dramatise_spec/2
]).

:- use_module(song_spec_parser).
:- use_module(song_language).

expand_song_idea(Spec0, Spec) :-
    spec_value(Spec0, genre, Genre),
    spec_value(Spec0, mood, Mood),
    spec_value(Spec0, energy, Energy),
    spec_value(Spec0, lyrics, LyricsMode),
    spec_value(Spec0, instrumentation, ExistingInstrumentation),
    sections_for(Genre, LyricsMode, Sections),
    melody_for(Mood, Energy, Melody),
    harmony_for(Genre, Mood, Harmony),
    rhythm_for(Genre, Energy, Rhythm),
    instrumentation_for(Genre, ExistingInstrumentation, Instrumentation),
    texture_for(Energy, Texture),
    dynamics_for(Sections, Dynamics),
    effects_for(Mood, Effects),
    ending_for(LyricsMode, Ending),
    set_spec_value(Spec0, sections, Sections, Spec1),
    set_spec_value(Spec1, melody, Melody, Spec2),
    set_spec_value(Spec2, harmony, Harmony, Spec3),
    set_spec_value(Spec3, rhythm, Rhythm, Spec4),
    set_spec_value(Spec4, instrumentation, Instrumentation, Spec5),
    set_spec_value(Spec5, texture, Texture, Spec6),
    set_spec_value(Spec6, dynamics, Dynamics, Spec7),
    set_spec_value(Spec7, effects, Effects, Spec8),
    set_spec_value(Spec8, ending, Ending, Spec9),
    add_source_terms(Spec9, creative,
        [sections(Sections), melody(Melody), harmony(Harmony), rhythm(Rhythm),
         instrumentation(Instrumentation), texture(Texture), dynamics(Dynamics),
         effects(Effects), ending(Ending)],
        Spec).

dramatise_spec(Spec0, Spec) :-
    spec_value(Spec0, prompt, Prompt),
    spec_value(Spec0, sections, Sections0),
    interesting_language(Prompt, Features),
    dramatic_arc_for(Features, Arc),
    dramatise_sections(Sections0, Arc, Sections),
    set_spec_value(Spec0, sections, Sections, Spec1),
    set_spec_value(Spec1, narrative, dramatic_arc(Arc, Features), Spec2),
    add_source_terms(Spec2, creative, [narrative(dramatic_arc(Arc, Features))], Spec).

sections_for(_, off, [
    section(intro, 8, sparse),
    section(development, 16, growing),
    section(climax, 16, full),
    section(outro, 8, release)
]).
sections_for(_, sectional(_), [
    section(intro, 4, sparse),
    section(verse_1, 8, restrained),
    section(chorus, 6, focused_peak),
    section(outro, 4, echo)
]).
sections_for(cinematic, _, [
    section(intro, 8, distant),
    section(verse_1, 12, restrained),
    section(build, 8, rising),
    section(climax, 12, expansive),
    section(outro, 8, transformed)
]).
sections_for(_, _, [
    section(intro, 4, airy),
    section(verse_1, 8, focused),
    section(pre_chorus, 4, lifting),
    section(chorus, 8, open),
    section(verse_2, 8, developing),
    section(chorus_2, 8, bigger),
    section(bridge, 8, contrast),
    section(final_chorus, 8, peak),
    section(outro, 4, afterglow)
]).

melody_for(mysterious, _, melodic_plan([low_phrase, held_tone, unresolved_return])).
melody_for(uplifting, high, melodic_plan([pickup, leap, answer, extension])).
melody_for(exhilarating, _, melodic_plan([rise, leap, repeat, release])).
melody_for(_, _, melodic_plan([statement, answer, hook_return])).

harmony_for(cinematic, _, progression([i, vi, iii, vii])).
harmony_for(electronic_pop, _, progression([vi, iv, i, v])).
harmony_for(dance, _, progression([i, bvi, biii, bvii])).
harmony_for(_, mysterious, progression([i, iv, vi, v])).
harmony_for(_, _, progression([i, v, vi, iv])).

rhythm_for(dance, high, groove(four_on_floor, syncopated_bass)).
rhythm_for(electronic_pop, _, groove(pulsing_eighths, lifted_chorus)).
rhythm_for(_, low, groove(spacious_backbeat, suspended_subdivisions)).
rhythm_for(_, _, groove(steady_backbeat, sectional_variation)).

instrumentation_for(_, Existing, Existing) :-
    Existing \= [],
    Existing \= [ ].
instrumentation_for(electronic_pop, _, [kick, snare, sub_bass, lead_synth, pads]).
instrumentation_for(dance, _, [kick, clap, sub_bass, arpeggiator, risers]).
instrumentation_for(cinematic, _, [strings, piano, sub_bass, percussion, lead_synth]).
instrumentation_for(guitar_pop, _, [drums, bass, electric_guitar, piano]).
instrumentation_for(_, _, [drums, bass, piano, pads]).

texture_for(high, layered_with_breaks).
texture_for(low, spacious_and_selective).
texture_for(_, dynamic_midrange_focus).

dynamics_for(Sections, DynamicPlan) :-
    findall(dynamic(Name, Level),
        (nth1(Index, Sections, section(Name, _, _)), dynamic_level(Index, Level)),
        DynamicPlan).

dynamic_level(1, restrained) :- !.
dynamic_level(2, measured) :- !.
dynamic_level(3, rising) :- !.
dynamic_level(4, open) :- !.
dynamic_level(5, developing) :- !.
dynamic_level(6, strong) :- !.
dynamic_level(7, contrast) :- !.
dynamic_level(8, peak) :- !.
dynamic_level(_, resolve).

effects_for(mysterious, [reverb_tail, filtered_intro, ghost_delay]).
effects_for(exhilarating, [uplifter, stereo_width, chorus_throw]).
effects_for(_, [section_transitions, contrast_mutes]).

ending_for(sectional(_), brief_afterglow).
ending_for(off, transformed_recall).
ending_for(_, chorus_afterglow).

dramatic_arc_for(Features, transformation_arc) :-
    member(feature(transformation, _), Features),
    !.
dramatic_arc_for(Features, nocturnal_reveal) :-
    member(feature(imagery, Imagery), Features),
    member("night", Imagery),
    !.
dramatic_arc_for(Features, tension_release) :-
    member(feature(tension, _), Features),
    !.
dramatic_arc_for(_, unfolding_arrival).

dramatise_sections(Sections, Arc, Dramatised) :-
    findall(section(Name, Bars, Density, Function),
        (nth1(Index, Sections, section(Name, Bars, Density)),
         dramatic_function(Arc, Index, Function)),
        Dramatised).

dramatic_function(_, 1, signal) :- !.
dramatic_function(transformation_arc, 2, emergence) :- !.
dramatic_function(transformation_arc, 3, mutation) :- !.
dramatic_function(transformation_arc, 4, arrival) :- !.
dramatic_function(nocturnal_reveal, 2, observation) :- !.
dramatic_function(nocturnal_reveal, 3, wonder) :- !.
dramatic_function(tension_release, 3, suspension) :- !.
dramatic_function(_, 4, payoff) :- !.
dramatic_function(_, 5, development) :- !.
dramatic_function(_, 6, expansion) :- !.
dramatic_function(_, 7, contrast) :- !.
dramatic_function(_, 8, catharsis) :- !.
dramatic_function(_, _, release).
