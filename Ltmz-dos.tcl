# Ltmz
# MS-DOS Text Adventure Compiler, version 5.0
# August 2025
# by Lukas Petru

# Licensed under the MIT License (Expat)

array set code {
 ldv a1      ldc b8     byv {8b 1e} byc bb
 st a3       ex 93      exdx 92 inter {cd 21}
 ret c3      call e8    jp e9 jpmde {ff 27}
 jpbe {76 3} jpa {77 3} add {1 d8} sbc {19 d8}
 jpc {72 3}  jpnc {73 3} jpz {74 3} jpnz {75 3}
 inc 40      dec 48     pop 58 push 50
 ldax_m {8b 07} ld_em {8a 1f b7 0} sub {29 d8}
}
proc asmsrc s {
 foreach {x r} {
  == {sub jpz}
  != {sub jpnz}
  >= {sub jpnc}
  <= {sub jpbe}
  <  {sub jpc}
  >  {sub jpa}
  { ld (\d)} { ldc \1}
  { ld } { ldv }
  { by (\d)} { byc \1}
  { by } { byv }

  { jp[bn]?\w } {\0jp }
  { (call|jp) } {\0$}
 } {regsub -all $x $s $r s}
 set s
}
set org 256
proc lb s {set ::a($s) [expr {$::org+[llength $::b]}]}
proc db s {foreach y $::code($s) {lappend ::b 0x$y}}
proc dv v {lappend ::b [expr $v&255] [expr $v>>8]}
proc dw {s o} {dv [expr {$::phase?$::a($s:)-$o:0}]}
proc dt s {
 binary scan \r$::($s) cu* c
 lappend ::b {*}[lrange $c 1 end-1] [expr {128+[lindex $c end]}]
}
proc asmeval s {
 foreach x $s {switch -glob $x {
   *: {lb $x} [a-z]* {db $x} [0-9]* {dv $x} %* {dt $x}
   $* {dw [scan $x $%s] [expr {2+[lb H]}]} * {dw $x 0}}
 }
}
proc assemble s {
 set s [asmsrc $s];set ::phase 0;set ::b "";set ::a(Boot:) 0
 asmeval $s;incr ::phase;set ::b ""
 asmeval $s
 puts "([array size ::v] v) [llength $::b] B"
 puts -nonewline [open [lindex $::argv 1] wb] [binary format c* $::b]
}
proc n s {expr {[scan $s %d d]?$s&65535:$s}}
proc END "" {lappend ::b F$::fc:;incr ::fc}
proc GOSUB n {lappend ::b call K$n}
proc GOTO n {lappend ::b jp K$n}
proc IF {a o b} {lappend ::b "ld [n $a] by [n $b] $o F$::fc"}
proc INIT args {
 lmap {x y} $args {append n $x;lappend w $y
  lappend c ex ldax_m st $x ex inc inc}
 lappend ::b "call I$n $w";set ::v(I$n:) "pop $c push ret"}
proc INPUT "" {lappend ::b call Input}
proc K n {lappend ::b K$n:}
proc LET {a e b "o 0" "c 0"} {
 lappend ::b "ld [n $b][
  expr {$c==0?"":$o=="+"?" by [n $c] add":" by [n $c] sub"}] st $a"}
proc MATCH {a s} {
 lappend ::b "call Match $s ex st $a"}
proc NEXT "" {lappend ::b N$::nc:;incr ::nc}
proc ON {a g args} {
 lappend ::b "ld [n $a] call [join Ongoto\ $args \ K] 0"}
proc PRINS s {lappend ::b "call Prins $s"}
proc PRINT s {lappend ::b "call Print $s"}
proc RETURN "" {lappend ::b ret}
proc SKIP "" {lappend ::b jp N$::nc}
proc SYSTEM "" {lappend ::b jp Boot}
# :: -strings, ::a -addresses, ::v -variables and struct
proc compile s {
 foreach {_ x} [regexp -all -inline {"(.*?)"} $s] {
  regsub {".*?"} $s \ %[incr i] s;set ::(%$i) [regsub -all \n $x \r\n]
 }
 regsub -all -line REM.* $s "" s
 regsub -all {[A-Z!=<>]+} $s " & " s
 regsub -all { THEN } $s ":" s
 regsub -all { AND } $s ":IF " s
 regsub -all {\s*[\n:][\s:]*} $s \; s
 regsub -all {,?(-|%)?\s*([\da-z]+)} $s { \1\2} s
 regsub -all {([\da-z]+)\s*([+-])} $s {\1 \2 } s
 regsub -all {\y[a-z]} $s _& s
 set ::fc 0;set ::nc 0;eval "K 0;$s"
 lmap x [regexp -all -inline {_\w+} [regsub -all {(GOSUB|GOTO|K) [^;]*} $s ""
  ]] {set ::v($x:) 0}
 assemble " $::runtime [join $::b] [join [
  lsort -dictionary -stride 2 [array get ::v]]]"
}

set runtime [join "
 jp Start

Prin1:
 dec st Txt
 jp L2
L1:
 ex call Princ
L2:
 call M1
 ld 128 <= L1
 ld 128 add
Princ:
 exdx ld 0x200
 inter ret
Print:
 pop push call Prin1
 call Prins 0x8a0d
 jp Exit
Prins:
 pop push call Prin1
 jp Exit

M1:
 ld Txt inc st Txt ex ld_em
 ret
Match:
 pop push dec st Txt
 ld Buf st P
M2:
 call M1
 ld P inc st P ex ld_em
 != M2
 ld 128 add by Txt ld_em == M3
 ld P st Buf ld 0
M3:
 st P
Exit:
 pop dec st Txt
M4:
 call M1
 ld 128 <= M4
 by P
 ld Txt inc
 push ret

Input:
 ld 125 st 128
 ld 129 st Buf
 dec exdx ld 0xa00
 inter ret

Ongoto:
 dec ex pop add add ex
 jpmde

P: 0
Txt: 0
Buf: 0
Start:
"]

compile [subst [read [open [lindex $::argv 0]]]]
