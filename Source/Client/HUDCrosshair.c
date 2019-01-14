/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

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
