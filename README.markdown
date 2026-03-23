Sometimes you just want to make a quick FASTQ file for testing.

Usage:

1. Write your FASTQ spec in a `foo.lisp` file (see below for the syntax).
2. `quick-fastq foo.lisp` (or `cat foo.lisp | quick-fastq` if you prefer) to dump a random FASTQ on stdout.

## Syntax

`quick-fastq` will read two Common Lisp forms from stdin (using the standard
reader for now, so don't run it on untrusted data).  The format of the input is:

    bindings
    expr

`expr` is an expression describing how to generate a random read.

* A literal string like `"ATCG"` generates those bases with random quality scores.
* An integer like `123` generates that many random bases with random quality scores.
* A vector like `#(expr1 expr2 …)` evaluates each expression and concatenates the results.
* A symbol like `x` looks up the value in the bindings (see below).
* A list performs some operation on the form inside, depending on the symbol at
  the head of the list:
  * `(qN expr)` where `N` is 0-90 evaluates `expr` and sets its quality scores to `N`, e.g. `(q12 500)` will generate 500
  random bases with a qscore of `12`.
  * `(rev expr)` reverses `expr` (you can also use `(r expr)` as a shortcut).
  * `(comp expr)` complements `expr` (you can also use `(c expr)` as a shortcut).
  * `(revcomp expr)` is equivalent to `(rev (comp expr))` (you can also use `(rc expr)` as a shortcut)
  * `(first n expr)` takes the first `n` bases of `expr` (you can also use `(f n expr)` as a shortcut).
  * `(last n expr)` takes the last `n` bases of `expr` (you can also use `(l n expr)` as a shortcut).
  * `(rep n expr)` concatenates `n` copies of `expr` (you can also use `(tr n expr)` as a shortcut).
  * `(snp freq expr)` modifies `expr` to add SNPs at a rate of `freq` (`freq` must be between 0 and 1).
  * `(ins freq expr)` modifies `expr` to insert bases at a rate of `freq` (`freq` must be between 0 and 1).
  * `(del freq expr)` modifies `expr` to delete bases at a rate of `freq` (`freq` must be between 0 and 1).
  * `(err freq expr)` is equivalent to `(ins freq (del freq (snp freq expr)))` (`freq` must be between 0 and 1).

Bindings must be a (possibly empty) list of bindings, each of the form `(symbol
expr)`.  `expr` will be evaluated and bound to `symbol`.  Bindings are performed
in order as if by `let*`.  Several keyword symbols have special meanings:

* Binding `:entries` to an integer `n` will generate that many FASTQ entries instead of just a single one.
* Binding `:seed` to an integer will seed the RNG with a specific seed, to make runs reproducible.

## Examples

Generate a random 1000bp read:

    ()
    1000

Generate a read with the same 100bp beginning and end, with 500bp of random
bases in the middle:

    ((x 100))
    #(x 500 x)

Generate a gapped foldback chimeric read, with the second half having a lower
quality than the first:

    ((x (q40 1000))
     (f (q20 (revcomp x))))
    #(x 25 f)

Generate a read with a tandem repeat in the middle:

    ()
    (1000 (rep 200 "ATTT") 1000)

Generate a foldback chimeric read with a double tandem duplication in the
foldback strand, with simulated sequencing error, and small chunks of
low-quality bases to make the transitions between sections as a hack:

    ((x 1000)
     (lq (q1 10))
     (a (first 800 x))
     (b (last 200 x))
     (dup (last 150 a))
     (f (revcomp #(lq a lq dup lq (rc dup) lq dup lq b))))

    (err 0.01 #(x f))
