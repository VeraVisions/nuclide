/*
OpenCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

weaponinfo_t wptTable[ CS_WEAPON_COUNT ] = {
	{ 0, 0, 0, 0, 240, 0, 0, 0, 0, 0.0, 0.0, 0, 0.0, 0.0, iAmmo_9MM, iAmmo_9MM, 0.0, 0.0, 0.0, 0, 0 },
	wptKNIFE,
	wptUSP45,
	wptGLOCK18,
	wptDEAGLE,
	wptP228,
	wptELITES,
	wptFIVESEVEN,
	wptM3,
	wptXM1014,
	wptMP5,
	wptP90,
	wptUMP45,
	wptMAC10,
	wptTMP,
	wptAK47,
	wptSG552,
	wptM4A1,
	wptAUG,
	wptSCOUT,
	wptAWP,
	wptG3SG1,
	wptSG550,
	wptPARA,
	wptC4BOMB
};

#ifdef SSQC
.int iShotMultiplier;
.float fDecreaseShotTime;
.int iOldShotMultiplier;
#else 
int iShotMultiplier;
#endif

void OpenCSGunBase_ShotMultiplierHandle( float fShots ) {
#ifdef SSQC
	if ( self.iShotMultiplier > 12 ) {
		self.iShotMultiplier = 12;
	} else {
		self.iShotMultiplier += fShots;
	}
	self.fDecreaseShotTime = time + 0.2;
#else
	if ( iShotMultiplier > 12 ) {
		iShotMultiplier = 12;
	} else {
		iShotMultiplier += fShots;
	}
#endif
}

#ifdef SSQC

// This is being triggered in PlayerPreThink after the input
void OpenCSGunBase_ShotMultiplierUpdate( void ) {
	if ( ( self.iShotMultiplier > 0 ) && ( self.fDecreaseShotTime < time ) ) {
		self.fDecreaseShotTime = time + wptTable[ self.weapon ].fAttackFinished + 0.01;
		self.iShotMultiplier--;
	}	
}

void OpenCSGunBase_Draw( void ) {
	self.iCurrentMag = self.(wptTable[ self.weapon ].iMagfld);
	self.iCurrentCaliber = self.(wptTable[ self.weapon ].iCaliberfld);
	Client_SendEvent( self, EV_WEAPON_DRAW );
}

void OpenCSGunBase_AccuracyCalc( void ) {
	self.fAccuracy = ( self.iShotMultiplier / wptTable[ self.weapon ].fAccuracyDivisor );
}

// Returns whether or not to play an animation
float OpenCSGunBase_PrimaryFire( void ) {
	// Nothing in the clip anymore? Don't even attempt
	if ( ( self.(wptTable[ self.weapon ].iMagfld) - 1 ) < 0 ) {
		return FALSE;
	}
	
	if ( wptTable[ self.weapon ].fWeaponType == TYPE_SEMI ) {
		self.flags = self.flags - ( self.flags & FL_SEMI_TOGGLED );
	}
	
	OpenCSGunBase_ShotMultiplierHandle( wptTable[ self.weapon ].iBullets );
	OpenCSGunBase_AccuracyCalc();
	TraceAttack_FireBullets( wptTable[ self.weapon ].iBullets, ( self.origin + self.view_ofs ) );
	Animation_ShootWeapon();
	
	self.(wptTable[ self.weapon ].iMagfld) -= 1;
	self.fAttackFinished = time + wptTable[ self.weapon ].fAttackFinished;
	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	return TRUE;
}

float OpenCSGunBase_Reload( void ) {
	static void OpenCSGunBase_FinishReload( void ) {
		// What if we've got less in our caliberfield than we need
		if ( self.(wptTable[ self.weapon ].iCaliberfld) < wptTable[ self.weapon ].iMagSize ) {
			self.(wptTable[ self.weapon ].iMagfld) = self.(wptTable[ self.weapon ].iCaliberfld);
			self.(wptTable[ self.weapon ].iCaliberfld) = 0;
		} else {
			self.(wptTable[ self.weapon ].iCaliberfld) -= ( wptTable[ self.weapon ].iMagSize - self.(wptTable[ self.weapon ].iMagfld) );
			self.(wptTable[ self.weapon ].iMagfld) = wptTable[ self.weapon ].iMagSize;
		}
		
		Weapon_UpdateCurrents();
	}
	
	// Don't bother reloading the gun when full
	if ( self.(wptTable[ self.weapon ].iMagfld) == wptTable[ self.weapon ].iMagSize ) {
		return FALSE;
	}
	
	// Also don't bother reloading the gun if you've got nothing to reload it with
	if ( self.(wptTable[ self.weapon ].iCaliberfld) <= 0 ) {
		return FALSE;
	}
	
	
	self.think = OpenCSGunBase_FinishReload;
	self.nextthink = time + wptTable[ self.weapon ].fReloadFinished;
	self.fAttackFinished = self.nextthink;
	
	Animation_ReloadWeapon();
	Client_SendEvent( self, EV_WEAPON_RELOAD );
	return TRUE;
}
#endif
