/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

// Clientside cvars
var vector autocvar_cross_color = '0 255 0'; // autocvar of "cross_color"

var int autocvar_cl_radar = 1;

// Particle stuff
var float PARTICLE_SMOKEGRENADE;

.float flUpAngle;

vector vHUDColor; // Defined in HUD_Draw (HUD.c)
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
	vector punchangle;
	float fLastWeapon;
	float fBobTime;
	float fBob;
	float damage_alpha;
	vector damage_pos;
	
	/* Camera Bob */
	float flCamMove;
	float flCamTime;
	int iCamCycle;
	float flCamFracSin;
	float flCamDelta;

	int iZoomed;
	float flZoomTime;

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

	int iInputAttack2;
	int iInputReload;
	int iInputUse;
	int iInputDuck;

	float fInputSendNext;
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

/*
====================
HUD_GetChatColor

Returns an RGB color vector for the specified team
====================
*/
vector HUD_GetChatColor( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return '0.45 0.60 0.75';
	} else if ( fTeam == TEAM_T ) {
		return '0.75 0.1875 0.1875';
	} else {
		return '0.75 0.75 0.75';
	}
}

/*
====================
HUD_GetChatColor

Returns a HEX color string prefix for the specified team
====================
*/
string HUD_GetChatColorHEX( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return "^x7AC";
	} else if ( fTeam == TEAM_T ) {
		return "^xC33";
	} else {
		return "^xCCC";
	}
}

/*
====================
HUD_GetChatColor

Returns a HEX color string prefix with teamname
====================
*/
string HUD_GetChatColorHEXTeam( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return "^x7AC(Counter-Terrorist) ";
	} else if ( fTeam == TEAM_T ) {
		return "^xC33(Terrorist) ";
	} else {
		return "^xCCC(Spectator) ";
	}
}
