:- module(song_model, [
    field_value/3,
    put_field/4,
    remove_field/3,
    container_fields/2,
    slugify/2
]).

:- use_module(library(lists)).

container_fields(Container, Fields) :-
    Container =.. [_Name, Fields].

field_value(Container, FieldName, Value) :-
    container_fields(Container, Fields),
    member(Term, Fields),
    compound(Term),
    Term =.. [FieldName, Value].

put_field(Container0, FieldName, Value, Container) :-
    container_fields(Container0, Fields0),
    exclude(has_field_name(FieldName), Fields0, Remaining),
    NewTerm =.. [FieldName, Value],
    Container0 =.. [Functor, _],
    Container =.. [Functor, [NewTerm|Remaining]].

remove_field(Container0, FieldName, Container) :-
    container_fields(Container0, Fields0),
    exclude(has_field_name(FieldName), Fields0, Remaining),
    Container0 =.. [Functor, _],
    Container =.. [Functor, Remaining].

has_field_name(Name, Term) :-
    compound(Term),
    Term =.. [Name|_].

slugify(Text, Slug) :-
    text_string(Text, String),
    string_lower(String, Lower),
    split_string(Lower, " ", ".,!?;:'\"()[]{}", Parts0),
    exclude(=(""), Parts0, Parts),
    atomic_list_concat(Parts, '-', Atom),
    atom_string(Atom, Slug).

text_string(Text, String) :-
    string(Text),
    !,
    String = Text.
text_string(Text, String) :-
    atom_string(Text, String).

