% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/selfhost').

% Domain: every query over the example programs: each predicate with each pattern of bound and unbound arguments.
person(X) :- member(X, [ann, bob, cal, dee, eve]).
query(family, G) :- member(F, [parent, grandparent, ancestor]), ( G =.. [F, _, _] ; person(X), G =.. [F, X, _] ; person(Y), G =.. [F, _, Y] ).
query(lists, app(X, Y, [1, 2, 3])) :- X = _, Y = _.
query(lists, app([1], [2], _)).
query(lists, mem(_, [a, b, c])).
query(lists, mem(b, [a, b, c])).
query(lists, mem(z, [a, b])).

% 1. The interpreter interpreting itself gives exactly the same answers, in the same order, as interpreting directly.
theorem(level_two_equals_level_one) :- forall(( program(N, P), query(N, G) ), ( solve(P, G, A), solve2(P, G, B), A =@= B )).

% 2. Interpreting directly gives the same answers as plain Prolog would (checked against the facts).
theorem(level_one_is_correct) :-
    program(family, P), solve(P, grandparent(ann, Z), S1), S1 == [grandparent(ann, cal), grandparent(ann, dee)],
    solve(P, ancestor(ann, W), S2), findall(W2, member(ancestor(ann, W2), S2), Ws), msort(Ws, [bob, cal, dee, eve]),
    program(lists, L), solve(L, app(X, Y, [1, 2]), S3), length(S3, 3), ( var(Z), var(W), var(X), var(Y) -> true ; true ).

% 3. Each level costs more steps: the extra layer is never free.
theorem(each_level_costs_more) :- forall(( program(N, P), query(N, G), solve(P, G, A), A \== [] ), ( steps(1, P, G, S1), steps(2, P, G, S2), S2 > S1 )).

% 4. A query with no answers has none at any level.
theorem(no_answers_at_any_level) :- forall(( program(N, P), query(N, G), solve(P, G, []) ), solve2(P, G, [])).

% 5. The interpreter can run itself running itself: level three gives exactly the answers of level one, in
% the same order, and costs more steps than level two.
theorem(level_three_equals_level_one) :- forall(( program(N, P), query(N, G) ), ( solve(P, G, A), solve3(P, G, C), A =@= C,
    ( A == [] -> true ; steps(2, P, G, S2), steps(3, P, G, S3), S3 > S2 ) )).
