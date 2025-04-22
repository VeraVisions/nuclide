/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

enumflags
{
	SF_TRIGGER,
	SF_TOUCH,
	SF_PRESSURE
};

enum
{
	BREAKMT_GLASS = 0,
	BREAKMT_WOOD,
	BREAKMT_METAL,
	BREAKMT_FLESH,
	BREAKMT_CINDER,
	BREAKMT_TILE,
	BREAKMT_COMPUTER,
	BREAKMT_GLASS_UNBREAKABLE,
	BREAKMT_ROCK,
	BREAKMT_NONE
};

#ifdef VALVE
const string funcbreakable_objtable[22] = {
	"",
	"spawnfunc_item_battery",
	"spawnfunc_item_healthkit",
	"weapon_9mmhandgun",
	"weapon_9mmclip",
	"weapon_9mmAR",
	"spawnfunc_ammo_9mmAR",
	"spawnfunc_ammo_ARgrenades",
	"weapon_shotgun",
	"spawnfunc_ammo_buckshot",
	"weapon_crossbow",
	"spawnfunc_ammo_crossbow",
	"weapon_357",
	"spawnfunc_ammo_357",
	"weapon_rpg",
	"spawnfunc_ammo_rpgclip",
	"spawnfunc_ammo_gaussclip",
	"weapon_hegrenade",
	"weapon_tripmine",
	"weapon_satchel",
	"weapon_snark",
	"weapon_hornetgun"
};
#else
const string funcbreakable_objtable[] = {
	""
};
#endif

const string funcbreakable_surftable[] = {
"gs_material_glass",
"gs_material_wood",
"gs_material_metal",
"gs_material_flesh",
"gs_material_cinderblock",
"gs_material_tile",
"gs_material_computer",
"gs_material_unbreakableglass",
"gs_material_rocks"
};



const string funcbreakable_proptable[] = {
"",
"Wooden.Tiny",
"Wooden.Small",
"Wooden.Medium",
"Wooden.Large",
"Wooden.Huge",
"Metal.Small",
"Metal.Medium",
"Metal.Large",
"Cardboard.Small",
"Cardboard.Medium",
"Cardboard.Large",
"Stone.Small",
"Stone.Medium",
"Stone.Large",
"Stone.Huge",
"Glass.Small",
"Plastic.Small",
"Plastic.Medium",
"Plastic.Large",
"Pottery.Small",
"Pottery.Medium",
"Pottery.Large",
"Pottery.Huge",
"Glass.Window",
};

/*! \brief Server-Entity: Breakable Brush Model */
/*!QUAKED func_breakable (0 .5 .8) ? SF_TRIGGER SF_TOUCH SF_PRESSURE
# OVERVIEW
Brush volume that can break into lots of little pieces.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "health" : Health of the entity.
- "material" : Material it's made of (See material-list below).
- "delay" : Delay in seconds of when it breaks under pressure.
- "explodemagnitude" : Strength of the explosion.

# SPAWNFLAGS
- SF_TRIGGER (1) : Breakable is invincible and has to be triggered in order to break.
- SF_TOUCH (2) : Break when an entity collides into it at high speed (damage is speed in units * 0.01).
- SF_PRESSURE (4) : Initiate break once someone is standing on top of it.

# NOTES
The strength of the explosion decides the radius (magnitude * 2.5) and the
maximum damage the explosion will do in the center. It has a linear fall-off.

Material-list:
	- 0 : Glass
	- 1 : Wood
	- 2 : Metal
	- 3 : Flesh
	- 4 : Cinder
	- 5 : Tile
	- 6 ; Computer
	- 7 : Glass (Unbreakable)
	- 8 : Rock
	- 9 : None

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_breakable:ncSurfacePropEntity
{
public:
	void func_breakable(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Pain(entity, entity, int, vector, vector, int);
	virtual void Death(entity, entity, int, vector, vector, int);
	virtual void Trigger(entity, triggermode_t);
	
	virtual void Explode(void);
	virtual void Touch(entity);

	/*virtual void(void) PressureDeath;*/

private:
	float m_flDelay;
	float m_flExplodeMag;
	float m_flExplodeRad;
	string m_strBreakSpawn;
	bool m_bCanTouch;
	int _m_iExplosionParticle;
	vector m_explodeDir;

	/*entity m_pressAttacker;
	int m_pressType;
	int m_pressDamage;*/
};

void
func_breakable::func_breakable(void)
{
	m_flDelay = 0.0f;
	m_flExplodeMag = 0.0f;
	m_flExplodeRad = 0.0f;
	m_strBreakSpawn = __NULL__;
	m_bCanTouch = false;
	_m_iExplosionParticle = 0i;

	/* func_breakable defaults to glass */
	if (classname == "func_breakable") {
		material = BREAKMT_GLASS;
	} else {
		material = BREAKMT_WOOD;
	}
}

void
func_breakable::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveFloat(handle, "m_flExplodeMag", m_flExplodeMag);
	SaveFloat(handle, "m_flExplodeRad", m_flExplodeRad);
	SaveString(handle, "m_strBreakSpawn", m_strBreakSpawn);
	SaveBool(handle, "m_bCanTouch", m_bCanTouch);
	SaveFloat(handle, "material", material);
}

void
func_breakable::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flDelay":
		m_flDelay = ReadFloat(setValue);
		break;
	case "m_flExplodeMag":
		m_flExplodeMag = ReadFloat(setValue);
		break;
	case "m_flExplodeRad":
		m_flExplodeRad = ReadFloat(setValue);
		break;
	case "m_strBreakSpawn":
		m_strBreakSpawn = ReadString(setValue);
		break;
	case "m_bCanTouch":
		m_bCanTouch = ReadBool(setValue);
		break;
	case "material":
		material = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_breakable::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "propdata":
		int propDataID = ReadInt(setValue);

		if (propDataID > 0i) {
			SetPropData(funcbreakable_proptable[propDataID]);
		}
		break;
	case "material":
		material = ReadFloat(setValue);
		break;
	case "explodemagnitude":
		m_flExplodeMag = ReadFloat(setValue);
		m_flExplodeRad = m_flExplodeMag * 2.5f;
		break;
	case "spawnobject":
		int oid = ReadInt(setValue);

		if (oid >= funcbreakable_objtable.length) {
			m_strBreakSpawn = "";
			EntWarning("spawnobject %i out of bounds", oid);
		} else {
			m_strBreakSpawn = funcbreakable_objtable[oid];
		}
		break;
	case "spawnonbreak":
		m_strBreakSpawn = ReadString(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
		break;
	}
}

void
func_breakable::Spawned(void)
{
	_m_iExplosionParticle = particleeffectnum("fx_explosion.main");
	super::Spawned();

	/* needs to be called before super function */
	if (HasSurfaceData() == false) {
		SetSurfaceData(funcbreakable_surftable[material]);
	}

	if (HasPropData() == false) {
		SetPropData(funcbreakable_surftable[material]);
	}
}

void
func_breakable::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSP);
	ClearAngles();
	ReleaseThink();
	m_bCanTouch = true;

	if (HasSpawnFlags(SF_TRIGGER)) {
		MakeInvulnerable();
	} else {
		MakeVulnerable();
	}

	/* initially set the health to that of the ent-data */
	float spawnhealth = GetSpawnFloat("health");

	if (HasPropData() == true && spawnhealth <= 0) {
		/* assign propdata health */
		SetHealth(GetPropData(PROPINFO_HEALTH));
		m_flExplodeMag = GetPropData(PROPINFO_EXPLOSIVE_DMG);
		m_flExplodeRad = GetPropData(PROPINFO_EXPLOSIVE_RADIUS);
	} else {
		SetHealth(spawnhealth);
	}

	/* unassigned health isn't valid */
	if (GetHealth() <= 0)
		SetHealth(15);
}

void
func_breakable::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	string painSound;

	if (HasSpawnFlags(SF_TRIGGER)) {
		return;
	}

	painSound = GetSurfaceData(SURFDATA_SND_BULLETIMPACT);

	if (painSound) {
		StartSoundDef(painSound, CHAN_VOICE, true);
	}
}


void
func_breakable::Explode(void)
{
	vector rp = WorldSpaceCenter();
	string breakModel = GetPropData(PROPINFO_BREAKMODEL);

	BreakModel_Spawn(absmin, absmax, m_explodeDir, m_flExplodeMag, vlen(size) / 10, breakModel);
	pointparticles(_m_iExplosionParticle, rp, [0,0,0], 1);
	combat.RadiusDamage(GetOrigin(), m_flExplodeMag, 0i, m_flExplodeRad, this, "");
	UseTargets(this, TRIG_TOGGLE, 0.0f); /* delay... ignored. */
	MakeInvulnerable();
	Disappear();
}

void
func_breakable::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	static void break_spawnobject(void) {
		/* become the classname assigned */
		ncEntity t = (ncEntity)self;
		callfunction(self.classname);

		/* spawn anew */
		if (t.Spawn)
			t.Spawn();
	}

	if (material == BREAKMT_GLASS_UNBREAKABLE) {
		return;
	}

	eActivator = (ncEntity)attacker;
	m_explodeDir = dir;

	if (STRING_SET(m_strBreakSpawn)) {
		if (isfunction(m_strBreakSpawn)) {
			entity unit = spawn();
			unit.classname = m_strBreakSpawn;
			unit.think = break_spawnobject;
			unit.nextthink = time;
			unit.real_owner = this;
			setorigin(unit, WorldSpaceCenter());
		}
	}

	/* This may seem totally absurd. That's because it is. It's very
	 * unreliable but exploding breakables in close proximity it WILL cause
	 * an OVERFLOW because we'll be busy running through thousands
	 * of entities in total when one breakable damages another in a frame. 
	 * The only way around this is to set a hard-coded limit of loops per
	 * frame and that would break functionality. */
	if (m_flExplodeMag) {
		ScheduleThink(Explode, random(0.0f, 0.5f));
	} else {
		string sndBreak = GetSurfaceData(SURFDATA_SND_BREAK);
		string breakModel = __NULL__;
		int gibCount = (int)bound(5, vlen(size) / 10, 32);

// 		if (HasPropData()) {
// 			breakModel = GetPropData(PROPINFO_BREAKMODEL);
// 		}

		if (!STRING_SET(breakModel)) {
			switch (material) {
			case 0:
				breakModel = "glasschunks";
				break;
			case 1:
				breakModel = "woodchunks";
				break;
			case 2:
				breakModel = "metalchunks";
				break;
			case 4:
				breakModel = "concretechunks";
				break;
			case 6:
				breakModel = "metalchunks";
				break;
			case 8:
				breakModel = "concretechunks";
				break;
			}
		}

		if (STRING_SET(breakModel)) {
			BreakModel_Spawn(absmin, absmax, dir, damage * 2.5, gibCount, breakModel);
		} else {
			EntError("No BreakModel set for \"material\" \"%d\"", material);
		}

		StartSoundDef(sndBreak, CHAN_BODY, true);

		Disappear();
		MakeInvulnerable();
		UseTargets(eActivator, TRIG_TOGGLE, 0.0f);
	}
}

void
func_breakable::Trigger(entity act, triggermode_t state)
{
	if (GetHealth() > 0) {
		Death(act, act, 0i, g_vec_null, origin, 0i);
	}
}

void
func_breakable::Touch(entity eToucher)
{
	static void TriggerWrap(void) {
		/* TODO: 'this' should be the person who touched the ent instead */
		Trigger(this, TRIG_TOGGLE);
	}

	if (m_bCanTouch == false) {
		return;
	}

	if (eToucher.classname == classname) {
		return;
	}

	/* grenades need to be able to break stuff */
	if (eToucher.solid == SOLID_CORPSE) {
		if (length(eToucher.velocity) > 100) {
			Trigger(this, TRIG_ON);
		}
	}

	/* break on touch */
	if (HasSpawnFlags(SF_TOUCH)) {
		int dmgAmount = (float)(vlen(eToucher.velocity) * 0.01f);

		if (dmgAmount >= GetHealth()) {
			vector dmgDir = dirFromTarget(eToucher.origin, WorldSpaceCenter());
			ncDict damageDecl = spawn(ncDict);
			damageDecl.AddKey("damage", itos(dmgAmount));
			damageDecl.AddKey("location", vtos(eToucher.origin));
			m_bCanTouch = false;
			Damage(eToucher, eToucher, damageDecl, 1.0f, dmgDir, eToucher.origin);

			if ((GetSurfaceData(SURFDATA_MATERIAL) == GSMATERIAL_GLASS) || (GetSurfaceData(SURFDATA_MATERIAL) == GSMATERIAL_COMPUTER)) {
				Damage(eToucher, eToucher, damageDecl, 0.25f, dmgDir, eToucher.origin);
			}
			remove(damageDecl);
		}
	}

	if (HasSpawnFlags(SF_PRESSURE) && (eToucher.absmin[2] >= maxs[2] - 2)) {
		m_bCanTouch = false;

		if (m_flDelay <= 0) {
			m_flDelay = 0.1f;
		}

		ScheduleThink(TriggerWrap, m_flDelay);
	}
}
