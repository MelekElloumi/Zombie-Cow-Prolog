
%Exercice 1 :

% 1.
:-dynamic rocher/2.
:-dynamic arbre/2.


% 2.
:-dynamic vache/4.

% 3.
:-dynamic dimitri/2.

% 4.initiation des dimensions
largeur(X):- X is 5.
hauteur(Y):- Y is 5.

% 5. initiation des nombres d'entités
nombre_rochers(N):-N is 2.
nombre_arbres(N):-N is 2.
nombre_vaches(brune,N):- N is 2.
nombre_vaches(simmental,N):- N is 2.
nombre_vaches(alpine_herens,N):- N is 2.


%Exercice 2:

% 1. retourne vrai si une entité occupe une case
occupe(X,Y):-rocher(X,Y);arbre(X,Y);vache(X,Y,_,_);dimitri(X,Y).

% 2.Donne une place libre aléatoire
libre(X,Y):-repeat, largeur(XMAX), X is random(XMAX),
  hauteur(YMAX),Y is random(YMAX), not(occupe(X,Y)),!.

% 3.Placer les entités aléatoirement
placer_rochers(0):-!.
placer_rochers(N):-libre(X,Y),assert(rocher(X,Y)),
  M is N - 1,placer_rochers(M).

placer_arbres(0):-!.
placer_arbres(N):-libre(X,Y),assert(arbre(X,Y)),
  M is N - 1,placer_arbres(M).

placer_vaches(_,0):-!.
placer_vaches(Race,N):-libre(X,Y),assert(vache(X,Y,Race,vivante)),
  M is N - 1,placer_vaches(Race,M).

placer_dimitri:-libre(X,Y),assert(dimitri(X,Y)).

% 4.Liste de tous les vaches
vaches(L):-findall([X,Y],vaches(X,Y),L).
vaches(X,Y):-vache(X,Y,_,_).

% 5.Transformer une vache aléatoire en zombie
creer_zombie:-vaches(L), random_member([X,Y],L),
  vache(X,Y,Race,vivante),assert(vache(X,Y,Race,zombie)),
  retract(vache(X,Y,Race,vivante)).

%Exercice 3:

% 1.Lire l'entrée du joueur autant de fois jusqu'il soit correct

readok(K):-repeat,read(M),say(M),
  correct(M),K is M,!.
say(M):-not(correct(M)), write("Numéro erroné, Réessayer"),nl.
say(M):-correct(M).
correct(M):-member(M,[1,2,3,4,5,6]).

question(R):- nl,write("Donner le numéro de la direction: "),nl,
  write("1-reste  2-nord  3-sud  4-est  5-ouest 6-Quitter"),nl,
  readok(R),nl.

% 2.zombifier les vaches vivantes si ils sont à coté de vache zombie

zombification:-vaches(L),zombification(L).
zombification([[X,Y]|L]):-cote(X,Y),zombification(X,Y),zombification(L).
zombification([[X,Y]|L]):-not(cote(X,Y)),zombification(L).
zombification([]):-!.
zombification(X,Y):-vache(X,Y,Race,vivante),assert(vache(X,Y,Race,zombie)),
  retract(vache(X,Y,Race,vivante)).
zombification(X,Y):-vache(X,Y,_,zombie).

%retourne vrai si il y'a une vache zombie à coté
cote(X,Y):-Y1 is Y+1, vache(X,Y1,_,zombie);
X1 is X+1, vache(X1,Y,_,zombie);
X1 is X-1, vache(X1,Y,_,zombie);
Y1 is Y-1, vache(X,Y1,_,zombie).


% 3.deplacer tous les vaches dans une direction aléatoire
deplacement_vaches:-vaches(L),deplacement_vaches(L).
deplacement_vaches([[X,Y]|L]):-Direction is (random(5)+ 1),
  deplacement_vache(X,Y,Direction),
  deplacement_vaches(L).
deplacement_vaches([]):-!.

%déplacer une seule vache
deplacement_vache(X,Y,Direction):-nouvpos(X,Y,Direction,X1,Y1),
  vache(X,Y,Race,Etat),retract(vache(X,Y,Race,Etat)),
  assert(vache(X1,Y1,Race,Etat)).

% nouvpos retourne la nouvelle position en testant si elle est déjà
% occupé ou sur le bord du terrain

% cas rester
nouvpos(X,Y,1,X1,Y1):-X1 is X,Y1 is Y.

%cas nord
nouvpos(X,Y,2,X1,Y1):-Y==0,nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,2,X1,Y1):-Y_ is Y-1, occupe(X,Y_),nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,2,X1,Y1):-X1 is X, Y1 is Y-1.

%cas sud
nouvpos(X,Y,3,X1,Y1):-hauteur(YMAX),Y=:=YMAX-1,nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,3,X1,Y1):-Y_ is Y+1,occupe(X,Y_),nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,3,X1,Y1):-X1 is X, Y1 is Y+1.

%cas est
nouvpos(X,Y,4,X1,Y1):-largeur(XMAX),X=:=XMAX-1,nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,4,X1,Y1):-X_ is X+1,occupe(X_,Y),nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,4,X1,Y1):-X1 is X+1, Y1 is Y.

%cas ouest
nouvpos(X,Y,5,X1,Y1):-X==0,nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,5,X1,Y1):-X_ is X-1,occupe(X_,Y),nouvpos(X,Y,1,X1,Y1),!.
nouvpos(X,Y,5,X1,Y1):-X1 is X-1, Y1 is Y.


% 4.déplacer dimitre dans la direction donnée
deplacement_joueur(Direction):-dimitri(X,Y),
  nouvpos(X,Y,Direction,X1,Y1),
  retract(dimitri(X,Y)),
  assert(dimitri(X1,Y1)).

% 5.retourne vrai si dimitri n'est pas à coté d'une vache zombie
verification:-dimitri(XD,YD),
  not(cote(XD,YD)).


% le reste est le code prédéfini du jeu
% j'ai ajouté retractall pour vider les anciens assert

initialisation :-
  retractall(rocher(_,_)),
  retractall(arbre(_,_)),
  retractall(vache(_,_,_,_)),
  retractall(dimitri(_,_)),
  nombre_rochers(NR),
  placer_rochers(NR),
  nombre_arbres(NA),
  placer_arbres(NA),
  nombre_vaches(brune, NVB),
  placer_vaches(brune, NVB),
  nombre_vaches(simmental, NVS),
  placer_vaches(simmental, NVS),
  nombre_vaches(alpine_herens, NVH),
  placer_vaches(alpine_herens, NVH),
  placer_dimitri,
  creer_zombie,
  !.

%j'ai ajouté le traitement du cas d'initialisation où dimitri est bloqué
%par des bords,arbres et roches.

%retourne vrai si il est occupé
occupe_bloq(X,Y):-rocher(X,Y),!;arbre(X,Y),!;
                 largeur(XMAX),X=:=XMAX,!;hauteur(YMAX),Y=:=YMAX,!;
                 X =:= -1,!; Y=:= -1,!.

%retroune vrai si dimitri est bloqué dans toutes les directions
bloquer:-dimitri(X,Y),bloquer(X,Y).
bloquer(X,Y):-Y1 is Y+1, occupe_bloq(X,Y1),
X1 is X+1, occupe_bloq(X1,Y),
X2 is X-1, occupe_bloq(X2,Y),
Y2 is Y-1, occupe_bloq(X,Y2).

%j'ai améliorer l'affichage du terrain
affichage(L, _) :-
  largeur(L),
  nl.

affichage(L, H) :-
  rocher(L, H),
  write(" O "),
  L_ is L + 1,
  affichage(L_, H).

affichage(L, H) :-
  arbre(L, H),
  write(" T "),
  L_ is L + 1,
  affichage(L_, H).

affichage(L, H) :-
  dimitri(L, H),
  write(" D "),
  L_ is L + 1,
  affichage(L_, H).

affichage(L, H) :-
  vache(L, H, brune, vivante),
  write(" B "),
  L_ is L + 1,
  affichage(L_, H).
affichage(L, H) :-
  vache(L, H, brune, zombie),
  write(" b "),
  L_ is L + 1,
  affichage(L_, H).

affichage(L, H) :-
  vache(L, H, simmental, vivante),
  write(" S "),
  L_ is L + 1,
  affichage(L_, H).
affichage(L, H) :-
  vache(L, H, simmental, zombie),
  write(" s "),
  L_ is L + 1,
  affichage(L_, H).

affichage(L, H) :-
  vache(L, H, alpine_herens, vivante),
  write(" H "),
  L_ is L + 1,
  affichage(L_, H).
affichage(L, H) :-
  vache(L, H, alpine_herens, zombie),
  write(" h "),
  L_ is L + 1,
  affichage(L_, H).

affichage(L, H) :-
  \+ occupe(L, H),
  write(" . "),
  L_ is L + 1,
  affichage(L_, H).

affichage(H) :-
  hauteur(H).

affichage(H) :-
  hauteur(HMax),
  H < HMax,
  affichage(0, H),
  H_ is H + 1,
  affichage(H_).

affichage :-
  affichage(0),!.


jouer :-
  initialisation,
  jouerinit.

%le jeu commence quand dimitri n'est pas bloqué
jouerinit:-bloquer,!,
  jouer.

jouerinit:-
  not(bloquer),
  tour(0, _).


tour_(N, _) :-
  not(verification),
  affichage,
  nl,write('Dimitri s\'est fait mordre'),nl,
  write("Score: "),write(N),write(" tours."),!.
tour_(N, R) :-
  verification,
  M is N + 1,
  tour(M, R).

tour(N, R) :-
  write("Tour numéro: "),write(N),nl,
  affichage,
  question(X),
  not(quitter(X)),
  deplacement_joueur(X),
  deplacement_vaches,
  zombification,
  tour_(N, R).

%j'ai ajouté une commande pour quitter le jeu dans n'importe quel tour
quitter(6):- write('Jeu quitté').




r(a).
r(c).
q(b).
p(X):-not(r(X)).




