/*
	TRIGGER_MULTIPLE
	http://twhl.info/wiki.php?id=139
	
    Target (target) - When an entity is activated, it triggers the entity with the name specified by Target.
    Name (targetname) - Property used to identify entities.
    Master (master) - The name of a multisource (or game_team_master) entity. A master must usually be active in order for the entity to work. Thus they act almost like an on/off switch, in their simplest form, and like an AND gate in the case of the multisource.
    Delay before trigger (delay) - Usually the time in seconds before an entity should trigger its target (after being triggered itself). Under other SmartEdit names, delay might also be the time to wait before performing some other action.
    Kill target (killtarget) - Remove this entity from the game when triggered
    Target Path (netname)
    Sound style (sounds)
    Message (message)
    Delay before reset (wait) - Time in seconds before the entity is ready to be re-triggered.
*/

// This is what they use...
.string killtarget;
.float wait;
.float delay;

void trigger_multiple_trigger( void ) {
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
	
/*
=================
SPAWN: trigger_multiple

Entry function for this nice trigger object.
=================
*/
void trigger_multiple( void ) {
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

void multi_manager( void ) {
	static void multi_manager_use( void ) {
		eprint( self );
	}
	self.message = __fullspawndata;
	self.think = multi_manager_use;
	self.nextthink = self.ltime + 5;
}
