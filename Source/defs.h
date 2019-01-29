/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

const vector VEC_HULL_MIN = '-16 -16 -36';
const vector VEC_HULL_MAX = '16 16 36';

const vector VEC_CHULL_MIN = '-16 -16 -18';
const vector VEC_CHULL_MAX = '16 16 18';

#ifdef CSTRIKE
const vector VEC_PLAYER_VIEWPOS = '0 0 20';
const vector VEC_PLAYER_CVIEWPOS = '0 0 12';
#endif

#ifdef VALVE
const vector VEC_PLAYER_VIEWPOS = '0 0 24';
const vector VEC_PLAYER_CVIEWPOS = '0 0 12';
#endif

// Actually used by input_button etc.
#define INPUT_BUTTON0 1
#define INPUT_BUTTON2 2
#define INPUT_BUTTON3 4
#define INPUT_BUTTON4 8
#define INPUT_BUTTON5 16
#define INPUT_BUTTON6 32
#define INPUT_BUTTON7 64
#define INPUT_BUTTON8 128

#define FL_USERELEASED 	(1<<13)
#define FL_CROUCHING 	(1<<19)
#define FL_SEMI_TOGGLED (1<<15)
#define FL_FROZEN 	(1<<17)
#define FL_REMOVEME	(1<<18)

#define clamp(d,min,max) bound(min,d,max)
