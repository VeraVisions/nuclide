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
	1,					// Max Inaccuracy
	8,
	4
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
	static float fBeepTime; // Used for the beeping sounds that last 1.5 seconds
	static float fDefuseProgress; // Used to track... the progress
	
	static void C4BombThink( void ) {
		// If the guy who started using us stopped using us, reset the defuser counter
		if ( ( self.eUser != world ) && ( self.eUser.button6 == FALSE ) ) {
			self.eUser.fProgressBar = 0;
			self.eUser = world;
			fDefuseProgress = 0;
		}
		
		// If our time has passed, explode
		if ( self.fAttackFinished < time ) {
			Rules_RoundOver( TEAM_T, 3500, FALSE );
			sound( self, CHAN_VOICE, "weapons/c4_explode1.wav", 1.0, ATTN_NONE );
			Damage_Radius( self.origin, self.owner, 500, 1024 );
			remove( self );
			iBombPlanted = FALSE;
			return;
		}
		
		// Only play sounds every once in a while
		if ( fBeepTime > time ) {
			return;
		}
		fBeepTime = time + 1.5;
		
		if ( self.fAttackFinished - time < 2 ) {
			sound( self, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NONE );
		} else if ( self.fAttackFinished - time < 5 ) {
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
	}
	static void C4BombUse( void ) {
		if ( eActivator.team != TEAM_CT ) {
			return;
		}
		
		// On first use, play defusing sound
		if ( self.eUser == world ) {
			sound( self, CHAN_VOICE, "weapons/c4_disarm.wav", 1.0, ATTN_NORM );
		}
		
		// Takes 10 seconds to defuse that thing!
		if ( fDefuseProgress > 10 ) {
			sound( self, CHAN_VOICE, "weapons/c4_disarmed.wav", 1.0, ATTN_NORM );
			Rules_RoundOver( TEAM_CT, 3500, TRUE );
			Radio_BroadcastMessage( RADIO_BOMBDEF );
			eActivator.fProgressBar = 0;
			iBombPlanted = FALSE;
			remove( self );
			return;
		}
		
		// If the user has the right equipment, make 10 seconds pass twice as fast
		if ( eActivator.iEquipment & EQUIPMENT_DEFUSALKIT ) {
			fDefuseProgress += ( frametime * 2 );
		} else {
			fDefuseProgress += frametime;
		}
		
		eActivator.fProgressBar = (fDefuseProgress * 0.1);
		
		// Makesure C4BombThink knows who the user is
		self.eUser = eActivator;
	}
	
	// Do all the dirty entspawning stuff
	entity eBomb = spawn();
	eBomb.classname = "c4bomb";
	setorigin( eBomb, vBombPos );
	setmodel( eBomb, "models/w_c4.mdl" );
	eBomb.solid = SOLID_BBOX;
	eBomb.customphysics = C4BombThink;
	eBomb.fAttackFinished = time + autocvar_mp_c4timer;
	eBomb.vUse = C4BombUse;
	eBomb.iUsable = TRUE;
	
	sound( eBomb, CHAN_WEAPON, "weapons/c4_plant.wav", 1.0, ATTN_IDLE );
	
	// Broadcast the bomb state
	Radio_BroadcastMessage( RADIO_BOMBPL );
	iBombPlanted = TRUE;
	
	// Tell the bomb-planter to get rid of the weapon!
	self.fSlotGrenade = self.fSlotGrenade - WEAPON_C4BOMB;
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
	
	// If we aren't aiming at a place or look in the wrong location... stop it
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
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 1.18 );
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 1.42 );
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 1.63 );
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 1.88 );
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 2.12 );
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 2.36 );
	Sound_Delayed( "weapons/c4_click.wav", 1.0, 2.55 );
#endif
}
