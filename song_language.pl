:- module(song_language, [
    interesting_language/2
]).

interesting_language(Sentence, Features) :-
    text_string(Sentence, Text),
    string_lower(Text, Lower),
    feature_matches(Lower, Matches),
    include(non_empty_feature, Matches, Features).

feature_matches(Text, [
    feature(metaphor, Metaphor),
    feature(imagery, Imagery),
    feature(movement, Movement),
    feature(spatial_concept, Spatial),
    feature(colour, Colour),
    feature(temperature, Temperature),
    feature(scale, Scale),
    feature(speed, Speed),
    feature(tension, Tension),
    feature(contradiction, Contradiction),
    feature(transformation, Transformation),
    feature(emotional_language, Emotional),
    feature(narrative_event, Narrative),
    feature(unusual_verb, Verb),
    feature(sonic_word, Sonic),
    feature(temporal_progression, Temporal)
]) :-
    matched_keywords(Text, [" like ", " as if ", " turns into ", " becomes "], Metaphor),
    matched_keywords(Text, ["neon", "curtains", "city", "night", "sunrise", "shadow", "street", "glitter"], Imagery),
    matched_keywords(Text, ["walking", "driving", "approaches", "explode", "explode", "gradually", "rush", "turns"], Movement),
    matched_keywords(Text, ["through", "over", "under", "inside", "outside", "across"], Spatial),
    matched_keywords(Text, ["red", "blue", "gold", "silver", "neon"], Colour),
    matched_keywords(Text, ["cold", "warm", "hot", "icy", "burning"], Temperature),
    matched_keywords(Text, ["enormous", "tiny", "huge", "vast"], Scale),
    matched_keywords(Text, ["fast", "slow", "rush", "sprint"], Speed),
    matched_keywords(Text, ["mysterious", "dark", "worst", "tension", "anxious"], Tension),
    matched_keywords(Text, ["but", "except", "although", "yet"], Contradiction),
    matched_keywords(Text, ["turns into", "becomes", "transforms", "gradually"], Transformation),
    matched_keywords(Text, ["happy", "sad", "uplifting", "melancholic", "exhilarating", "mysterious"], Emotional),
    matched_keywords(Text, ["finally", "first time", "after", "before", "arrives", "approaches"], Narrative),
    matched_keywords(Text, ["explodes", "drifts", "glows", "shivers"], Verb),
    matched_keywords(Text, ["echo", "signal", "pulse", "thunder", "whisper"], Sonic),
    matched_keywords(Text, ["gradually", "after", "before", "first time", "at night", "3 am"], Temporal).

matched_keywords(Text, Keywords, Matches) :-
    findall(Keyword, (member(Keyword, Keywords), sub_string(Text, _, _, _, Keyword)), Matches0),
    sort(Matches0, Matches).

non_empty_feature(feature(_, Matches)) :-
    Matches \= [].

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).

