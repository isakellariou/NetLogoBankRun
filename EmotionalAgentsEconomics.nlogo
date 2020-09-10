;;; Bank Run Emotional Agents Simulator.
;;; Ilias Sakellariou, Kostantinos Grevenitis, Petros Kefalas
;;; 2020
__includes ["state-x-machines-emotions.nls" "enviroment.nls" "persons.nls" "influencers.nls"]

globals [
  queue
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;run simulation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to run-simulation
  ;balance-books
  ask persons [
    update-percepts-persons
    ;; Run X-Machine to determine the next action
    execute-exsm-machine
    ;;financial-equlibrium
    ;;; Debugging
    ;set label current-state-name#sm
    ;;; Consume some goods
    if x-mem-value "Goods-Level" > 0
      [set-x-memory-value "Goods-Level" max (list 0 (x-mem-value "Goods-Level" - consumption_rate + random 3))]
  ]

  ask journalists [influencers-move-randomly]
  ask goverment_members [influencers-move-randomly]
  ask banks [bank-behaviour]

  ;; Shops might be awlays open.
  ;;if ticks mod 25 = 0 [ask shops [set shop-open true set color orange]]
  ; Keep it running
  ;;if ticks = 192 [stop]


  ;; Daily cycle
  if (ticks mod 96 = 0)
  [
    ask shops [shop-behaviour]

   ;ask banks
    ;[ ;; This actually presents a problem. 'Savings" are already in the bank, so adding the at the end of the day makes no point.
      ;;set bankReserves bankReserves + (sum [x-mem-value "Savings"] of persons with [x-mem-value "MyBank" = [id] of myself]  + sum [profits] of shops with [myBank = [id] of myself])
      ;;set bankReserves bankReserves + (sum [x-mem-value "Savings"] of persons with [x-mem-value "MyBank" = [id] of myself]  + sum [profits] of shops with [myBank = [id] of myself])
      ;;;set label (word bankReserves)
    ;]
    ask atms [atm-behaviour]
  ]

  ; Removed to speed-up experiment. Uncomment to see Labels.
  ; ask banks [update-bank-label]
  ; ask atms [update-atm-label]
  ; ask shops [update-shop-label]

  tick

  ;; Exeriment Terminating Conditions (25 days or all banks failed).
  if (floor ticks / 96 ) >= 25  [stop]
  if (count banks with [status-solvent] = 0) [stop]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setup methods for Environment and Agents
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all
  setup-companies
  setup-banks
  setup-atms
  ; shops should be after Banks
  setup-shops
  setup-houses
  setup-persons
  setup-journalists
  setup-goverment_members
  update-bank-atm-reserves
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; position in world (utility)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to rand-xy-co
  let _x 0
  let _y 0

  loop [
    set _x (random max-pxcor + random min-pxcor)
    set _y (random max-pycor + random min-pycor)
    if not any? turtles-on patch-at _x _y and not ( (abs _x) < 3  and (abs _y) < 3) [setxy _x _y stop]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utilities for Running Multiple experiments.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to run-set
  foreach [0 5 10 15]
    [ [inf?]->
      set Number-of-influencers inf?
      foreach ["none" "ascribe-like"]
      [[mod?] ->
        set contagion-model mod?
        show (word inf? " " mod?)
        setup
        no-display
        while [(floor (ticks / 96)) < 25 and count banks with [status-solvent] > 0] [run-simulation]
        export-plot "Bank Queues" (word "./data/BQ_" "Infl" inf? "_" mod? ".csv")
        export-plot "Reserves and Cash" (word "./data/testResCash_" "Infl" inf? "_" mod?  ".csv")
        export-output (word "./data/Output_" "Infl" inf? "_" mod?)
        ]
      ]
end


to run-only-output
  foreach [5 6 7 8 9 10 11 12 13 14 15]
    [ [inf?]->
      set Number-of-influencers inf?
      ;;foreach ["none" "ascribe-like"]
      foreach ["none"]
      [[mod?] ->
        foreach [1 2 3 4 5 6 7]
        [ [run?] ->
        set contagion-model mod?
        show (word inf? " " mod?)
        setup
        no-display
        while [(floor (ticks / 96)) < 25 and count banks with [status-solvent] > 0] [run-simulation]
    ;   export-plot "Bank Queues" (word "./data/BQ_" "Infl" inf? "_" mod? ".csv")
    ;   export-plot "Reserves and Cash" (word "./data/testResCash_" "Infl" inf? "_" mod?  ".csv")
        export-output (word "./data/Output_" "Infl" inf? "_" mod? "_" run?)
        ]
      ]
      ]

end
@#$#@#$#@
GRAPHICS-WINDOW
200
10
1020
831
-1
-1
24.61
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
8
30
100
63
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
69
186
102
Run simulation
run-simulation
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
105
31
186
64
Run Once
run-simulation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
4
351
190
384
Population
Population
1
500
264.0
1
1
NIL
HORIZONTAL

SLIDER
5
223
187
256
Number-of-Banks
Number-of-Banks
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
6
113
188
146
Number-of-Markets
Number-of-Markets
1
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
5
387
189
420
Average-Salary
Average-Salary
500
5000
800.0
100
1
NIL
HORIZONTAL

SLIDER
9
587
186
620
p-trait-max
p-trait-max
0
1
1.0
0.05
1
NIL
HORIZONTAL

CHOOSER
7
498
189
543
contagion-model
contagion-model
"none" "simple" "ascribe-like"
2

SLIDER
6
463
189
496
influence-distance
influence-distance
0
40
3.0
1
1
NIL
HORIZONTAL

MONITOR
1092
10
1177
55
Hour Of day
round (ticks mod 96 / 4)
17
1
11

MONITOR
1027
115
1180
160
NIL
is-start-of-the-day?
17
1
11

MONITOR
1028
163
1181
208
Day Period
day-time-indication
17
1
11

SLIDER
6
151
188
184
Number-of-Companies
Number-of-Companies
1
50
15.0
1
1
NIL
HORIZONTAL

SLIDER
6
260
188
293
Number-of-ATMs
Number-of-ATMs
1
50
20.0
1
1
NIL
HORIZONTAL

PLOT
1181
10
1829
174
Bank Queues
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot max [tickets-awarded - tickets-served] of banks"

MONITOR
1310
178
1438
223
Total Bank Reserves
total-bank-reserves
2
1
11

MONITOR
1181
178
1308
223
Total bank Deposits
total-bank-deposits
2
1
11

PLOT
1207
552
1828
833
Reserves and Cash
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Bank Reserves" 1.0 0 -5298144 true "" "plot total-bank-reserves"
"Wallet Cash" 1.0 0 -7500403 true "" "plot total-wallet-cash"
"Bank Deposits / 10" 1.0 0 -7858858 true "" "plot total-bank-deposits / 10"
"Cash Desired" 1.0 0 -13840069 true "" "plot (mean-cash-desired * Population)"

MONITOR
1570
178
1704
223
Total Person Cash
total-wallet-cash
2
1
11

MONITOR
1709
178
1844
223
Total Person Savings
total-person-savings
2
1
11

MONITOR
1032
10
1089
55
Day
floor (ticks / 96)
2
1
11

SLIDER
5
424
188
457
consumption_rate
consumption_rate
0
10
4.0
1
1
NIL
HORIZONTAL

MONITOR
1441
178
1568
223
Mean Cash Desired
mean-cash-desired
2
1
11

BUTTON
3
706
184
739
Increase Cash Desired
ask persons [set-x-memory-value \"CashDesired\" 1.2 * x-mem-value \"CashDesired\"] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
6
187
187
220
Number-of-influencers
Number-of-influencers
0
20
15.0
1
1
NIL
HORIZONTAL

BUTTON
3
746
184
779
Increase Wallet/Cash
ask persons [if x-mem-value \"Wallet/Cash\" < 0.8 [set-x-memory-value \"Wallet/Cash\" (x-mem-value \"Wallet/Cash\") + 0.05]] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1574
227
1663
272
Wallet/Cash
mean [x-mem-value \"Wallet/Cash\"] of persons
2
1
11

PLOT
1458
287
1838
506
Emotions-Arousal
Time
Values
0.0
10.0
-1.1
1.1
true
true
"" ""
PENS
"Arousal" 1.0 0 -2674135 true "" "plot mean [x-arousal-of-self] of persons"
"Max-Arousal" 1.0 0 -1069655 true "" "plot max [x-arousal-of-self] of persons"
"Min Arousal" 1.0 0 -8053223 true "" "plot min [x-arousal-of-self] of persons"
"0" 1.0 0 -16777216 true "" "plot 0"

PLOT
1067
288
1448
506
Emotions Valence
NIL
NIL
0.0
10.0
-1.1
1.1
true
true
"" ""
PENS
"Mean Valence" 1.0 0 -13345367 true "" "plot mean [x-valence-of-self] of persons"
"Max Valence" 1.0 0 -4528153 true "" "plot max [x-valence-of-self] of persons"
"Min Valence" 1.0 0 -7500403 true "" "plot min [x-valence-of-self] of persons"
"0" 1.0 0 -5298144 true "" "plot 0"

SLIDER
11
624
183
657
Init-Exp
Init-Exp
0
0.8
0.2
0.05
1
NIL
HORIZONTAL

SLIDER
12
660
184
693
Init-Open
Init-Open
0
0.8
0.3
0.05
1
NIL
HORIZONTAL

SLIDER
8
552
185
585
p-trait-min
p-trait-min
0
1
1.0
0.05
1
NIL
HORIZONTAL

MONITOR
1033
59
1090
104
Hours
ticks / 4
2
1
11

OUTPUT
1029
552
1203
832
12

@#$#@#$#@
## WHAT IS IT?

A simulation of a bank run using agents based on emotional X-Machines.

(Description will be updated soon).

## CREDITS AND REFERENCES

This work is described in the paper 
Konstantinos Grevenitis, Ilias Sakellariou and Petros Kefalas. Emotional Agents Make a (Bank) Run, EUMAS Conference 2020, Thessaloniki Greece.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bank
false
0
Rectangle -7500403 true true 15 75 285 300
Rectangle -16777216 true false 30 210 90 285
Line -16777216 false 30 105 270 105
Rectangle -16777216 true false 120 210 180 285
Rectangle -16777216 true false 210 210 270 285
Circle -7500403 true true 75 15 150
Rectangle -16777216 true false 30 120 90 195
Rectangle -16777216 true false 210 120 270 195
Rectangle -16777216 true false 210 120 270 195
Rectangle -16777216 true false 120 120 180 195

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

building store2
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 0 165 315 300
Rectangle -16777216 true false 120 180 180 240
Line -7500403 true 150 180 150 255
Rectangle -16777216 true false 15 180 75 240
Rectangle -16777216 true false 210 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 60 150 90 135 285 60 285 135 300 165
Rectangle -7500403 true true 0 0 135 60
Rectangle -16777216 false false 0 0 135 60
Line -7500403 true 45 180 45 255
Rectangle -16777216 true false 15 180 75 240
Line -7500403 true 45 180 45 255
Line -7500403 true 240 180 240 255

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

company
false
0
Rectangle -7500403 true true 45 0 300 300
Rectangle -16777216 true false 60 210 270 285
Rectangle -7500403 true true 0 75 45 300
Rectangle -16777216 true false 60 120 270 195
Rectangle -16777216 true false 60 30 270 105
Line -7500403 true 165 30 165 285
Line -7500403 true 225 30 225 285
Line -7500403 true 105 15 105 285

computer server
false
0
Rectangle -7500403 true true 75 30 225 270
Line -16777216 false 210 30 210 195
Line -16777216 false 90 30 90 195
Line -16777216 false 90 195 210 195
Rectangle -10899396 true false 184 34 200 40
Rectangle -10899396 true false 184 47 200 53
Rectangle -10899396 true false 184 63 200 69
Line -16777216 false 90 210 90 255
Line -16777216 false 105 210 105 255
Line -16777216 false 120 210 120 255
Line -16777216 false 135 210 135 255
Line -16777216 false 165 210 165 255
Line -16777216 false 180 210 180 255
Line -16777216 false 195 210 195 255
Line -16777216 false 210 210 210 255
Rectangle -7500403 true true 84 232 219 236
Rectangle -16777216 false false 101 172 112 184

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dollar bill
false
0
Rectangle -7500403 true true 15 90 285 210
Rectangle -1 true false 30 105 270 195
Circle -7500403 true true 120 120 60
Circle -7500403 true true 120 135 60
Circle -7500403 true true 254 178 26
Circle -7500403 true true 248 98 26
Circle -7500403 true true 18 97 36
Circle -7500403 true true 21 178 26
Circle -7500403 true true 66 135 28
Circle -1 true false 72 141 16
Circle -7500403 true true 201 138 32
Circle -1 true false 209 146 16
Rectangle -16777216 true false 64 112 86 118
Rectangle -16777216 true false 90 112 124 118
Rectangle -16777216 true false 128 112 188 118
Rectangle -16777216 true false 191 112 237 118
Rectangle -1 true false 106 199 128 205
Rectangle -1 true false 90 96 209 98
Rectangle -7500403 true true 60 168 103 176
Rectangle -7500403 true true 199 127 230 133
Line -7500403 true 59 184 104 184
Line -7500403 true 241 189 196 189
Line -7500403 true 59 189 104 189
Line -16777216 false 116 124 71 124
Polygon -1 true false 127 179 142 167 142 160 130 150 126 148 142 132 158 132 173 152 167 156 164 167 174 176 161 193 135 192
Rectangle -1 true false 134 199 184 205

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house2
false
0
Rectangle -7500403 true true 45 105 60 300
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 30 105 150 15 270 105
Line -16777216 false 30 120 270 120
Rectangle -7500403 true true 240 105 255 300
Rectangle -7500403 true true 45 285 255 300

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
