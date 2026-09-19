:- module(song_lyrics, [
    write_lyrics/2,
    rewrite_lyrics/3,
    align_lyrics_music/3
]).

:- use_module(song_spec_parser).

write_lyrics(Spec, lyrics_sheet([])) :-
    spec_value(Spec, lyrics, off),
    !.
write_lyrics(Spec, lyrics_sheet(Sections)) :-
    spec_value(Spec, lyrics, LyricsMode),
    spec_value(Spec, subject, Subject),
    spec_value(Spec, mood, Mood),
    lyric_sections_for(LyricsMode, Subject, Mood, Sections).

rewrite_lyrics(Instruction, lyrics_sheet(Sections0), lyrics_sheet(Sections)) :-
    text_string(Instruction, Text),
    string_lower(Text, Lower),
    (   sub_string(Lower, _, _, _, "chorus")
    ->  replace_section_lines(Sections0, chorus, [
            "We turn the key and let the skyline sing",
            "One bright line can change the shape of everything"
        ], Sections)
    ;   Sections = Sections0
    ).

align_lyrics_music(Lyrics, Music, aligned_song(Lyrics, Music, [
    support(important_words_with_register_lift),
    support(pauses_before_hooks),
    support(dynamic_density_toward_chorus)
])).

lyric_sections_for(sectional(_), Subject, Mood, [
    lyric_section(chorus, [
        ChorusLine1,
        ChorusLine2
    ])
]) :-
    mood_word(Mood, MoodWord),
    format(string(ChorusLine1), "First light on ~w feels brand new", [Subject]),
    format(string(ChorusLine2), "A sudden colour running straight through ~w", [MoodWord]).
lyric_sections_for(auto, Subject, Mood, Sections) :-
    lyric_sections_for(on, Subject, Mood, Sections).
lyric_sections_for(on, Subject, Mood, [
    lyric_section(verse_1, [
        VerseLine1,
        "Every small detail leaves a spark"
    ]),
    lyric_section(chorus, [
        "Now the whole horizon answers back",
        ChorusLine
    ]),
    lyric_section(verse_2, [
        "I watch the old silence fall away",
        "Something brighter learns my name"
    ]),
    lyric_section(bridge, [
        "Hold the breath before the door swings wide",
        "Let the night turn over to the light"
    ])
]) :-
    format(string(VerseLine1), "I carry the shape of ~w in the dark", [Subject]),
    format(string(ChorusLine), "And ~w becomes the heart of the track", [Subject]),
    mood_word(Mood, _).

mood_word(mysterious, "midnight blue").
mood_word(exhilarating, "electric heat").
mood_word(uplifting, "morning gold").
mood_word(_, "open air").

replace_section_lines([], _, _, []).
replace_section_lines([lyric_section(Name, _)|Rest], Name, Lines, [lyric_section(Name, Lines)|Rest]) :- !.
replace_section_lines([Section|Rest], Name, Lines, [Section|Updated]) :-
    replace_section_lines(Rest, Name, Lines, Updated).

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).
