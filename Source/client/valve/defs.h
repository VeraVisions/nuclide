/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
