:- module(acceptance_pairs, [
    acceptance_pair/2,
    acceptance_pairs/1,
    acceptance_category_count/2
]).

acceptance_pair(Prompt, Expected) :-
    category_prompts(Category, Prompts),
    member(Prompt, Prompts),
    expected_output(Category, Prompt, Expected).

acceptance_pairs(Pairs) :-
    findall(q(Prompt, Expected), acceptance_pair(Prompt, Expected), Pairs).

acceptance_category_count(Category, Count) :-
    category_prompts(Category, Prompts),
    length(Prompts, Count).

expected_output(initial_song_specifications, Prompt, [
    command(initial_song),
    prompt(Prompt),
    complete_song(true),
    revision_history(enabled)
]).
expected_output(instrumental_specifications, Prompt, [
    command(initial_song),
    prompt(Prompt),
    lyrics(off),
    section_contrast(true)
]).
expected_output(lyric_based_specifications, Prompt, [
    command(initial_song),
    prompt(Prompt),
    lyrics(on),
    lyrics_sheet(required)
]).
expected_output(unusual_metaphorical_specifications, Prompt, [
    command(initial_song),
    prompt(Prompt),
    interesting_language(required),
    dramatic_arc(required)
]).
expected_output(editing_commands, Prompt, [
    command(edit_existing_project),
    prompt(Prompt),
    non_destructive_edit(true)
]).
expected_output(add_lyrics_cases, Prompt, [
    command(add_lyrics),
    prompt(Prompt),
    lyrics(on),
    preserve_music(true)
]).
expected_output(remove_lyrics_cases, Prompt, [
    command(remove_lyrics),
    prompt(Prompt),
    lyrics(off),
    preserve_music(true)
]).
expected_output(instrumentation_changes, Prompt, [
    command(change_instrumentation),
    prompt(Prompt),
    preserve_form(true)
]).
expected_output(structure_changes, Prompt, [
    command(change_structure),
    prompt(Prompt),
    localised_regeneration(true)
]).
expected_output(inspiration_reference_cases, Prompt, [
    command(inspiration_analysis),
    prompt(Prompt),
    provenance(required)
]).
expected_output(originality_check_cases, Prompt, [
    command(originality_check),
    prompt(Prompt),
    originality_report(required)
]).
expected_output(multi_turn_chatbot_cases, Prompt, [
    command(multi_turn_chat),
    prompt(Prompt),
    revision_history(enabled),
    context_preserved(true)
]).

category_prompts(initial_song_specifications, [
    "Write an exhilarating electronic pop song about seeing a city for the first time at night, instrumental except for a short chorus.",
    "A mysterious song about walking through Melbourne at 3 AM.",
    "Instrumental cinematic dance track where the orchestra gradually turns into a nightclub.",
    "Happy guitar pop song with lyrics about finally finishing university.",
    "Write an uplifting instrumental song that gradually becomes enormous.",
    "A dark electronic ballad about missing the last train home.",
    "Make a bright piano pop song about summer storms breaking.",
    "Create a slow-burning synth piece about neon rain on empty roads.",
    "Write a hopeful anthem about starting over after disaster.",
    "Produce a tense cinematic track for a city waking up too fast.",
    "Generate a shimmering electro-pop song about late trains and new chances.",
    "Compose a wistful guitar song about postcards never sent.",
    "Give me a dramatic instrumental about a bridge at sunrise.",
    "Make a spacious downtempo track about winter light through blinds.",
    "Write a stadium chorus song about finally being believed.",
    "Create an art-pop miniature about borrowed time.",
    "Compose a moody dance song about elevators and sleeplessness.",
    "Write a strange lullaby for a glowing apartment block.",
    "Build an upbeat indie pop track about exams ending at dawn.",
    "Create a cinematic instrumental with a huge final lift.",
    "Write a reflective song about leaving a familiar suburb forever.",
    "Make a glossy pop song about crowded trams and private victories.",
    "Compose a dark synthwave drive through a flooded city.",
    "Write a patient folk-pop song about waiting outside hospitals.",
    "Create a restrained instrumental that blooms into celebration.",
    "Make an elegant electronic piece about museum halls at night.",
    "Write a giant chorus song about the first warm day in spring.",
    "Compose a modern ballad about learning to trust again.",
    "Create a nervous dance-pop song about missing a phone call.",
    "Write an ecstatic night-drive anthem with only a tiny lyric hook.",
    "Make a gentle song about curtains opening after grief.",
    "Compose a tense instrumental about the airport before dawn.",
    "Write an optimistic synth-pop song about packing boxes.",
    "Create a shadowy pop track about losing track of time underground.",
    "Make a dreamy electronic song about reflected lights on the river.",
    "Write a widescreen climax song about choosing to stay.",
    "Compose a punchy chorus track about a final assignment submission.",
    "Create a sleek instrumental with rising pressure and release.",
    "Write a luminous pop song about meeting the morning train.",
    "Make a vulnerable nocturnal anthem about surviving the week."
]).

category_prompts(instrumental_specifications, [
    "Make this instrumental.",
    "Instrumental cinematic dance track where the orchestra gradually turns into a nightclub.",
    "Write an uplifting instrumental song that gradually becomes enormous.",
    "Create a purely instrumental night-drive song.",
    "No vocals, just a huge synth arc.",
    "Instrumental only with a suspenseful bridge.",
    "Keep it instrumental and minimal.",
    "Write an instrumental guitar pop theme.",
    "Generate a lyric-free club build.",
    "Remove vocals from the arrangement.",
    "Instrumental city-at-night soundtrack.",
    "Compose an instrumental for a first sunrise after heartbreak.",
    "Create a wordless chorus-focused EDM cue.",
    "Make the second version instrumental.",
    "Only instruments, no lyrics at all.",
    "Give me an orchestral instrumental with nightclub energy.",
    "Produce an ambient instrumental about empty escalators.",
    "Write a synth instrumental that peaks late.",
    "Make the whole thing instrumental except maybe atmosphere.",
    "An instrumental finale after a hard year."
]).

category_prompts(lyric_based_specifications, [
    "Write a song with lyrics about summer.",
    "Happy guitar pop song with lyrics about finally finishing university.",
    "Add words about finally getting home.",
    "Write lyrics for a mysterious tram-ride song.",
    "Create a chorus with a memorable title line.",
    "Generate a lyrical synth-pop ballad about reunion.",
    "Give me verses and a big chorus about relief.",
    "Write a song with lyrics about surviving exams.",
    "Need a heartbreak song with lyrics and imagery.",
    "Add lyrics about a city opening up at night.",
    "Create a lyric-led pop song about finishing the semester.",
    "Write words for an uplifting electronic track.",
    "Make the chorus lyrical and unforgettable.",
    "Build a full lyric sheet around the night skyline idea.",
    "Give the bridge a confessional lyric moment.",
    "Write lyrics that feel cinematic but singable.",
    "Need verses about waiting and a hopeful chorus.",
    "Create a hooky lyric for a first train home song.",
    "Write a refrain around neon and rain.",
    "Make this instrumental idea into a song with lyrics."
]).

category_prompts(unusual_metaphorical_specifications, [
    "A cold neon sunrise explodes over a sleeping city.",
    "The orchestra turns into a nightclub under the bridge.",
    "The sun comes through the curtains after the worst night of someone's life.",
    "Write a song where streetlights learn to breathe.",
    "Compose a chorus like broken glass turning into water.",
    "Build an instrumental where elevators bloom like flowers.",
    "Make a dance song about gravity forgetting us.",
    "Write a track where the station platform glows like mercy.",
    "Create a pop song where thunder becomes confetti.",
    "Compose a mysterious anthem about a silver hallway swallowing echoes.",
    "Write a chorus where the skyline exhales.",
    "Make the bridge feel like ash turning into gold.",
    "Create a song about winter opening like a curtain.",
    "Write a cinematic build where signals become birds.",
    "Compose a nocturnal pop idea about mirrors catching weather.",
    "Make the intro feel like blue static becoming dawn.",
    "Write a song where the river speaks in fluorescent vowels.",
    "Turn panic into a glass elevator of light.",
    "Create a track where the bassline walks on wet concrete moons.",
    "Make the ending feel like rust learning to sing."
]).

category_prompts(editing_commands, [
    "Make the chorus bigger.",
    "Remove the lyrics.",
    "Change the second verse into an instrumental section.",
    "Make this sound more futuristic without changing the melody.",
    "Give the bass more movement.",
    "Add strings.",
    "More energetic.",
    "Less busy.",
    "Change chorus.",
    "Change melody.",
    "Change chords.",
    "Make it darker.",
    "Regenerate.",
    "Make another version.",
    "Undo.",
    "Redo.",
    "Compare versions.",
    "Show inspiration.",
    "Check originality.",
    "Export MIDI."
]).

category_prompts(add_lyrics_cases, [
    "Add lyrics to this instrumental.",
    "Turn the instrumental into a lyric song.",
    "Give the chorus words.",
    "Add verses and chorus lyrics.",
    "Write lyrics for version two.",
    "Make this arrangement singable with words.",
    "Add a short lyric hook only.",
    "Create a full lyric sheet for the existing song.",
    "Put lyrics back in.",
    "Add words without changing the music."
]).

category_prompts(remove_lyrics_cases, [
    "Make this instrumental.",
    "Keep the music but remove the lyrics.",
    "Strip the vocals out conceptually.",
    "Delete the lyrics but preserve the arrangement.",
    "Turn this into an instrumental mix.",
    "Mute the words and keep the harmony.",
    "No lyrics on the next pass.",
    "Remove the chorus words.",
    "Take out all lyrics.",
    "Convert this lyric song into instrumental form."
]).

category_prompts(instrumentation_changes, [
    "Replace the piano with strings.",
    "Add strings.",
    "Swap guitar for synths.",
    "Bring the orchestra forward.",
    "Make the drums hit harder.",
    "Remove the pads.",
    "Add a lead synth to the chorus.",
    "Give the bass more movement.",
    "Turn the bridge into just piano and voice.",
    "Use brass instead of pads in the climax.",
    "Make the intro only piano and sub bass.",
    "Change the percussion to club drums.",
    "Add arpeggiators behind the final chorus.",
    "Replace the strings with a choir pad.",
    "Give the outro a solo guitar line."
]).

category_prompts(structure_changes, [
    "Make the chorus bigger.",
    "Change the second verse into an instrumental section.",
    "Add a breakdown before the final chorus.",
    "Shorten the intro.",
    "Repeat this riff during the outro.",
    "Add a bridge after chorus two.",
    "Turn the pre-chorus into a pause.",
    "Move the climax later.",
    "Double the final chorus.",
    "Cut verse two in half.",
    "Start with the hook.",
    "Add a cold open intro.",
    "Make the ending more abrupt.",
    "Insert a silence before the climax.",
    "Make the song through-composed instead of verse-chorus."
]).

category_prompts(inspiration_reference_cases, [
    "Use the energetic build of my previous song as inspiration.",
    "Use the energetic build of [reference song] as inspiration.",
    "Borrow the atmosphere of my library's late-night tracks.",
    "Reference a cinematic dance cue without copying it.",
    "Show inspiration provenance for the current draft.",
    "Find inspiration from my existing forms but transform them.",
    "Use the strings from a reference track only as high-level inspiration.",
    "Make the chorus feel informed by a club classic without imitation.",
    "Analyse my library for recurring arrangement strategies.",
    "Explain which parts came from the prompt versus inspiration."
]).

category_prompts(originality_check_cases, [
    "Check originality.",
    "Run a similarity review against my references.",
    "See if the hook is too close to the reference.",
    "Increase originality if needed.",
    "Review this chorus for excessive similarity.",
    "Compare this draft with the user library patterns.",
    "Transform any suspicious melodic overlap.",
    "Check originality before export.",
    "Find suspicious rhythm matches.",
    "Report whether the current hook needs mutation."
]).

category_prompts(multi_turn_chatbot_cases, [
    "New song: mysterious Melbourne 3 AM.",
    "Then make the chorus bigger.",
    "Then add strings.",
    "Then remove the lyrics.",
    "Then add lyrics back.",
    "Start a new song about graduation relief.",
    "Now make it darker.",
    "Undo that change.",
    "Redo it and give the bass more movement.",
    "Export the current project as JSON."
]).

