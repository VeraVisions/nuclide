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

// This is what they use...
.string killtarget;
.float wait;
.float delay;

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
multi_manager

This entity can activate several different events (including itself) at specific times.

Attributes:
Name (targetname) - Property used to identify entities.

Flags:
Multithreaded (1) - See notes below for an explanation.

Notes:
There were better ways to do this, but someone thought it was viable to use custom, user defined fields
which cannot normally be read by something like QC for targetnames. FTE allows us to read the fields
via the __fullspawndata global at least.

TODO: Try to find out what garbled mess __fullspawndata is trying to give us
=================
*/
void multi_manager( void ) {
	static void multi_manager_use( void ) {
		eprint( self );
	}
	
	self.message = __fullspawndata;
	self.vUse = multi_manager_use;
}
