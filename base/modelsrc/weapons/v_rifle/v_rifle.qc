output ../v_rifle.vvm
materialprefix textures/models/weapons/v_rifle/

scene ref/m16.smd
origin 10 0 0 
rotate 0 -90 0

scene seq/idle.smd fps 8.0
scene seq/idle_empty.smd fps 8.0

event reset
event 0 1004 "weapons/m16/draw.wav 1"
scene seq/draw.smd fps 25.0
scene seq/draw_empty.smd fps 25.0

event reset
event 0 1004 "weapons/m16/holster.wav 1"
scene seq/holster.smd fps 30.0
scene seq/holster_empty.smd fps 30.0

event reset
event 13 1004 "weapons/m16/clipout.wav 1"
event 36 1004 "weapons/m16/clipin.wav 1"
event 43 1004 "weapons/m16/bolt.wav 1"
scene seq/reload.smd fps 20.0
scene seq/reload_empty.smd fps 20.0

event reset
event 0 5000 ""
event 0 1002 "54 0 0 -40"
event 0 1005 "54 1"
	scene seq/shoot.smd fps 24.0
	scene seq/shoot_last.smd fps 24.0

event reset
scene seq/shoot_empty.smd fps 30.0

event reset
event 0 1004 "weapons/m16/mode.wav 1"
	scene seq/goto_semi.smd fps 30.0
	scene seq/goto_semi_empty.smd fps 30.0
	scene seq/end_semi.smd fps 30.0
	scene seq/end_semi_empty.smd fps 30.0

event reset
event 0 1004 "weapons/goto_aim.wav 1"
	scene seq/goto_aim.smd fps 30.0
	scene seq/goto_aim_empty.smd fps 30.0

event reset
	scene seq/aim_idle.smd fps 30.0
	scene seq/aim_idle_empty.smd fps 30.0

event reset
event 0 5000 ""
event 0 1002 "54 0 0 -40"
event 19 0 1005 "54 1"
	scene seq/aim_shoot.smd fps 30.0
	scene seq/aim_shoot_last.smd fps 30.0

event reset
	scene seq/aim_shoot_empty.smd fps 30.0

event 0 1004 "weapons/m16/mode.wav 1"
	scene seq/aim_goto_semi.smd fps 30.0
	scene seq/aim_goto_semi_empty.smd fps 30.0
	scene seq/aim_end_semi.smd fps 30.0
	scene seq/aim_end_semi_empty.smd fps 30.0

event reset
event 0 1004 "weapons/end_aim.wav 1"
	scene seq/end_aim.smd fps 30.0
	scene seq/end_aim_empty.smd fps 30.0
