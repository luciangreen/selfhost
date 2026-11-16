# selfhost

an interpreter written in the language it interprets, run on itself. The interpreter's own clauses are data it can run, so it can interpret a program directly, or interpret itself interpreting the program, and so on: each level gives the same answers, as a self-hosted Detlog must. Steps are counted at each level, showing what each layer costs. Programs are lists of (Head :- Body) clauses.

## Use

```prolog
?- use_module(prolog/selfhost).
?- program(family, P), solve(P, grandparent(ann, X), Sols).         % direct
?- program(family, P), solve2(P, grandparent(ann, X), Sols).        % the interpreter interpreting itself
?- program(family, P), steps(1, P, grandparent(ann, _), S1), steps(2, P, grandparent(ann, _), S2).   % S2 > S1
```

## Proofs

`proofs/theorems.pl` proves 4 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every query over the example programs: each predicate with each pattern of bound and unbound arguments.

1. The interpreter interpreting itself gives exactly the same answers, in the same order, as interpreting directly.
2. Interpreting directly gives the same answers as plain Prolog would (checked against the facts).
3. Each level costs more steps: the extra layer is never free.
4. A query with no answers has none at any level.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
