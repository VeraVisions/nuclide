output ../v_pistol.vvm
materialprefix textures/models/weapons/v_pistol/

geomset 0 0
	scene ref/enforcer_R.smd
geomset 0 1
	scene ref/enforcer_L.smd
rotate 0 -90 0
origin 8 0 0

scene seq/single_idle.smd fps 24
scene seq/single_idle_empty.smd fps 24

event reset
event 2 1004 "weapons/akimbo/draw4.wav 1"
event 19 1004 "weapons/enforcer/draw.wav 1"
	scene seq/single_draw1.smd fps 24

event reset
event 2 1004 "weapons/akimbo/draw4.wav 1"
event 19 1004 "weapons/enforcer/draw.wav 1"
	scene seq/single_draw1_empty.smd fps 24

event reset
event 2 1004 "weapons/akimbo/draw5.wav 1"
	scene seq/single_draw2.smd fps 24

event reset
event 2 1004 "weapons/akimbo/draw5.wav 1"
	scene seq/single_draw2_empty.smd fps 24

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
	scene seq/single_holster.smd fps 16

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
	scene seq/single_holster_empty.smd fps 16

event reset
event 12 1004 "weapons/enforcer/clipout.wav 1"
event 36 1004 "weapons/enforcer/clipin.wav 1"
	scene seq/single_reload1.smd fps 24

event reset
event 12 1004 "weapons/enforcer/clipout.wav 1"
event 36 1004 "weapons/enforcer/clipin.wav 1"
event 51 1004 "weapons/enforcer/slide.wav 1"
	scene seq/single_reload1_empty.smd fps 24

event reset
event 12 1004 "weapons/enforcer/clipout.wav 1"
event 40 1004 "weapons/enforcer/clipin.wav 1"
	scene seq/single_reload2.smd fps 24

event reset
event 12 1004 "weapons/enforcer/clipout.wav 1"
event 40 1004 "weapons/enforcer/clipin.wav 1"
event 57 1004 "weapons/enforcer/slide.wav 1"
	scene seq/single_reload2_empty.smd fps 24

event reset
event 12 1004 "weapons/enforcer/clipout.wav 1"
event 38 1004 "weapons/enforcer/clipin.wav 1"
	scene seq/single_reload3.smd fps 24

event reset
event 12 1004 "weapons/enforcer/clipout.wav 1"
event 38 1004 "weapons/enforcer/clipin.wav 1"
event 73 1004 "weapons/enforcer/slide.wav 1"
	scene seq/single_reload3_empty.smd fps 24

event reset
event 0 5000 ""
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot1.smd fps 24

event reset
event 0 5000 ""
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot1_last.smd fps 24

event reset
event 0 5000 ""
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot2.smd fps 24

event reset
event 0 5000 ""
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot2_last.smd fps 24

event reset
	scene seq/single_shoot_empty.smd fps 24

event reset
event 0 1004 "weapons/goto_aim.wav 1"
	scene seq/single_goto_aim.smd fps 48

event reset
event 0 1004 "weapons/goto_aim.wav 1"
	scene seq/single_goto_aim_empty.smd fps 48

event reset
	scene seq/single_aim_idle.smd fps 24
	scene seq/single_aim_idle_empty.smd fps 24

event reset
event 0 5000 ""
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_aim_shoot.smd fps 24

event reset
event 0 5000 ""
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_aim_shoot_last.smd fps 24

event reset
	scene seq/single_aim_shoot_empty.smd fps 24

event reset
event 0 1004 "weapons/end_aim.wav 1"
	scene seq/single_end_aim.smd fps 48

event reset
event 0 1004 "weapons/end_aim.wav 1"
	scene seq/single_end_aim_empty.smd fps 48

event reset
	scene seq/single_whip1.smd fps 24
	scene seq/single_whip1_empty.smd fps 24
	scene seq/single_whip2.smd fps 24
	scene seq/single_whip2_empty.smd fps 24
