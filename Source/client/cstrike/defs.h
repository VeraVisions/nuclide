/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

// Clientside cvars
var vector autocvar_cross_color = '0 255 0'; // autocvar of "cross_color"

var int autocvar_cl_radar = 1;

// Particle stuff
var float PARTICLE_SMOKEGRENADE;

.float flUpAngle;

vector vHUDColor; // Defined in HUD_Draw (HUD.c)
vector vVGUIColor; // Defined in HUD_Draw (VGUI.c)
vector vCrossColor; // Defined in HUD_Draw (HUDCrosshair.c)

string sShellModel [ 4 ] = {
	"models/pshell.mdl",
	"models/rshell.mdl",
	"models/rshell_big.mdl",
	"models/shotgunshell.mdl"
};


var string autocvar_skins_dir = "";
string sViewModels[ CS_WEAPON_COUNT - 1 ] = {
	"v_knife.mdl",
	"v_usp.mdl",
	"v_glock18.mdl",
	"v_deagle.mdl",
	"v_p228.mdl",
	"v_elite.mdl",
	"v_fiveseven.mdl",
	"v_m3.mdl",
	"v_xm1014.mdl",
	"v_mp5.mdl",
	"v_p90.mdl",
	"v_ump45.mdl",
	"v_mac10.mdl",
	"v_tmp.mdl",
	"v_ak47.mdl",
	"v_sg552.mdl",
	"v_m4a1.mdl",
	"v_aug.mdl",
	"v_scout.mdl",
	"v_awp.mdl",
	"v_g3sg1.mdl",
	"v_sg550.mdl",
	"v_m249.mdl",
	"v_c4.mdl",
	"v_flashbang.mdl",
	"v_hegrenade.mdl",
	"v_smokegrenade.mdl"
};


struct
{
//Viewmodel stuff
	entity eViewModel;
	entity eMuzzleflash;
	float fNumBones;
	float fEjectBone;
	vector vPunchAngle;
	float fLastWeapon;
	float fBobTime;
	float fBob;

//Player fields
	entity ePlayer;
	vector vPlayerOrigin;
	vector vPlayerOriginOld;
	vector vPlayerVelocity;
	float fPlayerFlags;
	
// Camera Fields
	//entity ePlayerEnt;
	vector vCameraPos;
	vector vCameraAngle;
	float fCameraTime;
	
// Flashbang'd
	float fFlashTime;
	float fFlashAlpha;
	
//UI fields
	float fVGUI_Display;	// The VGUI menu currently being drawn
	int iShowScores;	// This is seperated from the other VGUI stuff so we can check scores while buying and whatnot
	
	// Testing
	int iOverview;
	int iMapExpand;
	float fMapLerp;
	
//crosshair
	int iOldShotMultiplier;
	float fCrosshairDistance;
	float fDecreaseShotTime;
	int iShotMultiplier;
	
//buy menu
	// We can only carry one item per slot, so this is hacking around the last one
	int iHUDGrenades;
	int iHUDGrenadesSelected;
	float fHUDWeaponSelectTime;
	float fHUDWeaponSelected;
} seats[4], *pSeat;

// Sound Stuff
//.string sSoundSample;
//.float fVolume;
string HUD_GetChatColorHEX( float fTeam );

// For the player entity
.entity eGunModel;
float fWeaponEventPlayer;
.float fWeaponLast;
.float fWeaponBoneID;
.float health;
.float oldhealth;

void Animation_ShootWeapon( entity ePlayer );
void Animation_ReloadWeapon( entity ePlayer );
