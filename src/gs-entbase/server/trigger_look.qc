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

/*! \brief Server-Entity: Eye/Vision Based Trigger */
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

@ingroup serverentity
@ingroup brushentity
*/
class
trigger_look:ncBrushTrigger
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
	float m_targetViewCone;
	float m_minimumLookTime;
	float m_timeSpentLooking;
	string m_lookTarget;

	/* Input/Output */
	string m_outputOnTrigger;
};

void
trigger_look::trigger_look(void)
{
	m_targetViewCone = 0.9f;
	m_minimumLookTime = 0.5f;
	m_timeSpentLooking = 0.0f;
	m_lookTarget = __NULL__;
	m_outputOnTrigger = __NULL__;
}

void
trigger_look::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "targetViewCone", m_targetViewCone);
	SaveFloat(handle, "minimumLookTime", m_minimumLookTime);
	SaveFloat(handle, "timeSpentLooking", m_timeSpentLooking);
	SaveString(handle, "lookTarget", m_lookTarget);
	SaveString(handle, "outputOnTrigger", m_outputOnTrigger);
}

void
trigger_look::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "targetViewCone":
		m_targetViewCone = ReadFloat(setValue);
		break;
	case "minimumLookTime":
		m_minimumLookTime = ReadFloat(setValue);
		break;
	case "timeSpentLooking":
		m_timeSpentLooking = ReadFloat(setValue);
		break;
	case "lookTarget":
		m_lookTarget = ReadString(setValue);
		break;
	case "outputOnTrigger":
		m_outputOnTrigger = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_look::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "looktarget":
	case "target_destination":
		m_lookTarget = setValue;
		break;
	case "fov":
	case "FieldOfView":
		m_targetViewCone = stof(setValue);
		break;
	case "looktime":
	case "LookTime":
		m_minimumLookTime = stof(setValue);
		break;
	case "OnTrigger":
		m_outputOnTrigger = PrepareOutput(m_outputOnTrigger, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
		break;
	}
}

void
trigger_look::Spawned(void)
{
	super::Spawned();

	if (m_outputOnTrigger)
		m_outputOnTrigger = CreateOutput(m_outputOnTrigger);
}

void
trigger_look::Respawn(void)
{
	/* reset */
	InitBrushTrigger();
	m_timeSpentLooking = 0.0f;
}

void
trigger_look::Touch(entity eToucher)
{
	float dot;
	entity lt;

	if (GetMaster(eToucher) == FALSE)
		return;

	if (is.Player(eToucher) == false) {
		/* FIXME: could this conflict with other entities? probably. */
		m_timeSpentLooking = 0.0f;
		return;
	}

	/* find the looktarget */
	lt = find(world, ::targetname, m_lookTarget);
	if (!lt) {
		EntLog("^1trigger_look:Touch^7: Invalid m_lookTarget %s!", m_lookTarget);
		Destroy();
		return;
	}

	/* test against the looktarget position */
	makevectors(eToucher.v_angle);
	vector v = normalize (lt.origin - other.origin);
	dot = v * v_forward;

	/* field of view check */
	if (dot < m_targetViewCone) {
		m_timeSpentLooking = 0.0f;
		return;
	}

	/* increment the 'looked-time' a little bit one frame after another */
	if (m_timeSpentLooking < m_minimumLookTime) {
		m_timeSpentLooking += frametime;
		return;
	}

	/* trigger and disable entity, for now */
	SetSolid(SOLID_NOT);

	if (!target)
		UseOutput(eToucher, m_outputOnTrigger);
	else
		UseTargets(eToucher, TRIG_TOGGLE, GetTriggerDelay());
}
