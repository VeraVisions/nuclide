/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
HUD_DrawCrosshair

Draws the cursor every frame, unless spectator
=================
*/
void HUD_DrawCrosshair(void) {	
	int iCrosshairDistance;
	int iLineLength;

	// Weapon Info Tables have got Mins and Deltas they are willing to share
	float fDistance = wptTable[getstatf(STAT_ACTIVEWEAPON)].iCrosshairMinDistance; 
	float fDeltaDistance = wptTable[getstatf(STAT_ACTIVEWEAPON)].iCrosshairDeltaDistance;

	if (iNightVision == FALSE) {
		vCrossColor = autocvar_cross_color * (1 / 255);
	} else {
		vCrossColor = [1.0f,0.0f,0.0f];
	}

	if (!(getstatf(STAT_FLAGS) & FL_ONGROUND)) { // If we are in the air...
		fDistance = fDistance * 2;
	} else if (getstatf(STAT_FLAGS) & FL_CROUCHING) { // Crouching...
		fDistance = fDistance * 0.5;
	} else if (vlen(pSeat->ePlayer.velocity) > 120) { // Running, not walking
		fDistance = fDistance * 1.5;
	}

	// The amount of shots that we've shot totally does affect our accuracy!
	if (pSeat->iShotMultiplier > pSeat->iOldShotMultiplier) {
		pSeat->fCrosshairDistance = min(15, pSeat->fCrosshairDistance + fDeltaDistance);
	} else if (pSeat->fCrosshairDistance > fDistance) {
		// Slowly decrease the distance again
		pSeat->fCrosshairDistance -= (pSeat->fCrosshairDistance * frametime);
		
		if ((pSeat->iShotMultiplier > 0) && (pSeat->fDecreaseShotTime < time)) {
			pSeat->fDecreaseShotTime = time + 0.2;
			pSeat->iShotMultiplier--;
		}
	}

	pSeat->iOldShotMultiplier = pSeat->iShotMultiplier;
	
	if (pSeat->fCrosshairDistance < fDistance) {
		 pSeat->fCrosshairDistance = fDistance;
	}

	iCrosshairDistance = ceil(pSeat->fCrosshairDistance);
	iLineLength = max(1, ((iCrosshairDistance - fDistance) / 2) + 5);

	// Line positions
	vector vVer1, vVer2, vHor1, vHor2;
	vVer1 = vVer2 = vHor1 = vHor2 = vVideoMins;

	// Vertical Lines
	vVer1[0] += (vVideoResolution[0] / 2);
	vVer1[1] += (vVideoResolution[1] / 2) - (iCrosshairDistance + iLineLength);
	vVer2[0] += (vVideoResolution[0] / 2);
	vVer2[1] += (vVideoResolution[1] / 2) + iCrosshairDistance + 1;

	// Horizontal Lines
	vHor1[0] += (vVideoResolution[0] / 2) - (iCrosshairDistance + iLineLength);
	vHor1[1] += (vVideoResolution[1] / 2);
	vHor2[0] += (vVideoResolution[0] / 2) + iCrosshairDistance + 1;
	vHor2[1] += (vVideoResolution[1] / 2);

	drawfill(vVer1, [1, iLineLength], vCrossColor, 1, DRAWFLAG_ADDITIVE);
	drawfill(vVer2, [1, iLineLength], vCrossColor, 1, DRAWFLAG_ADDITIVE);
	drawfill(vHor1, [iLineLength, 1], vCrossColor, 1, DRAWFLAG_ADDITIVE);
	drawfill(vHor2, [iLineLength, 1], vCrossColor, 1, DRAWFLAG_ADDITIVE);
}


/*
=================
HUD_DrawSimpleCrosshair

Draws a simple HL crosshair
=================
*/
void HUD_DrawSimpleCrosshair(void)
{
	static vector cross_pos;
	
	// Draw the scope in the middle, seperately from the border
	cross_pos = (vVideoResolution / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [0.1875,0], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
}
