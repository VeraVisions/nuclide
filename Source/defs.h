/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* Those are constant for HL BSP and CANNOT be changed.
 * Blame Valve for purchasing a Quake II license but not
 * scrapping hull sizes for their .bsp format... */
const vector VEC_HULL_MIN = [-16,-16,-36];
const vector VEC_HULL_MAX = [16,16,36];
const vector VEC_CHULL_MIN = [-16,-16,-18];
const vector VEC_CHULL_MAX = [16,16,18];

#ifdef CSTRIKE
const vector VEC_PLAYER_VIEWPOS =	 [0,0,20];
const vector VEC_PLAYER_CVIEWPOS = [0,0,12];
#endif

#ifdef VALVE
const vector VEC_PLAYER_VIEWPOS = [0,0,24];
const vector VEC_PLAYER_CVIEWPOS = [0,0,12];
#endif

// Actually used by input_button etc.
#define INPUT_BUTTON0	0x00000001
#define INPUT_BUTTON2	0x00000002
#define INPUT_BUTTON3	0x00000004
#define INPUT_BUTTON4	0x00000008
#define INPUT_BUTTON5	0x00000010
#define INPUT_BUTTON6	0x00000020
#define INPUT_BUTTON7	0x00000040
#define INPUT_BUTTON8	0x00000080

#define FL_USERELEASED 	(1<<13)
#define FL_CROUCHING 	(1<<19)
#define FL_SEMI_TOGGLED	(1<<15)
#define FL_FROZEN 	(1<<17)
#define FL_REMOVEME	(1<<18)

#define clamp(d,min,max) bound(min,d,max)
