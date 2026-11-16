% selfhost: an interpreter written in the language it interprets, run on itself. The
% interpreter's own clauses are data it can run, so it can interpret a program directly, or
% interpret itself interpreting the program, and so on: each level gives the same answers, as
% a self-hosted Detlog must. Steps are counted at each level, showing what each layer costs.
% Programs are lists of (Head :- Body) clauses.
%?- program(family, P), solve(P, grandparent(ann, X), Sols).         % direct
%?- program(family, P), solve2(P, grandparent(ann, X), Sols).        % the interpreter interpreting itself
%?- program(family, P), steps(1, P, grandparent(ann, _), S1), steps(2, P, grandparent(ann, _), S2).   % S2 > S1
:- module(selfhost, [program/2, interpreter/1, solve/3, solve2/3, solve_level/4, steps/4]).
:- use_module(library(lists)).
:- use_module(library(apply)).

program(family, [ (parent(ann, bob) :- true), (parent(bob, cal) :- true), (parent(bob, dee) :- true), (parent(dee, eve) :- true),
                  (grandparent(X, Z) :- parent(X, Y), parent(Y, Z)),
                  (ancestor(X, Y) :- parent(X, Y)), (ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z)) ]).
program(lists, [ (app([], L, L) :- true), (app([H|T], L, [H|R]) :- app(T, L, R)),
                 (mem(X, [X|_]) :- true), (mem(X, [_|T]) :- mem(X, T)) ]).

% The interpreter as data: prove(Program, Goal) for conjunctions, true, and clause lookup
% (each clause is copied before use, so its variables are fresh, as Prolog does).
interpreter([ (prove(_, true) :- true),
              (prove(P, (A, B)) :- prove(P, A), prove(P, B)),
              (prove(P, G) :- is_goal(G), pick(P, C), copy_term(C, (G :- B)), prove(P, B)),
              (pick([C|_], C) :- true),
              (pick([_|Cs], C) :- pick(Cs, C)) ]).

% Level 1: Prolog runs the interpreter's logic directly (this is the host).
host(_, true, S, S) :- !.
host(P, (A, B), S0, S) :- !, host(P, A, S0, S1), host(P, B, S1, S).
host(_, is_goal(G), S0, S) :- !, G \= true, G \= (_, _), S is S0 + 1.
host(_, copy_term(A, B), S0, S) :- !, copy_term(A, B), S is S0 + 1.
host(P, G, S0, S) :- member(C, P), copy_term(C, (H :- B)), H = G, S1 is S0 + 1, host(P, B, S1, S).

% solve_level(+Level, +Program, +Goal, -Steps): Level 1 interprets the program; level 2 interprets
% the interpreter running the program (prove/2 is just another goal for the host).
solve_level(1, P, G, S) :- host(P, G, 0, S).
solve_level(2, P, G, S) :- interpreter(I), host(I, prove(P, G), 0, S).

solve(P, G, Sols) :- findall(G, solve_level(1, P, G, _), Sols).
solve2(P, G, Sols) :- findall(G, solve_level(2, P, G, _), Sols).
steps(L, P, G, S) :- aggregate_all(sum(K), solve_level(L, P, G, K), S).
