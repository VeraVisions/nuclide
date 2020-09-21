/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED func_breakable (0 .5 .8) ? SF_TRIGGER SF_TOUCH SF_PRESSURE
"targetname"        Name
"target"            Target when triggered.
"killtarget"        Target to kill when triggered.
"material"          Material it's made of.
"delay"             Delay in seconds of when it breaks under pressure.
"explodemagnitude"  Strength of the explosion.

Brush volume that can break into lots of little pieces.

Material list:

0 = Glass
1 = Wood
2 = Metal
3 = Flesh
4 = Cinder
5 = Tile
6 = Computer
7 = Glass (Unbreakable)
8 = Rock
9 = None

When SF_TOUCH is set, it'll break when an entity runs into it at high
velocities (damage is speed in units * 0.01).

When SF_PRESSURE is set, it'll collapse once someone is standing on top of it.
At that point the "delay" key will decide after how many seconds the object
breaks.

The strength of the explosion decides the radius (magnitude * 2.5) and the
maximum damage the explosion will do (you have to stand in the center for that).
*/

enumflags
{
	SF_TRIGGER,
	SF_TOUCH,
	SF_PRESSURE
};

enum
{
	BREAKMT_GLASS,
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

class func_breakable:CBaseTrigger
{
	int m_iMaterial;
	float m_flDelay;
	float m_flExplodeMag;
	string m_strBreakSpawn;

	/*entity m_pressAttacker;
	int m_pressType;
	int m_pressDamage;*/

	void(void) func_breakable;
	virtual void(void) Respawn;
	virtual void(void) Explode;
	virtual void(entity, int) Trigger;
	virtual void(void) PlayerTouch;
	/*virtual void(void) PressureDeath;*/
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(string, string) SpawnKey;
};

void
func_breakable::Pain(void)
{
	if (spawnflags & SF_TRIGGER) {
		return;
	}
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}

	switch (m_iMaterial) {
	case BREAKMT_GLASS:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_glass");
		break;
	case BREAKMT_COMPUTER:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_computer");
		break;
	case BREAKMT_GLASS_UNBREAKABLE:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_glassunreakable");
		break;
	case BREAKMT_WOOD:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_wood");
		break;
	case BREAKMT_METAL:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_metal");
		break;
	case BREAKMT_FLESH:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_flesh");
		break;
	case BREAKMT_CINDER:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_cinder");
		break;
	case BREAKMT_ROCK:
		Sound_Play(this, CHAN_VOICE, "func_breakable.impact_rock");
		break;
	}
}


void
func_breakable::Explode(void)
{
	vector rp = absmin + (0.5 * (absmax - absmin));
	FX_BreakModel(vlen(size) / 10, absmin, absmax, [0,0,0], m_iMaterial);
	FX_Explosion(rp);
	Damage_Radius(rp, this, m_flExplodeMag, m_flExplodeMag * 2.5f, TRUE, 0);
	UseTargets(this, TRIG_TOGGLE, 0.0f); /* delay... ignored. */
	Hide();
}

void
func_breakable::Death(void)
{
	static void break_spawnobject(void) {
		/* these might get overwritten by the entity spawnfunction */
		vector neworg = self.origin;

		/* become the classname assigned */
		CBaseEntity t = (CBaseEntity)self;
		callfunction(self.classname);

		/* apply the saved values back */
		t.origin = t.m_oldOrigin = neworg;

		/* spawn anew */
		if (t.Respawn)
			t.Respawn();
	}

	if (m_iMaterial == BREAKMT_GLASS_UNBREAKABLE) {
		return;
	}

	health = 0;
	eActivator = g_eAttacker;

	if (m_strBreakSpawn != "" && isfunction(m_strBreakSpawn)) {
		entity unit = spawn();
		unit.classname = m_strBreakSpawn;
		unit.think = break_spawnobject;
		unit.nextthink = time;
		unit.real_owner = this;
		setorigin(unit, absmin + (0.5 * (absmax - absmin)));
		print(sprintf("breakable spawning %s\n", unit.classname));
	}

	/* This may seem totally absurd. That's because it is. It's very
	 * unreliable but exploding breakables in close proximity it WILL cause
	 * an OVERFLOW because we'll be busy running through thousands
	 * of entities in total when one breakable damages another in a frame. 
	 * The only way around this is to set a hard-coded limit of loops per
	 * frame and that would break functionality. */
	if (m_flExplodeMag) {
		think = Explode;
		nextthink = time + random(0.0,0.5);
	} else {
		FX_BreakModel(vlen(size) / 10, absmin, absmax, [0,0,0], m_iMaterial);
		/* TODO: ability to have whoever destroyed the crate be the activator */
		UseTargets(this, TRIG_TOGGLE, 0.0f);
		Hide();
	}
}

void
func_breakable::Trigger(entity act, int state)
{
	if (health > 0)
		func_breakable::Death();
}

void
func_breakable::PlayerTouch(void)
{
	static void TriggerWrap(void) {
		/* TODO: 'this' should be the person who touched the ent instead */
		Trigger(this, TRIG_TOGGLE);
	}

	if (other.classname == classname) {
		return;
	}

	if (other.solid == SOLID_CORPSE) {
		if (vlen(other.velocity) > 100) {
			Trigger(this, TRIG_ON);
		}
	}

	if (spawnflags & SF_TOUCH) {
		int fDamage = (float)(vlen(other.velocity) * 0.01f);

		if (fDamage >= health) {
			touch = __NULL__;
			Damage_Apply(this, other, fDamage, 0, DMG_CRUSH);

			if ((m_iMaterial == BREAKMT_GLASS) || (m_iMaterial == BREAKMT_COMPUTER)) {
				Damage_Apply(other, this, fDamage / 4, 0, DMG_CRUSH);
			}
		}
	}

	if ((spawnflags & SF_PRESSURE) && (other.absmin[2] >= maxs[2] - 2)) {
		touch = __NULL__;
		think = TriggerWrap;

		if (m_flDelay == 0) {
			m_flDelay = 0.1f;
		}

		nextthink = time + m_flDelay;
	}
}

void
func_breakable::Respawn(void)
{
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSP);

	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	touch = PlayerTouch;
	think = __NULL__;

	if (spawnflags & SF_TRIGGER) {
		takedamage = DAMAGE_NO;
	} else {
		takedamage = DAMAGE_YES;
	}

	health = m_oldHealth;

	if (!health) {
		health = 15;
	}
}

void
func_breakable::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "material":
		m_iMaterial = stoi(strValue);
		break;
	case "explodemagnitude":
		m_flExplodeMag = stof(strValue);
		break;
	case "spawnobject":
		int oid = stoi(strValue);

		if (oid >= funcbreakable_objtable.length) {
			m_strBreakSpawn = "";
			print(sprintf("^1func_breakable^7:" \
			      "spawnobject %i out of bounds! fix your mod!\n", oid));
		} else {
			m_strBreakSpawn = funcbreakable_objtable[oid];
		}
		break;
	case "spawnonbreak":
		m_strBreakSpawn = strValue;
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
		break;
	}
}

void
func_breakable::func_breakable(void)
{
	CBaseTrigger::CBaseTrigger();

	switch (m_iMaterial) {
	case BREAKMT_GLASS:
		Sound_Precache("func_breakable.impact_glass");
		break;
	case BREAKMT_COMPUTER:
		Sound_Precache("func_breakable.impact_computer");
		break;
	case BREAKMT_GLASS_UNBREAKABLE:
		Sound_Precache("func_breakable.impact_glassunreakable");
		break;
	case BREAKMT_WOOD:
		Sound_Precache("func_breakable.impact_wood");
		break;
	case BREAKMT_METAL:
		Sound_Precache("func_breakable.impact_metal");
		break;
	case BREAKMT_FLESH:
		Sound_Precache("func_breakable.impact_flesh");
		break;
	case BREAKMT_CINDER:
		Sound_Precache("func_breakable.impact_cinder");
		break;
	case BREAKMT_ROCK:
		Sound_Precache("func_breakable.impact_rock");
		break;
	}
}
