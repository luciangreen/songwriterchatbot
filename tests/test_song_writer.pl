:- begin_tests(song_writer).

:- use_module('../song_writer.pl').
:- use_module('../song_model.pl').
:- use_module('../song_export.pl').
:- use_module('../song_originality.pl').
:- use_module('../song_spec_parser.pl').
:- use_module('acceptance_pairs.pl').

test(single_sentence_produces_complete_song) :-
    song_writer("Write an exhilarating electronic pop song about seeing a city for the first time at night, instrumental except for a short chorus.", Project),
    field_value(Project, interpreted_spec, Spec),
    field_value(Project, song, Song),
    spec_value(Spec, sections, Sections),
    Sections \= [],
    field_value(Song, sections, SongSections),
    SongSections \= [].

test(instrumental_request_contains_no_full_lyrics) :-
    song_writer("A mysterious instrumental song about walking through Melbourne at 3 AM.", Project),
    field_value(Project, lyrics, lyrics_sheet([])),
    field_value(Project, interpreted_spec, Spec),
    spec_value(Spec, lyrics, off).

test(lyric_request_produces_lyrics_sheet) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project),
    field_value(Project, lyrics, lyrics_sheet(Sections)),
    Sections \= [].

test(add_lyrics_after_composition) :-
    song_writer("Instrumental cinematic dance track where the orchestra gradually turns into a nightclub.", Project0),
    add_lyrics(Project0, "add lyrics", Project),
    field_value(Project, lyrics, lyrics_sheet(Sections)),
    Sections \= [].

test(strip_lyrics_preserves_music) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project0),
    field_value(Project0, form, Form),
    strip_lyrics(Project0, Project),
    field_value(Project, lyrics, lyrics_sheet([])),
    field_value(Project, form, Form).

test(section_edit_is_localised) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project0),
    field_value(Project0, melody, Melody),
    edit_song(Project0, "Change the second verse into an instrumental section.", Project),
    field_value(Project, melody, Melody),
    field_value(Project, interpreted_spec, Spec),
    spec_value(Spec, sections, Sections),
    member(section(instrumental_break, _, _, _), Sections).

test(instrumentation_change_preserves_harmony) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project0),
    field_value(Project0, harmony, Harmony),
    edit_song(Project0, "Add strings.", Project),
    field_value(Project, harmony, Harmony),
    field_value(Project, instruments, Instruments),
    member(strings, Instruments).

test(subsequent_chat_instructions_create_revision_history) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project0),
    edit_song(Project0, "More energetic.", Project1),
    edit_song(Project1, "Undo", Project2),
    field_value(Project2, revisions, history(_Past, Current, Future)),
    Current \= none,
    Future \= [].

test(interesting_language_affects_inspiration) :-
    interpret_song_spec("A cold neon sunrise explodes over a sleeping city.", Spec),
    find_inspiration(Spec, Inspirations),
    Inspirations \= [].

test(hooks_recur_coherently) :-
    interpret_song_spec("Happy guitar pop song with lyrics about finally finishing university.", Spec0),
    expand_song_idea(Spec0, Spec1),
    dramatise_spec(Spec1, Spec),
    generate_song(Spec, Song),
    field_value(Song, hooks, Hooks),
    member(hook(_, _, recurrence([_|_]), _), Hooks).

test(sections_have_beginning_development_and_ending) :-
    song_writer("Create a restrained instrumental that blooms into celebration.", Project),
    field_value(Project, song, Song),
    field_value(Song, sections, Sections),
    Sections = [section(intro, _, _, _)|_],
    last(Sections, section(outro, _, _, _)).

test(adapter_generates_music_composer_spec) :-
    interpret_song_spec("Happy guitar pop song with lyrics about finally finishing university.", Spec0),
    expand_song_idea(Spec0, Spec1),
    dramatise_spec(Spec1, Spec),
    song_spec_to_music_composer(Spec, mc_spec(Fields)),
    member(form(_), Fields),
    member(instrumentation(_), Fields).

test(reference_inspiration_records_provenance) :-
    interpret_song_spec("Use the energetic build of [reference song] as inspiration.", Spec),
    find_inspiration(Spec, Inspirations),
    member(inspiration(source(sentence), feature(_), transformation(_)), Inspirations).

test(originality_flags_and_transformations) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project),
    field_value(Project, song, Song),
    originality_check(Song, [Song], Report),
    increase_originality(Song, Report, RevisedSong),
    Report = originality_report(_, [_|_], _),
    Song \= RevisedSong.

test(candidate_generation_creates_alternatives) :-
    interpret_song_spec("Happy guitar pop song with lyrics about finally finishing university.", Spec0),
    expand_song_idea(Spec0, Spec1),
    dramatise_spec(Spec1, Spec),
    generate_candidates(Spec, 3, Songs),
    Songs = [First, Second, Third],
    First \= Second,
    Second \= Third.

test(malformed_specification_fails_safely) :-
    \+ interpret_song_spec("", _).

test(project_can_save_and_reload) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project),
    export_song(Project, prolog, File),
    load_project(File, Loaded),
    Project = Loaded.

test(text_and_json_exports_exist) :-
    song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project),
    export_song(Project, json, JsonFile),
    export_song(Project, text, TextFile),
    exists_file(JsonFile),
    exists_file(TextFile).

test(acceptance_pairs_cover_all_categories) :-
    acceptance_pairs(Pairs),
    length(Pairs, 200),
    acceptance_category_count(initial_song_specifications, 40),
    acceptance_category_count(instrumental_specifications, 20),
    acceptance_category_count(lyric_based_specifications, 20),
    acceptance_category_count(unusual_metaphorical_specifications, 20),
    acceptance_category_count(editing_commands, 20),
    acceptance_category_count(add_lyrics_cases, 10),
    acceptance_category_count(remove_lyrics_cases, 10),
    acceptance_category_count(instrumentation_changes, 15),
    acceptance_category_count(structure_changes, 15),
    acceptance_category_count(inspiration_reference_cases, 10),
    acceptance_category_count(originality_check_cases, 10),
    acceptance_category_count(multi_turn_chatbot_cases, 10).

:- end_tests(song_writer).
