output ../v_bat.vvm
materialprefix textures/models/weapons/v_bat/

scene ref/slugger.smd
rotate 0 -90 0
origin 8 0 0

scene seq/1h_idle.smd fps 13.0
scene seq/2h_idle.smd fps 13.0
scene seq/1h_idle2.smd fps 30.0
scene seq/2h_idle2.smd fps 30.0

event 0 1004 "weapons/baseballbat/draw.wav 1"
	scene seq/1h_draw.smd fps 30.0
	scene seq/2h_draw.smd fps 30.0

event reset
event 0 1004 "weapons/baseballbat/holster.wav 1"
	scene seq/1h_holster.smd fps 24.0
	scene seq/2h_holster.smd fps 24.0

event reset
scene seq/1h_hit1.smd fps 16.0
scene seq/1h_hit1_miss.smd fps 24.0
scene seq/1h_hit2.smd fps 16.0
scene seq/1h_hit2_miss.smd fps 16.0
scene seq/1h_hit3.smd fps 16.0
scene seq/1h_hit3_miss.smd fps 16.0
scene seq/2h_hit1.smd fps 30.0
scene seq/2h_hit1_miss.smd fps 30.0
scene seq/2h_hit2.smd fps 30.0
scene seq/2h_hit2_miss.smd fps 30.0
scene seq/1h_to_2h.smd fps 30.0
scene seq/2h_to_1h.smd fps 30.0
scene seq/block_start.smd fps 30.0
scene seq/block_idle.smd fps 30.0
scene seq/block_end.smd fps 30.0
