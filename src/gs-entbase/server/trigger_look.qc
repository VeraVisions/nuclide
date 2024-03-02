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

/*!QUAKED trigger_look (.5 .5 .5) ?
# OVERVIEW
Triggers itself when a player is inside its volume and is looking at a
specific entity within a specified field-of-view cone.
It then disables itself.

It's like the beginning in Halo - you know, where you have to look up/down
at lights and stuff? No...? Well... ever played Splinter Cell?... Nevermind.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "delay" : Delay until target is triggered.
- "killtarget" : Target to kill when triggered.
- "looktarget" : Name of the entity to be looked at. Doesn't have to be solid.
- "looktime" : How long the player must look at the 'looktarget', in seconds.
- "fov" : Area of the view-cone check, 1.0 is straight ahead, 0.0 is in the realm of 90 degrees. Default is 0.9.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class
trigger_look:NSBrushTrigger
{
public:
	void trigger_look(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Touch(entity);

private:
	float m_flFOV;
	float m_flLookTime;
	float m_flDelay;
	float m_flLooked;
	string m_strLookTarget;

	/* Input/Output */
	string m_strOnTrigger;
};

void
trigger_look::trigger_look(void)
{
	m_flFOV = 0.9f;
	m_flLookTime = 0.5f;
	m_flDelay = 0.0f;
	m_flLooked = 0.0f;
	m_strLookTarget = __NULL__;
	m_strOnTrigger = __NULL__;
}

void
trigger_look::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flFOV", m_flFOV);
	SaveFloat(handle, "m_flLookTime", m_flLookTime);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveFloat(handle, "m_flLooked", m_flLooked);
	SaveString(handle, "m_strLookTarget", m_strLookTarget);
	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
}

void
trigger_look::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flFOV":
		m_flFOV = ReadFloat(strValue);
		break;
	case "m_flLookTime":
		m_flLookTime = ReadFloat(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_flLooked":
		m_flLooked = ReadFloat(strValue);
		break;
	case "m_strLookTarget":
		m_strLookTarget = ReadString(strValue);
		break;
	case "m_strOnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_look::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "looktarget":
	case "target_destination":
		m_strLookTarget = strValue;
		break;
	case "fov":
	case "FieldOfView":
		m_flFOV = stof(strValue);
		break;
	case "looktime":
	case "LookTime":
		m_flLookTime = stof(strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = PrepareOutput(m_strOnTrigger, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
trigger_look::Spawned(void)
{
	super::Spawned();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);
}

void
trigger_look::Respawn(void)
{
	/* reset */
	InitBrushTrigger();
	m_flLooked = 0.0f;
}

void
trigger_look::Touch(entity eToucher)
{
	float dot;
	entity lt;

	if (GetMaster(eToucher) == FALSE)
		return;

	if (!(eToucher.flags & FL_CLIENT)) {
		/* FIXME: could this conflict with other entities? probably. */
		m_flLooked = 0.0f;
		return;
	}

	/* find the looktarget */
	lt = find(world, ::targetname, m_strLookTarget);
	if (!lt) {
		EntLog("^1trigger_look:Touch^7: Invalid m_strLookTarget %s!", m_strLookTarget);
		Destroy();
		return;
	}

	/* test against the looktarget position */
	makevectors(eToucher.v_angle);
	vector v = normalize (lt.origin - other.origin);
	dot = v * v_forward;

	/* field of view check */
	if (dot < m_flFOV) {
		m_flLooked = 0.0f;
		return;
	}

	/* increment the 'looked-time' a little bit one frame after another */
	if (m_flLooked < m_flLookTime) {
		m_flLooked += frametime;
		return;
	}

	/* trigger and disable entity, for now */
	SetSolid(SOLID_NOT);

	if (!target)
		UseOutput(eToucher, m_strOnTrigger);
	else
		UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);
}
