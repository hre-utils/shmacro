#!/usr/bin/awk -f
#
# Starting to draft out a really simple line-wise macro

BEGIN {
   false = 0
   true  = 1

   delete M_DUPE[0]
   delete MACROS[0]

   buffer_open = false
   buffer      = ""
   current     = ""
}


function push(arr, val,   i) {
   for (i=0 ;; ++i) {
      if (! arr[i]) {
         arr[i]=val
         break
      }
   }
}


function cat(left, right) {
   if (left) {
      left = left "\n" right
   } else {
      left = right
   }
   return left
}


function shift(   name) {
   name = $1
   sub(/^[[:space:]]*[^[:space:]]*[[:space:]]*/, "")
   return name
}


function non_comment () {
   print "empty line  ? "  match($0, /\s*$/)
   print "non-comment ? "  !match($0, /\s*#/)
   print "either/or   ? "  (match($0, /\s*$/) || !match($0, /\s*#/))
   return (match($0, /\s*$/) || !match($0, /\s*#/))
}


function handle_args() {
   arg()
   while (match($0, /^\s*,\s*/)) {
      arg()
   }
}


function arg(   name) {
   name = shift()
   push(MACROS[current]["args"], name)
}


/^\s*#\s*macro\s+/ {
   sub(/^\s*#\s*macro\s+/, "")
   buffer_open = true

   current = shift()
   sub(/\s*/, "")

   if (M_DUPE[current]) {
      print "==> ERROR: macro already defined: "  current  "." > "/dev/stderr"
   } else {
      M_DUPE[current] = true
   }

   handle_args()
   next
}


/^\s*#\s*endmacro\s*/ {
   sub(/\s^#\s*endmacro\s*/, "")
   buffer_open = false
   next
}


buffer_open && /^\s*#\s*/ {
   sub(/^\s*#/, "")
   push(MACROS[current]["lines"], $0)
   next
}


buffer_open && non_comment() {
   print "==> ERROR: un-terminated macro definition.\n" > "/dev/stderr"
   exit 1
}



END {
   for (m in MACROS) {
      printf "MACRO: "  m  ":: "
      for (i in MACROS[m]["args"]) {
         print MACROS[m]["args"][i] ","
      }
      for (i in MACROS[m]["lines"]) {
         print MACROS[m]["lines"][i] ","
      }
      printf "\n"
   }
}
