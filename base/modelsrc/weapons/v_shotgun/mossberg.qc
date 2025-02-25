output ../v_shotgun.vvm
materialprefix textures/models/weapons/v_shotgun/

scale 0.5
scene ref/mossberg.smd
rotate 0 -90 0
origin 12 0 -3.5

scene seq/idle1.smd fps 10.0
scene seq/idle2.smd fps 10.0

event 0 1004 "weapons/mossberg/draw.wav 1"
	scene seq/draw.smd fps 30.0

event reset
event 0 1004 "weapons/mossberg/holster.wav 1"
	scene seq/holster.smd fps 60.0

event reset
	scene seq/goto_reload.smd fps 25.0

event reset
event 8 1004 "weapons/mossberg/reload.wav 1"
	scene seq/reload.smd fps 35.0

event reset
event 0 1004 "weapons/mossberg/pump.wav 1"
	scene seq/end_reload.smd fps 30.0

event reset
event 0 5000 ""
event 0 1005 "30 9"
	scene seq/shoot.smd fps 25.0
	scene seq/shoot2.smd fps 25.0

event reset
scene seq/shoot_empty.smd fps 25.0

event 0 1004 "weapons/goto_aim.wav 1"
	scene seq/goto_aim.smd fps 60.0

event reset
	scene seq/aim_idle.smd fps 30.0

event reset
event 0 5000 ""
event 0 1005 "30 9"
	scene seq/aim_shoot.smd fps 30.0
origin 7.5 0.5 -4
	scene seq/aim_shoot2.smd fps 25.0
origin 8 0 -3.5

event reset
	scene seq/aim_shoot_empty.smd fps 30.0

event 0 1004 "weapons/end_aim.wav 1"
	scene seq/end_aim.smd fps 60.0

event reset
	scene seq/whip.smd fps 30.0
