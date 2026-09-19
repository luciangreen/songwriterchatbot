:- module(song_originality, [
    originality_check/3,
    increase_originality/3
]).

:- use_module(song_model).

originality_check(Candidate, References, originality_report(Score, Flags, Recommendation)) :-
    candidate_signatures(Candidate, CandidateSignatures),
    findall(flag(Type, Signature),
        (member(Reference, References),
         candidate_signatures(Reference, ReferenceSignatures),
         member(Signature, CandidateSignatures),
         member(Signature, ReferenceSignatures),
         signature_type(Signature, Type)),
        Flags0),
    sort(Flags0, Flags),
    originality_score(Flags, Score, Recommendation).

increase_originality(song(Fields0), originality_report(_, [], _), song(Fields0)).
increase_originality(song(Fields0), originality_report(_, [_|_], _), song(Fields)) :-
    put_field(song(Fields0), hooks, [hook(melodic, motif([rise, skip, fall]), recurrence([chorus, final_chorus]), variation(fragment))], song(Fields1)),
    put_field(song(Fields1), harmony, progression([i, bvii, iv, vi]), song(Fields)).

candidate_signatures(Term, Signatures) :-
    (   field_value(Term, hooks, Hooks)
    ->  true
    ;   Hooks = []
    ),
    (   field_value(Term, harmony, Harmony)
    ->  true
    ;   Harmony = none
    ),
    append([Harmony], Hooks, Signatures).

signature_type(progression(_), harmony).
signature_type(hook(melodic, _, _, _), melodic_hook).
signature_type(hook(rhythmic, _, _, _), rhythmic_hook).
signature_type(_, mixed_feature).

originality_score([], strong, proceed).
originality_score([_], medium, review_and_transform).
originality_score(_, guarded, transform_before_export).
