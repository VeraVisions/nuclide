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
			while ( eFind ) {
				entity eRemoveMe = eFind;
				remove( eRemoveMe );
				eFind = eFind.chain;
			}
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
	self.think = multi_manager_use;
	self.nextthink = self.ltime + 5;
}
