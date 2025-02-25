output ../v_frag.vvm
materialprefix textures/models/weapons/v_frag/

scene ref/grenade.smd
rotate 0 -90 0
origin 4 0 0

event reset
	scene seq/idle.smd fps 30.0

event reset
event 0 1004 "weapons/grenade/draw.wav 1"
	scene seq/draw.smd fps 30.0

event reset
event 0 1004 "weapons/grenade/holster.wav 1"
	scene seq/holster.smd fps 30.0

event reset
event 11 1004 "weapons/grenade/pinpull.wav 1"
event 23 1004 "weapons/grenade/spoon.wav 1"
event 23 1004 "weapons/grenade/ticking.wav 1"
	scene seq/goto_throw.smd fps 30.0
	scene seq/goto_throw_hold.smd fps 30.0

event reset
	scene seq/drop.smd fps 30.0

event reset
event 0 1004 "weapons/grenade/throw.wav 1"
	scene seq/throw.smd fps 30.0

