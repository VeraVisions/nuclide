/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

// Because padding...
weaponinfo_t wptDEFAULT = { 0, 0, 0, 0, 240, 0, 0, 0, 0, 0.0, 0.0, 0, 0.0, 0.0, iAmmo_9MM, iAmmo_9MM, 0.0, 0.0, 0.0 };

weaponinfo_t wptTable[ CS_WEAPON_COUNT ] = {
	wptDEFAULT,
	wptDEFAULT,
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
	wptPARA
};

#ifdef SSQC
void OpenCSGunBase_Draw( void ) {
		self.iCurrentClip = self.(wptTable[ self.weapon ].iClipfld);
		self.iCurrentCaliber = self.(wptTable[ self.weapon ].iCaliberfld);
		Client_SendEvent( self, EV_WEAPON_DRAW );
}

void OpenCSGunBase_AccuracyCalc( void ) {
	self.fAccuracy = 3 / wptTable[ self.weapon ].fAccuracyDivisor;
}

// Returns whether or not to play an animation
float OpenCSGunBase_PrimaryFire( void ) {
	// Nothing in the clip anymore? Don't even attempt
	if ( ( self.(wptTable[ self.weapon ].iClipfld) - 1 ) < 0 ) {
		return FALSE;
	}
	
	OpenCSGunBase_AccuracyCalc();
	TraceAttack_FireBullets( wptTable[ self.weapon ].iBullets );
	
	self.(wptTable[ self.weapon ].iClipfld) -= 1;
	self.fAttackFinished = time + wptTable[ self.weapon ].fAttackFinished;
	
	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	return TRUE;
}

float OpenCSGunBase_Reload( void ) {
	// Don't bother reloading the gun when full
	if ( self.(wptTable[ self.weapon ].iClipfld) == wptTable[ self.weapon ].iClipSize ) {
		return FALSE;
	}
	
	// Also don't bother reloading the gun if you've got nothing to reload it with
	if ( self.(wptTable[ self.weapon ].iCaliberfld) <= 0 ) {
		return FALSE;
	}
	
	if ( self.(wptTable[ self.weapon ].iCaliberfld) < wptTable[ self.weapon ].iClipSize ) {
		self.(wptTable[ self.weapon ].iClipfld) = self.(wptTable[ self.weapon ].iCaliberfld);
		self.(wptTable[ self.weapon ].iCaliberfld) = 0;
	} else {
		self.(wptTable[ self.weapon ].iClipfld) = wptTable[ self.weapon ].iClipSize;
		self.(wptTable[ self.weapon ].iCaliberfld) -= wptTable[ self.weapon ].iClipSize;
	}
	
	self.fAttackFinished = time + wptTable[ self.weapon ].fReloadFinished;
	
	Client_SendEvent( self, EV_WEAPON_RELOAD );
	return TRUE;
}
#endif
