:- module(cases, [title/1, case/3]).
:- use_module('../prolog/selfhost').
:- use_module(engine).
title('selfhost').
person_g(X) :- rnd_pick([ann, bob, cal, dee, eve, fay], X).
q_g(family, G) :- rnd_pick([parent, grandparent, ancestor], F), person_g(X), person_g(Y), rnd_pick([[X, _], [_, Y], [X, Y]], As), G =.. [F|As].
q_g(lists, G) :- rnd_int(0, 3, N), numlist(1, 3, L0), length(L, N), append(L, _, L0), rnd_pick([app(_, _, L), mem(_, L), mem(2, L)], G).
case(solve, [Prog, G], solve) :- rnd_pick([family, lists], Pn), program(Pn, Prog), q_g(Pn, G).
case(solve2, [Prog, G], solve2) :- rnd_pick([family, lists], Pn), program(Pn, Prog), q_g(Pn, G).
case(steps, [L, Prog, G], steps) :- rnd_int(1, 2, L), rnd_pick([family, lists], Pn), program(Pn, Prog), q_g(Pn, G).
