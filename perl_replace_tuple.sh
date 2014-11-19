#!/bin/sh

# a perl script which can replace all occurences of
# a with b, b with c, c with d, d with e, e with f and finally f with g
# WITHOUT producing the common problem of ending up
# with everything replaced with g because
# a -> b -> c -> e -> f -> g

# to edit this, you need to provide the pattern/replacement tuples
# in the "subs" list

if test -z "$1"; then
  echo "you must provide a filename as an argument"
  exit 1
fi

filename=$1

perl -pe'
   BEGIN {
      %subs=qw( 
                a b
                b c
                c d
                d e
                e f
                f g
              );
      $re=join "|", map quotemeta, keys %subs;
      $re = qr/$re/;
   }
   s/($re)/$subs{$1}/g;
' $filename
