# Ltmz
# 8-bit CP/M Text Adventure Compiler, version 5.0
# July 2025
# by Lukas Petru

# Licensed under the MIT License (Expat)

array set code {
 ldv 2a  ldc 21   byv {ed 5b} byc 11
 st 22   ex eb    bc 1    addbc 9
 ret c9  call cd  jp c3   jphl e9
 rc bf   sc 37    add 19  sub {ed 52}
 jpnc d2 jpc da   jpnz c2 jpz ca
 inc 23  dec 2b   pop e1  push e5
 lddm 56 ldem 5e  ldlm 6e ldhb 60
 nul 0   ld_mb 70 rst30 f7
}
proc asmsrc s {
 foreach {x r} {
  { by 0 < }      { jp }
  { by (\d+) < }  { byc -\1 add jpc }
  { by 0 >= \w+}  {}
  { by (\d+) >= } { byc -\1 add jpnc }
  { by (\d+) <= } { byc ~\1 add jpc }
  { by (\d+) > }  { byc ~\1 add jpnc }
  { by (\d+) != } { byc ~\1 add addbc jpc }
  { by (\d+) == } { byc ~\1 add addbc jpnc }
  == {rc sub jpnz}
  != {rc sub jpz}
  { by (\d+) rc sub } { byc -\1 add }
  >= {rc sub jpc}
  <= {sc sub jpnc}
  <  {rc sub jpnc}
  >  {sc sub jpc}
  { ld (\d)} { ldc \1}
  { ld } { ldv }
  { by (\d)} { byc \1}
  { by } { byv }
  { ld_dem } { ldem inc lddm }
  { ld_lm } { ldlm ldhb }
  { call Print } { rst30 }
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
   *: {lb $x} [a-z]* {db $x} [-~0-9]* {dv $x} %* {dt $x} * {dw $x 0}}
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
proc GOSUB n {lappend ::b "call K$n"}
proc GOTO n {lappend ::b "jp K$n"}
proc IF {a o b} {lappend ::b "ld [n $a] by [n $b] $o F$::fc"}
proc INPUT "" {lappend ::b "call Input"}
proc K n {lappend ::b K$n:}
proc LET {a e b "o 0" "c 0"} {
 lappend ::b "ld [n $b][
  expr {$c==0?"":$o=="+"?" by [n $c] add":" by [n $c] rc sub"}] st $a"}
proc MATCH {a s} {
 lappend ::b "call Match $s ex st $a"}
proc NEXT "" {lappend ::b N$::nc:;incr ::nc}
proc ON {a g args} {
 lappend ::b "ld [n $a] call [join Ongoto\ $args \ K] 0"}
proc PRINS s {lappend ::b "call Prins $s"}
proc PRINT s {lappend ::b "call Print $s"}
proc RETURN "" {lappend ::b ret}
proc SKIP "" {lappend ::b "jp N$::nc"}
proc SYSTEM "" {lappend ::b "jp Boot"}
# :: -strings, ::v -variables, ::a -addresses
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
 assemble " $::runtime [join $::b] [
  lsort -dictionary -stride 2 [array get ::v]]"
}

set runtime [join "
 ldc jp nul st 0x30
 ldc Print st 0x31
 bc 1 
 jp Start

Prin1:
 dec st Txt
 jp L2
L1:
 call Princ
L2:
 call M1
 ld 128 <= L1
 ld 128 add ex
Princ:
 bc 2
Bdos:
 call 5 bc 1 ret
Print:
 pop push call Prin1
 call Prins 0x8a0d
 jp Exit
Prins:
 pop push call Prin1
 jp Exit

M1:
 ld Txt inc st Txt ld_lm ex
 ret
Match:
 pop push dec st Txt
 ld Buf st P
M2:
 call M1
 ld P inc st P ld_lm
 != M2
 ld 0xff80 add ex ld P ld_lm == M3
 ld P st Buf ld 0
M3:
 st P
Exit:
 pop dec st Txt
M4:
 call M1
 ex by 128 >= M4
 by P
 ld Txt inc
 jphl

Input:
 ld 125 st 128
 by 128 bc 10 call Bdos
 ld 129 st Buf
 ld_lm by 130 add ld_mb
 ret

Ongoto:
 dec ex pop add add
 ld_dem ex
 jphl

P: 0
Txt: 0
Buf: 0
Start:
"]

compile [subst [read [open [lindex $::argv 0]]]]
