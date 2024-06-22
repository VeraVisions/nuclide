output ../v_pistol.vvm
materialprefix /models/weapons/v_pistol/

geomset 0 0
	scene ref/enforcer_R.smd
geomset 0 1
	scene ref/enforcer_L.smd
rotate 0 -90 0

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
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot1.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot1_last.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_shoot2.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
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
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1002 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/single_aim_shoot.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
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
	scene seq/dual_idle.smd fps 24
	scene seq/dual_idle_Lempty.smd fps 24
	scene seq/dual_idle_Rempty.smd fps 24
	scene seq/dual_idle_Bempty.smd fps 24

event reset
event 0 1004 "weapons/akimbo/draw5.wav 1"
	scene seq/dual_draw_Lgun.smd fps 24

event reset
event 0 1004 "weapons/akimbo/draw5.wav 1"
	scene seq/dual_draw_Lgun_empty.smd fps 24

event reset
event 0 1004 "weapons/akimbo/draw2.wav 1"
	scene seq/dual_draw1.smd fps 24

event reset
event 0 1004 "weapons/akimbo/draw2.wav 1"
	scene seq/dual_draw1_empty.smd fps 24

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
	scene seq/dual_holster.smd fps 16

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
	scene seq/dual_holster_empty.smd fps 16

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
	scene seq/dual_holster_Lgun.smd fps 16

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
	scene seq/dual_holster_Lgun_empty.smd fps 16

event reset
event 9 1004 "weapons/enforcer/holster.wav 1"
event 27 1004 "weapons/akimbo/draw5.wav 1"
	scene seq/dual_reload01.smd fps 24

event reset
event 9 1004 "weapons/enforcer/holster.wav 1"
event 27 1004 "weapons/akimbo/draw5.wav 1"
	scene seq/dual_reload01_empty.smd fps 24

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
event 23 1004 "weapons/akimbo/magtoss.wav 1"
event 35 1004 "weapons/enforcer/clipout.wav 1"
event 36 1004 "weapons/akimbo/clipout.wav 1"
event 56 1004 "weapons/enforcer/clipin.wav 1"
event 58 1004 "weapons/akimbo/clipin.wav 1"
event 70 1004 "weapons/akimbo/draw2.wav 1"
	scene seq/dual_reload02.smd fps 24

event reset
event 0 1004 "weapons/enforcer/holster.wav 1"
event 24 1004 "weapons/akimbo/magtoss.wav 1"
event 35 1004 "weapons/enforcer/clipout.wav 1"
event 36 1004 "weapons/akimbo/clipout.wav 1"
event 56 1004 "weapons/enforcer/clipin.wav 1"
event 58 1004 "weapons/akimbo/clipin.wav 1"
event 70 1004 "weapons/akimbo/draw2.wav 1"
event 93 1004 "weapons/enforcer/slide.wav 1"
event 94 1004 "weapons/akimbo/slide.wav 1"
	scene seq/dual_reload02_empty.smd fps 24

event reset
event 10 1004 "weapons/akimbo/clipout.wav 1"
event 11 1004 "weapons/enforcer/clipout.wav 1"
event 28 1004 "weapons/akimbo/magtoss.wav 1"
event 52 1004 "weapons/akimbo/clipin.wav 1"
event 74 1004 "weapons/akimbo/magtoss.wav 1"
event 106 1004 "weapons/enforcer/clipin.wav 1"
event 139 1004 "weapons/enforcer/draw5.wav 1"
	scene seq/dual_reload03.smd fps 24

event reset
event 10 1004 "weapons/akimbo/clipout.wav 1"
event 11 1004 "weapons/enforcer/clipout.wav 1"
event 28 1004 "weapons/akimbo/magtoss.wav 1"
event 52 1004 "weapons/akimbo/clipin.wav 1"
event 74 1004 "weapons/akimbo/slide.wav 1"
event 74 1004 "weapons/akimbo/magtoss.wav 1"
event 106 1004 "weapons/enforcer/clipin.wav 1"
event 128 1004 "weapons/enforcer/slide.wav 1"
event 139 1004 "weapons/enforcer/draw5.wav 1"
	scene seq/dual_reload03_empty.smd fps 24

event reset
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_L1.smd fps 24

event reset
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_L1_Bempty.smd fps 24

event reset
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_L1_last.smd fps 24

event reset
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_L1_Rempty.smd fps 24

event reset
	scene seq/dual_shoot_Bempty_L.smd fps 24


event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_L2.smd fps 24

event reset
	scene seq/dual_shoot_L2_Bempty.smd fps 24


event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
		scene seq/dual_shoot_L2_last.smd fps 24

event reset
	scene seq/dual_shoot_L2_Rempty.smd fps 24

event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/dual_shoot_R1.smd fps 24

event reset
	scene seq/dual_shoot_R1_Bempty.smd fps 24

event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/dual_shoot_R1_last.smd fps 24

event reset
	scene seq/dual_shoot_R1_Lempty.smd fps 24
	scene seq/dual_shoot_Bempty_R.smd fps 24

event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/dual_shoot_R2.smd fps 24

event reset
	scene seq/dual_shoot_R2_Bempty.smd fps 24

event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
	scene seq/dual_shoot_R2_last.smd fps 24

event reset
	scene seq/dual_shoot_R2_Lempty.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_both_L1_R1.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_both_L1_R2.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_both_L2_R1.smd fps 24

event reset
event 0 1001 "71 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1006 "63 0 0 60"
event 0 1005 "71 1"
event 0 1009 "28 models/effects/muzzleflash/muzzleflash1.vvm"
event 0 1007 "30 0 0 -60"
event 0 1005 "28 1"
	scene seq/dual_shoot_both_L2_R2.smd fps 24
