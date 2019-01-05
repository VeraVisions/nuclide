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


// All about +use
.void(void) vUse;
.int iUsable;

// Generic entity fields
.void() PlayerUse;
.int iBleeds;
.void(int iHitBody) vPain;
.void(int iHitBody) vDeath;
.float fRespawns;
.entity eUser;
.float material;

/* Respawnable/reset entity fields */
.string sOldModel;
.float fOldSolid;
.float fOldHealth;
.vector vOldOrigin;
.vector vOldAngle;
.void() vRespawn;
.void() vOldUse;

// Player specific fields
.float fInBuyZone;
.float fInHostageZone;
.float fInBombZone;
.float fInEscapeZone;
.float fInVIPZone;
.float fMoney;
.float fStepTime;
.int iInGame;
.float fCharModel;
.float fDeaths;
.int iEquipment;
.float armor;
.float fProgressBar;

// Weapon specific fields
.int iCurrentMag;
.int iCurrentCaliber;
.float fSlotMelee;
.float fSlotPrimary;
.float fSlotSecondary;
.float fSlotGrenade;
.float fSlotC4Bomb;
.float fAttackFinished;
.float fRadioFinished;
.float fAccuracy;

/* Map Entity Specific Fields /*
 * They used to be in their respective files, but there is not much point */

/* armoury_entity */
.float item;
.float count;

/* env_explosion */
.int iMagnitude;

/* env_spark */
.float MaxDelay;

/* func_button || func_door */
.float speed;
.float lip;
.float dmg;
.float state;
.vector pos1;
.vector pos2;
.float movesnd;
.float stopsnd;

/* func_door_rotating */
.float distance;

/* func_vehicle */
.entity eDriver;
.entity eVehicle;
.float height;

/* infodecal */
.string texture;

/* light */
.string pattern;
