#!/usr/bin/awk -f
#
# A super simplified approach, only adding a dot syntax for easier accessing
# array elements.

BEGIN {
}

match($0, /\$\{[[:alpha:]_][[:alnum:]_]*(\.[[:alpha:]_][[:alnum:]_]*)+\}/) {
   text = substr($0, RSTART, RLENGTH)
   sub(/^\$\{/, "", text) ; sub(/\}$/, "", text)
   split(text, words, ".")

   print "declare -n __=\"${"  words[1]  "}"

   len = 0
   for (w in words) len = len + 1

   for (idx=2; idx<len; ++idx) {
      print "declare -n __=\"${__["  words[idx]  "]}"
   }

   repl = "${__["  words[len]  "]}"

   sub(/\$\{[[:alpha:]_][[:alnum:]_]*(\.[[:alpha:]_][[:alnum:]_]*)+\}/, repl)
   print $0
}
