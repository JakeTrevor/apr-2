#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

#show raw.where(lang: "lean"): it => {
  show "<=": $<=$
  show "->": $->$
  it
}

#show math.equation: it => {
  show "[": math.bracket.l.stroked
  show "]": math.bracket.r.stroked
  it
}



= APR Presentation 2

== Structure of this presentation

1. Miscellany
2. Quantum PL survey paper
3. A quick look at my current work


== Extra curricular activities

This year I have:
- Worked on the SoCS student project allocation and marking system
- Tutored for
  - Functional Programming
  - Quantum Computing
  - CS1S
- I've given two guest lectures
  - One filling in for Simon in the QC course
  - One invited lecture on React for Nikela's Internet Technologies course

== Distractions

I gave a PLUG talk on formalising package managers with lenses

- I find this topic really interesting!
- Unfortunately, it's not relevant to my PhD

I do hope to finish off this work and perhaps get it published...

#pause

...but not at the expense of my actual research



== Survey paper

- In my last APR, the main piece of work I had been working on was a survey of quantum
  programming languages

- Submitted to ACM TQC in around February/March

- Rejected at the start of June

  #quote[it is not clear that the required revisions could be completed in a fixed
    timeframe.]

- Journal would be open to a resubmission _if_ revisions are done

== Survey paper

In total, 17 pages of feedback

Key Problems:
- Choose better example programs
- Pseudocode is vaguely defined
- Need to cover more languages

But:
- Lattice is recognised as novel
- The basics of the paper seem to be OK
- Writing was good

#centered-slide[
  #text(size: 40pt)[Aim: Revise and resubmit by October]
]

= What am I working on now?

== What am I working on now?

- at the last APR, I wanted to construct a modular semantics for hybrid QPLs

- I have started work on this in lean4

- A lot of time spent on basic quantum information theory

  - e.g. the stuff from section 2 of the report

- required to give a semantics to anything quantum

== What am I working on now?
Big milestone just last week:

- _Unitary_ and _Circuit_ languages both fully mechanised

- We can chat about what that means after the presentation if needed

== What's next?

There are two big avenues to chase down

1. Continue this work on more expressive languages

2. Look into using this framework to write a verified optimiser.


== Capturing more expressive languages

The big challenge here is that the style of the semantics needs to change:

- For _Cond,_ we need to track classical data
  - To handle this gracefully, I want to move away from a density operator presentation to
    one based on ensemble states

---

- For _Loop,_ the semantics can no longer be denotational
  - Since we don't know how to tackle qubit allocation in a loop
  - As far as I know, this is a big open question.


- In fact, for Loop, we will need to formalise the semantics as a relation


- The upside: _QCond_ and _QLoop_ should be relatively trivial extensions, since they just
  allow recorded measurement.

== Verified optimisation

- Verify optimisation on smaller languages where it's easy

- Provide an embedding function that lets us _lift_ these to larger languages.

A bit hard to say what this will look like without more work on higher expressiveness
languages...

== What do I have right now?

Consider the following program:

#align(center)[

  ```
  X 1; X 1
  ```
]

This is equivalent to:

#align(center)[
  ```
  // ...
  ```
]

i.e. the _empty program_

==

Here, we have a concrete equivalence

Checking the equivalence is easy
- these are programs in _Unitary_
- so we can compute their denotations and compare them

But it's an instance of a general pattern e.g.

#align(center)[
  ```
  forall i, {X i; X i} = {}
  ```
]

We might call this `X`-involutive

== What we want: Generalisation from Example (GfE)

- Proving concrete equivalences is easy

- We need general patterns for rewriting

We want to generate the general rule from the concrete example

$->$ can we _generalise from an example_?

Spoiler: Yes!

== Formal statement: Generalisation from Example

#quote[
  If I have evidence that $P$ and $Q$ agree in one context, I know they agree in every
  context
]

$
  forall (k : NN) quad (P, Q : "ProgCons" k), \
  exists (x : "ctx" k), [ P x ] = [ Q x] ->
  forall (x' : "ctx" k), [P x'] = [Q x']
$

== Definitions:


A program $P$ in unitary is given by:

```lean
inductive Command : (q : ℕ) -> Type where
  | Done : Command q
  | App : (h_size : n <= q) ->  Gate n -> PartialPerm n q -> Command q -> Command q
```

- `q` is the _bit width_ of the circuit
- qubits are referred to by index
  - as the targets of gates - that `PartialPerm` thing
  - a qubit index in a `Command q` is just a `Fin q`

---

A _context_ on $k$ variables is just a permutation, i.e. $"Fin" n -> "Fin" n$

$
  "ctx" k := "Fin" k -> "Fin" k
$

We can apply a context $x$ to a program by substituting each variable reference $i$ with
$x(i)$

The function that does this recursively over a command is $"subst"$

$
  "subst" : "Command" k -> "ctx" k -> "Command" k
$

---

We refer to the partial application of $"subst"$ to a program as a _program constructor_


$
  "ProgCons" k := "ctx" k -> "Command" k
$

It's a function from a context to a program
== Now, this definition should make more sense:


#quote[
  If I have evidence that $P$ and $Q$ agree in one context, I know they agree in every
  context
]

$
  forall (k : NN) quad (P, Q : "ProgCons" k), \
  exists (x : "ctx" k), [ P x ] = [ Q x] ->
  forall (x' : "ctx" k), [P x'] = [Q x']
$

- If we have a pair of concrete program $X, Y$
- This corresponds to the program constructors $"subst" X, "subst" Y$
- If $[X] = [Y]$, this corresponds to the context $x= "ID"$, where
  $["subst" X "ID"] = ["subst" Y "ID"]$

==
Proving this implication gives us our generalisation rule


It is true due to the fact that we are really working in an SMC

However, it's not necessarily clear how to apply the symmetry to get this to work.

== Proof Sketch

Observe that

$
  forall (x , x' : "ctx" k), quad
  exists (pi : #h(0.25em) dots.h.c),\
  forall (P : "ProgCons" k),
  [P x] = [pi P x']
$

$ pi = lambda p. "subst" p #h(0.25em) (x compose x'^(-1)) $

Therefore, require to prove:

$
  forall (k : NN) quad (P, Q : "ProgCons" k), \
  exists (x : "ctx" k), [ P x ] = [ Q x] ->
  [pi P x] = [pi Q x]
$


==

$pi$ is a _semantic equivalence preserving_ transformation

$
  "sep" F := [F P] = [F Q] <-> [P] = [Q]
$

Therefore require to prove:

$
  forall (k : NN) quad (P, Q : "ProgCons" k), \
  exists (x : "ctx" k), [ P x ] = [ Q x] ->
  [P x] = [Q x]
$

Which is now trivial

==

As presented, there are quite a few holes in this sketch

I'm quite confident that they can all be filled and formalised nicely

== Size Embedding

- Generalisation from Example gives us a general rule on programs of a fixed size...

#pause

- But such rules actually apply to programs of any size.

What does that look like?

==

Using GfE, we can get proofs in the form:


$
  forall (x : "ctx" k), [P x] = [Q x]
$

But the variant of the rule we want looks like:

$
  forall (k' : NN), k' >= k -> forall (x : "ctx" k'), [P x] = [Q x]
$

Note that the rule is now polymorphic over some $k'$

==

To make this work in general, we just need to prove:

$
  forall (x : "ctx" k), [P x] = [Q x] ->\
  forall (k' : NN), k' >= k -> forall (x' : "ctx" k'), [P x'] = [Q x']
$

== The basic idea

#quote[
  If we fill the holes in the program with variables ranging over $k'$ options, it's the
  same as filling them with variables over $k < k'$ options and performing a suitable
  permutation
]

$
  forall (x':"ctx" k') #h(0.25em) (a : "ctx" k) #h(0.25em)
  exists (pi : dots.h.c),\
  P x' = pi (arrow.t P a)
$



$arrow.t$ is the _embedding function_ that takes a program in $k$ to a program in $k+n$
for some $n$

==

It is therefore sufficient to prove:

$
  forall (a : "ctx" k), [pi (arrow.t P a)] = [pi (arrow.t Q a)]
$

and $pi$ and $arrow.t$ are both $"sep"$, so it's sufficient to prove:

$
  forall (a : "ctx" k), [P a] = [Q a]
$

Which is true by assumption

==
Again, there are some big holes here.

Not everything I've presented here typechecks e.g.

$
  (P : "ProgCons" k), (x' : "ctx" k')\
  P x'
$

Requires us to really first construct something like:

$
  P' := "subst" (arrow.t X)
$

Or to generalise $"subst"$ to be parametric over the size of the context in some way

== Remaining Challenges

The following program can be optimised by `X`-involutive
```
X 1; Z 2; X 1
```

However, the `Z` in the middle inhibits the application of the rewrite rule.

We can solve this by somehow putting the program into normal form

But the problem will re-emerge at _loop_

In real life, this is solved by converting the program to a DAG representation which
eliminates the symmetries

==

It would be nice to think about how to verify a DAG representation of programs

open questions:

1. what does a DAG representation for hybrid programs look like?
2. How do we generate _summary information_ (i.e. data-flow facts) about this DAG form?


If possible, I'd like to answer these questions during the remainder of my PhD
