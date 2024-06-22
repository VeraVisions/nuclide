output animations.vvm
rotate 0 -90 0
origin -8 0 -36

// animations
// some variants of animations are exclusive to certain teams to give them more personality
// e.g. the USMC raiders would have some semblance of military training so more tactical poses
// and less exaggerated signs of pain when attacked, regulators would have a gunslinger akimbo
// type pose, etc.

scene ref_empty.smd

// movement
scene animations/all_idle.smd fps 18.0 loop 
scene animations/bottom_walk.smd fps 35.0 loop
scene animations/bottom_run.smd fps 35.0 loop
scene animations/jump.smd fps 60.0

origin -12 0 -18
scene animations/crouch_idle.smd fps 14.0 loop
scene animations/crouch_crawl.smd fps 22.0 loop
origin -8 0 -36

scene animations/fists_shoot_R.smd fps 30
scene animations/fists_shoot_L.smd fps 30
scene animations/fists_shove.smd fps 30
scene animations/top_holster.smd fps 30

scene animations/new_shoot_single.smd fps 30 loop

event 0 1010 ""
scene animations/new_shoot_single_animated.smd fps 30
event reset

scene animations/new_shoot_dual.smd fps 30
event reset

scene animations/new_shoot_rifle.smd fps 30 loop
event reset

event 0 1010 ""
scene animations/new_shoot_rifle_animated.smd fps 30
event reset

scene animations/throw_idle.smd fps 18 loop
scene animations/throw_throw.smd fps 18
scene animations/top_singlereload.smd fps 30
scene animations/top_dualreload.smd fps 30
scene animations/top_strike1.smd fps 60
scene animations/top_strike2.smd fps 60
scene animations/top_strike3.smd fps 60

scene animations/die_fall.smd fps 25.0 
scene animations/die_forwards.smd fps 25.0 
scene animations/die_headshot01.smd fps 20.0 
scene animations/die_headshot02.smd fps 25.0 
scene animations/die_gutshot.smd fps 20.0 
scene animations/die_running01.smd fps 30.0 
scene animations/die_running02.smd fps 50.0 
scene animations/die_simple.smd fps 30.0 
scene animations/die_torso.smd fps 30.0 
scene animations/die_explosion_back.smd fps 25.0 
scene animations/die_explosion_front.smd fps 25.0 
scene animations/die_suicide.smd fps 25.0
scene animations/car_sit_idle.smd fps 25.0
scene animations/limping.smd fps 25.0 loop
scene animations/healing.smd fps 15.0 loop
scene animations/top_riflereload.smd fps 10.0
scene animations/shot_goto_reload.smd fps 10.0
scene animations/shot_reload.smd fps 10.0
scene animations/shot_end_reload.smd fps 10.0

scene animations/new_dual_idle.smd fps 10.0
scene animations/new_dual_shootleft.smd fps 10.0
scene animations/new_dual_shootright.smd fps 10.0

scene animations/flamethrower_idle.smd fps 10.0
scene animations/flamethrower_shoot.smd fps 10.0

