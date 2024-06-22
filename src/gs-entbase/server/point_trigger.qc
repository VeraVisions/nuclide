/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/** point_trigger spawnflags */
typedef enumflags
{
	PTRIG_CLIENT,		/**< Clients only. */
	PTRIG_NPC,			/**< NPCs only. */
	PTRIG_PUSHABLE,		/**< Pushables only. */
	PTRIG_PHYS,			/**< Physics objects only. */
	PTRIG_ALLIES,		/**< Player allied NPCs. */
	PTRIG_VEHPLAYER,	/**< Players in vehicles. */
	PTRIG_ALL,			/**< Everything. */
	PTRIG_UNUSED1,
	PTRIG_UNUSED2,
	PTRIG_NOVEHCL,		/**< Clients that are not in vehicles. */
} pointTriggerFlags_t;

/*! \brief Server-Entity: Radius Based Trigger */
/*!QUAKED point_trigger (1 0 0) (-8 -8 -8) (8 8 8) CLIENT NPC PUSHABLE PHYS ALLIES VEHPLAYER ALL x x NOVEHCL
# OVERVIEW
Point based trigger. Define a radius and it will fire its targets when an entity touches
it within that radius.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "TriggerOnce" : Either 0 (Multiple) or 1 (Once).
- "TriggerRadius" : Radius in Quake units.

# INPUTS
- "Toggle" : Toggles it between disabled and enabled states.

# OUTPUTS
- "OnStartTouch": Triggered when something starts touching this volume
- "OnEndTouchAll": Triggered when nothing touched the entity no more

# SPAWNFLAGS
- CLIENT (1) : Make this explosion purely decorative, without radius damage.
- NPC (2) : Makes this explosion triggerable more than once.
- PUSHABLE (4) : Spawn no fireball.
- PHYS (8) : Spawn no smoke.
- ALLIES (16) : Leave no decal upon explosion.
- VEHPLAYER (32) : Don't spawn any sparks upon exploding.
- ALL (64) : Don't spawn any sparks upon exploding.
- NOVEHCL (512) : Don't spawn any sparks upon exploding.

# TRIVIA
This entity was introduced in Obsidian Conflict (2006).

@ingroup server
@ingroup pointentity
*/
class
point_trigger:NSPointTrigger
{
public:
	void point_trigger(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity,string,string);
	virtual void Touch(entity);
	virtual void EndTouch(entity);

	/** Returns if this trigger will work with the activator filtered by spawnflags. */
	nonvirtual bool WillThisTrigger(entity);

private:
	bool m_bTriggerOnce;
	float m_flTriggerRadius;
	string m_strOnStartTouch;
	string m_strOnEndTouchAll;
	bool m_bEnabled;
};

void
point_trigger::point_trigger(void)
{
	m_bEnabled = true;
	m_bTriggerOnce = false;

	/* Input/Output */
	m_strOnStartTouch =
	m_strOnEndTouchAll =  __NULL__;
}

void
point_trigger::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flTriggerRadius", m_flTriggerRadius);
	SaveBool(handle, "m_bTriggerOnce", m_bTriggerOnce);
	SaveBool(handle, "m_bEnabled", m_bEnabled);

	/* Input/Output */
	SaveString(handle, "m_strOnStartTouch", m_strOnStartTouch);
	SaveString(handle, "m_strOnEndTouchAll", m_strOnEndTouchAll);
}

void
point_trigger::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flTriggerRadius":
		m_flTriggerRadius = ReadFloat(strValue);
		break;
	case "m_bTriggerOnce":
		m_bTriggerOnce = ReadBool(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;

	/* Input/Output */
	case "m_strOnStartTouch":
		m_strOnStartTouch = ReadString(strValue);
		break;
	case "m_strOnEndTouchAll":
		m_strOnEndTouchAll = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
point_trigger::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "TriggerOnce":
		m_bTriggerOnce = stof(strValue);
		break;
	case "TriggerRadius":
		m_flTriggerRadius = stof(strValue);
		break;

	/* Input/Output */
	case "OnStartTouch":
	case "OnStartTouchAll":
		m_strOnStartTouch = PrepareOutput(m_strOnStartTouch, strValue);
		break;
	case "OnEndTouchAll":
		m_strOnEndTouchAll = PrepareOutput(m_strOnEndTouchAll, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
point_trigger::Spawned(void)
{
	super::Spawned();

	/* Input/Output */
	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
	if (m_strOnEndTouchAll)
		m_strOnEndTouchAll = CreateOutput(m_strOnEndTouchAll);
}

void
point_trigger::Respawn(void)
{
	vector vecMins, vecMaxs;

	InitPointTrigger();

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_TRIGGER);
	geomtype = GEOMTYPE_SPHERE;

	/* adjust size */
	vecMins = [-m_flTriggerRadius, -m_flTriggerRadius];
	vecMaxs = [m_flTriggerRadius, m_flTriggerRadius];
	SetSize(vecMins, vecMaxs);
}


void
point_trigger::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bEnabled = false;
		break;
	case TRIG_ON:
		m_bEnabled = true;
		break;
	default:
		m_bEnabled = m_bEnabled ? false : true;
	}
}

void
point_trigger::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
point_trigger::Touch(entity eToucher)
{
	if (GetMaster(eToucher) == false)
		return;
	if (m_bEnabled == false)
		return;
	if (WillThisTrigger(eToucher) == false)
		return;

	/* if the target key isn't used, assume we're using the new I/O system */
	if (HasTriggerTarget() == false)
		UseOutput(eToucher, m_strOnStartTouch);
	else
		UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);

	/* FIXME: Does Source do this? Perhaps in Source it won't re-enable at all... */
	/* Will need to be triggered to be enabled again. */
	if (m_bTriggerOnce)
		m_bEnabled = false;
}

void
point_trigger::EndTouch(entity eToucher)
{
	if (m_strOnEndTouchAll)
		UseOutput(eToucher, m_strOnEndTouchAll);
}

bool
point_trigger::WillThisTrigger(entity eAct)
{
	if (HasSpawnFlags(PTRIG_ALL))
		return true;
	if (HasSpawnFlags(PTRIG_CLIENT) && eAct.flags & FL_CLIENT)
		return true;
	if (HasSpawnFlags(PTRIG_NPC) && eAct.flags & FL_MONSTER)
		return true;
	if (HasSpawnFlags(PTRIG_PUSHABLE) && eAct.classname == "func_pushable")
		return true;
	if (HasSpawnFlags(PTRIG_PHYS) && eAct.movetype == MOVETYPE_PHYSICS)
		return true;
	if (HasSpawnFlags(PTRIG_ALLIES) && eAct.flags & FL_MONSTER && eAct.m_iAlliance == MAL_FRIEND)
		return true;
	if (HasSpawnFlags(PTRIG_VEHPLAYER) && eAct.flags & FL_CLIENT && eAct.vv_flags & VFL_INVEHICLE)
		return true;
	if (HasSpawnFlags(PTRIG_NOVEHCL) && eAct.flags & FL_CLIENT && !(eAct.vv_flags & VFL_INVEHICLE))
		return true;

	return false;
}