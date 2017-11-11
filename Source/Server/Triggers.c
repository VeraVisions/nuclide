/*
FreeCS Project
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

// This is what they use...
.string killtarget;
.float wait;
.float delay;
.float dmg;

/*
=================
trigger_multiple

This entity triggers a specified target every time its area is entered by players, monsters or pushables.

Attributes:
Target (target) - When an entity is activated, it triggers the entity with the name specified by Target.
Name (targetname) - Property used to identify entities.
Master (master) - The name of a multisource (or game_team_master) entity. A master must usually be active in order for the entity to work. Thus they act almost like an on/off switch, in their simplest form, and like an AND gate in the case of the multisource.
Delay before trigger (delay) - Usually the time in seconds before an entity should trigger its target (after being triggered itself). Under other SmartEdit names, delay might also be the time to wait before performing some other action.
Kill target (killtarget) - Remove this entity from the game when triggered
Target Path (netname)
Sound style (sounds)
Message (message)
Delay before reset (wait) - Time in seconds before the entity is ready to be re-triggered.

Flags:
Monsters (1) - Allow monsters to activate this entity.
No Clients (2) - Players cannot activate this entity.
Pushables (4) - Allow pushable objects to activate this entity.
=================
*/
void trigger_multiple( void ) {
	static void trigger_multiple_trigger( void ) {
		Entities_UseTargets();
		
		if ( self.killtarget ) {
			entity eFind = findchain( killtarget, self.target );
			entity eOld = self;
			while ( eFind ) {
				entity eRemoveMe = eFind;
				self = eRemoveMe;
				Entities_Remove();
				
				eFind = eFind.chain;
			}
			self = eOld;
		}
	}
	
	static void trigger_multiple_use( void ) {
		if ( self.delay ) {
			self.think = trigger_multiple_trigger;
			self.nextthink = self.ltime + self.delay;
		} else {
			trigger_multiple_trigger();
		}
	}
	
	static void trigger_multiple_touch( void ) {
		if ( self.fAttackFinished > self.ltime ) {
			return;
		}
		
		if ( other.classname == "player" ) {
			trigger_multiple_use();
			self.fAttackFinished = self.ltime + self.wait;
		}
	}
	
	self.angles = '0 0 0';
	self.solid = SOLID_TRIGGER;

	setmodel( self, self.model );
	self.model = 0;
	
	self.vUse = trigger_multiple_use;
	self.touch = trigger_multiple_touch;
}

/*
=================
trigger_camera
=================
*/
void trigger_camera( void ) {
	static void trigger_camera_use( void ) {
		if ( self.target ) {
			entity eTarget = find( world, targetname, self.target );
			if ( eTarget ) {
				self.angles = vectoangles( eTarget.origin - self.origin );
				self.angles_x *= -1;
			}
		}
		Client_TriggerCamera( eActivator, self.origin, self.angles, self.wait );
	}
	
	self.vUse = trigger_camera_use;
}

/*
=================
trigger_hurt

Brush that damages things, especially players
=================
*/
#define SF_HURT_ONCE 			1 // Turn off once it fired the first time
#define SF_HURT_OFF 			2 // Needs to be triggered in order to work again
#define SF_HURT_NOPLAYERS 		8 // Don't hurt players
#define SF_HURT_FIREONPLAYER 	16 // Only call UseTarget functions when it's a player
#define SF_HURT_TOUCHPLAYER 	32 // Only hurt players

void trigger_hurt( void ) {
	static void trigger_hurt_use( void ) {
		if ( self.solid == SOLID_NOT ) {
			self.solid = SOLID_TRIGGER;
		} else {
			self.solid = SOLID_NOT;
		}
	}
	
	static void trigger_hurt_touch( void ) {
		if ( self.fAttackFinished > self.ltime ) {
			return;
		} else if ( other.takedamage == DAMAGE_NO ) {
			return;
		} else if ( ( self.spawnflags & SF_HURT_TOUCHPLAYER ) && !( other.flags & FL_CLIENT ) ) {
			return;
		} else if ( ( self.spawnflags & SF_HURT_NOPLAYERS ) && ( other.flags & FL_CLIENT ) ) {
			return;
		}
			
		if ( self.spawnflags & SF_HURT_FIREONPLAYER ) {
			if ( other.flags & FL_CLIENT ) {
				Entities_UseTargets();
			}
		} else {
			Entities_UseTargets();
		}

		Damage_Apply( other, self, self.dmg, other.origin, FALSE );

		// Shut it down if used once
		if ( self.spawnflags & SF_HURT_ONCE ) {
			self.solid = SOLID_NOT;
		}
		
		self.fAttackFinished = self.ltime + 0.5;
	}
	static void trigger_hurt_respawn( void ) {
		self.angles = '0 0 0';
		self.solid = SOLID_TRIGGER;
	
		setmodel( self, self.model );
		self.model = 0;
		
		if ( self.spawnflags & SF_HURT_OFF ) {
			self.solid = SOLID_NOT;
		}
		
		self.vUse = trigger_hurt_use;
		self.touch = trigger_hurt_touch;
	}
	
	trigger_hurt_respawn();
	Entities_InitRespawnable( trigger_hurt_respawn );
}

/*
=================
trigger_relay

This entity acts as a relay between an event and its target. 
Its main advantage is that it can send a specific trigger state 
to its target (only turn it on, or only turn it off, as opposed 
to the toggling experienced with typical triggering).

Attributes:
Name (targetname) 
Target (target)
Delay before trigger (delay)
Trigger State (triggerstate) - Off (0), On (1), or Toggle (2)

Flags:
Remove On fire (1)
=================
*/
void trigger_relay( void ) {
	
}
    
/*
=================
multi_manager

This entity can activate several different events (including itself) at specific times.

Attributes:
Name (targetname) - Property used to identify entities.

Flags:
Multithreaded (1)

Notes:
There were better ways to do this, but someone thought it was viable to use custom, user defined fields
which cannot normally be read by something like QC for targetnames. FTE allows us to read the fields
via the __fullspawndata global at least.

TODO: Try to find out what garbled mess __fullspawndata is trying to give us
=================
*/
void multi_manager( void ) {
	static void multi_manager_enttrigger( void ) {
		Entities_UseTargets();
		remove( self );
	}
	static void multi_manager_use( void ) {
		int iFields = tokenize( self.message );
		
		for ( int i = 1; i < ( iFields - 1 ); i += 2 ) {
			// Sigh, let's attempt to sanitize this
			if ( ( argv( i ) != "classname" ) && ( argv( i ) != "origin" ) && ( argv( i ) != "targetname" ) ) {
				entity eTemp = spawn();
				eTemp.think = multi_manager_enttrigger;
				eTemp.nextthink = time + stof( argv( i + 1 ) );
				
				// sigh, because you obviously don't want to tokenize inside a tokenized loop
				if ( substring( argv( i ), strlen( argv( i ) ) - 3,  1 ) == "#" ) {
					eTemp.target = substring( argv( i ), 0, strlen( argv( i ) ) - 3 );
				} else if ( substring( argv( i ), strlen( argv( i ) ) - 2,  1 ) == "#" ) {
					eTemp.target = substring( argv( i ), 0, strlen( argv( i ) ) - 2 );
				} else {
					eTemp.target = argv( i );
				}
			}
		}
	}
	
	self.message = __fullspawndata;
	self.vUse = multi_manager_use;
}

/*
=================
multisource

TODO: State crap
=================
*/
void multisource( void ) {
	static void multisource_use( void ) {
		Entities_UseTargets();
	}
	
	self.vUse = multisource_use;
}
