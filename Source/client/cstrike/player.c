/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

.float pmove_frame;

.vector netorigin;
.vector netangles;
.vector netvelocity;
.float netflags;
.float netpmove_flags;

string sPModels[CS_WEAPON_COUNT - 1] = {
	"models/p_knife.mdl",
	"models/p_usp.mdl",
	"models/p_glock18.mdl",
	"models/p_deagle.mdl",
	"models/p_p228.mdl",
	"models/p_elite.mdl",
	"models/p_fiveseven.mdl",
	"models/p_m3.mdl",
	"models/p_xm1014.mdl",
	"models/p_mp5.mdl",
	"models/p_p90.mdl",
	"models/p_ump45.mdl",
	"models/p_mac10.mdl",
	"models/p_tmp.mdl",
	"models/p_ak47.mdl",
	"models/p_sg552.mdl",
	"models/p_m4a1.mdl",
	"models/p_aug.mdl",
	"models/p_scout.mdl",
	"models/p_awp.mdl",
	"models/p_g3sg1.mdl",
	"models/p_sg550.mdl",
	"models/p_m249.mdl",
	"models/p_c4.mdl",
	"models/p_flashbang.mdl",
	"models/p_hegrenade.mdl",
	"models/p_smokegrenade.mdl"
};
