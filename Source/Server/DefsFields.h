/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

// Generic entity fields
.void() PlayerUse;
.int iBleeds;
.void(int iHitBody) vPain;
.void(int iHitBody) vDeath;
.entity eUser;
.float material;

// Player specific fields
.float fInBuyZone;
.float fInHostageZone;
.float fInBombZone;
.float fInEscapeZone;
.float fInVIPZone;
.float fMoney;
.float fStepTime;
.float fCharModel;
.float fDeaths;
.float fProgressBar;
.float armor;
.int iEquipment;
.int iInGame;

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

