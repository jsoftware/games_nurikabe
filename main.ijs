WHITE=: 0
BLACK=: _1
FREE=: _2

init=: + FREE*0=]

see=: 3 : 'y { _1|.(":&.>1+i.>./,y),<"0 ''?X '''

connect=: 3 : 0     NB. connection matrix for Nurikabe
b=. WHITE<:y
i=. I., (}.=}:) b
j=. I., 0,.~(}."1 = }:"1) b
(+.|:) 1 (<"1 (i+/0,{:$y),j+/0 1)}=i.*/$y
)

tc=: +./ .*~^:(>.@(2&^.)@#)
NB. transitive closure

islands=: ~. @ (<@I."1"_) @ tc @ connect
NB. connected components

check=: 3 : 0       NB. 1 iff y is a Nurikabe solution
assert. (y e. BLACK,WHITE) +. 0<y
assert. -. 2 2 (2 2$BLACK)&-:;._3 y
c=. islands y
assert. (#c) = 1++/,0<y
i=. c{&.><,y
n=. #&>i
b=. i = n$&.><BLACK
assert. 1=+/b
assert. b +. *./@(0&<:)&>i
assert. b +. 1 = +/@(0&<)&>i
assert. b +. n = +/&>i
1
)

wf=: 3 : 0          NB. # white cells, # free cells
t=. ,y
m=. (+/0>.t)-+/(0<t)+.t=WHITE
n=. +/t=FREE
m,n
)

comb=: 4 : 0        NB. All size x combinations of i.y
k=. i.>:d=. y-x
z=. (d$<i.0 0),<i.1 0
for. i.x do. z=. k ,.&.> ,&.>/\. >:&.> z end.
; z
)

bf=: 3 : 0          NB. brute force solver
t=. ,y
b=. t=FREE
'm n'=. wf t
t=. ($y) $"1 (t*-.b) +"1 b #^:_1"1 ((i.n) e."1 m comb n){BLACK,WHITE
t {~ (check :: 0:"2 i. 1:) t
)

heuristics=: (WHITE&hboxedin) @ (BLACK&hboxedin) @ hwhiteislands @ h2ell @ h22 ^:_ @ hnbr @ h2far

bfh=: bf @ heuristics @ init
NB. brute force with heuristics

NB. Heuristics

h2far=: 3 : 0       NB. set to black cells too far from a numbered cell
i=. ($y)#:I.,_2=y
j=. ($y)#:I.,1<y
b=. (i +/@:|@:-"1/ j) */ .>: (1<y)#&,y
p=. (i.$y) e. ($y)#.b#i
(p*BLACK) + y*-.p
)

neighborhood=: 3 3 ,;._3 [,.([,],[),.[
NB. neighborhood of each atom in y, bordering y by x

hnbr=: 3 : 0        NB. set to black cells with >1 numbered neighbors
p=. 2 3 e.~ (0 neighborhood 0<y) +/ .* 9$0 1
(p*BLACK) + y*-.p
)

h22=: 3 : 0         NB. set to white the free cell of a 2x2 block with 3 black cells
p=. (FREE=y) *. +./"1 (=i.4) e.~ (,/2 2 ,;._3 i.3 3) {"2 1 (BLACK,FREE) i. WHITE neighborhood y
(p*WHITE) + y*-.p
)

NB. If a 2-cell has only two possibilities for a white neighbor,
NB. and the three cells together form an "L",
NB. then set to black the neighbor of the two limbs of the "L".

h2ell=: 3 : 0
k=. #: 12 10 5 3
t=. FREE = (* (2=4{"1]) * (k{BLACK,FREE) e.~ 1 3 5 7{"1 ]) ,/ BLACK neighborhood y
i=. I. -. t-:"1 (9$0)
j=. (k i.(<i;1 3 5 7){t){(-1 _1+n),_1 1+n=. {:$y
p=. (i.$y) e. i+j
(p*BLACK) + y*-.p
)

NB. set to black neighbors of complete white islands

hwhiteislands=: 3 : 0
c=. (#~ (# = +/@({&(,y)))&>) islands y
p=. (WHITE>y) *. (i.$y) e. ,(;c){1 3 5 7 {"1 ,/_1 neighborhood i.$y
(p*BLACK) + y*-.p
)

NB. x is BLACK or WHITE
NB. set to x the free neighbor of an x cell whose other neighbors are not x
NB. assumes that neighbors of complete white islands are already black

hboxedin=: 4 : 0
nx=. (WHITE,BLACK){~(BLACK,WHITE)i.x
t=. 1 3 5 7 {"1 ,/ _1 neighborhood i.$y
i=. ((=i.4){nx,FREE) i. ((*,y-x)e. 0,x=WHITE)*t{WHITE<.(,y),nx
b=. 4>i
p=. (i.$y) e. (<"1 (I.b),.b#i){t
(p*x) + y*-.p
)
