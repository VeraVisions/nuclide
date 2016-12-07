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

#ifdef SSQC
.float fBombProgress;
#else
int iBombProgress;
#endif

// Weapon Info
weaponinfo_t wptC4BOMB = { 
	WEAPON_C4BOMB, 		// Identifier
	SLOT_GRENADE,
	0, 					// Price
	CALIBER_50AE, 		// Caliber ID
	1.0, 				// Max Player Speed
	0, 					// Bullets Per Shot
	0, 					// Clip/MagSize
	500, 				// Damage
	1, 					// Penetration Multiplier
	64, 				// Bullet Range
	1,	 				// Range Modifier
	TYPE_AUTO,
	0.0, 				// Attack-Delay
	0.0, 				// Reload-Delay
	iAmmo_9MM, 			// Caliber Pointer
	iAmmo_9MM, 			// Clip Pointer
	1,					// Accuracy Divisor
	1,					// Accuracy Offset
	1					// Max Inaccuracy
};

// Anim Table
enum {
	ANIM_C4_IDLE,
	ANIM_C4_DRAW,
	ANIM_C4_DROP,
	ANIM_C4_ENTERCODE
};

#ifdef SSQC
void WeaponC4BOMB_Drop( vector vBombPos ) {
	static void c4bomb_think( void ) {
		if ( self.fAttackFinished < time ) {
			Rules_RoundOver( TEAM_T );
			// EXPLODE!
			sound( self, CHAN_VOICE, "weapons/c4_explode1.wav", 1.0, ATTN_NONE );
			Damage_Radius( self.origin, self.owner, 500, 1024 );
			remove( self );
			return;
		}
		
		if ( self.fAttackFinished - time < 5 ) {
			sound( self, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NORM );
		} else if ( self.fAttackFinished - time < 10 ) {
			sound( self, CHAN_VOICE, "weapons/c4_beep4.wav", 1.0, ATTN_NORM );
		} else if ( self.fAttackFinished - time < 20 ) {
			sound( self, CHAN_VOICE, "weapons/c4_beep3.wav", 1.0, ATTN_NORM );
		} else if ( self.fAttackFinished - time < 30 ) {
			sound( self, CHAN_VOICE, "weapons/c4_beep2.wav", 1.0, ATTN_NORM );
		} else {
			sound( self, CHAN_VOICE, "weapons/c4_beep1.wav", 1.0, ATTN_NORM );
		}
		self.nextthink = time + 1.5;
	}
	
	entity eBomb = spawn();
	setorigin( eBomb, vBombPos );
	setmodel( eBomb, "models/w_c4.mdl" );
	eBomb.think = c4bomb_think;
	eBomb.nextthink = time + 1.5;
	eBomb.fAttackFinished = time + 45;
	sound( eBomb, CHAN_WEAPON, "weapons/c4_plant.wav", 1.0, ATTN_IDLE );
	
	Radio_BroadcastMessage( RADIO_BOMBPL );
	
	Weapon_SwitchBest();
}
#endif

void WeaponC4BOMB_Draw( void ) {
#ifdef SSQC
	Client_SendEvent( self, EV_WEAPON_DRAW );
#else
	View_PlayAnimation( ANIM_C4_DRAW );
#endif
}

void WeaponC4BOMB_Release( void ) {
#ifdef SSQC
	self.fBombProgress = 0;
#else
	View_PlayAnimation( ANIM_C4_IDLE );
	iBombProgress = 0;
#endif
}

void WeaponC4BOMB_PrimaryFire( void ) {
#ifdef SSQC
	makevectors( self.v_angle );
	traceline( self.origin + self.view_ofs, self.origin + self.view_ofs + ( v_forward * 64 ), FALSE, self );
	
	if ( trace_fraction == 1 || self.fInBombZone == FALSE ) {
		WeaponC4BOMB_Release();
		self.fAttackFinished = time + 1.0;
		return;
	}
	
	// Play the sequence at the start
	if ( self.fBombProgress == 0 ) {
		Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	}
	
	// Add onto the planting-time thing
	self.fBombProgress += frametime;
	
	// 3 seconds have passed, plant the bomb
	if ( self.fBombProgress >= 3.0 ) {
		WeaponC4BOMB_Drop( trace_endpos );
	}
#else
	View_PlayAnimation( ANIM_C4_ENTERCODE );
#endif
}
