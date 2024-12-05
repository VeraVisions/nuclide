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

/*! \brief Server-Entity: Changes Targets Of Other Entities */
/*!QUAKED trigger_changetarget (.5 .5 .5) (-8 -8 -8) (8 8 8)
# OVERVIEW
When triggered, trigger_changetarget changes the 'target' value of any entity
to something else.

# KEYS
- "targetname" : Name
- "target" : Target when triggered
- "m_iszNewTarget" : Name of the new 'target' value for the targeted entity

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
trigger_changetarget:ncPointTrigger
{
	string m_strNewTarget;

public:
	void trigger_changetarget(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);

};

void
trigger_changetarget::trigger_changetarget(void)
{
	m_strNewTarget = __NULL__;
}

void
trigger_changetarget::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strNewTarget", m_strNewTarget);
}

void
trigger_changetarget::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strNewTarget":
		m_strNewTarget = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_changetarget::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iszNewTarget":
		m_strNewTarget = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_changetarget::Trigger(entity act, triggermode_t state)
{
	ncEntity f;

	for (f = __NULL__; (f = (ncEntity)find(f, ::targetname, target));) {

		EntLog("Changing %s (%s) target from '%s' to '%s'\n", \
		       target, f.classname, f.target, target);

		/* now change the target */
		f.target = m_strNewTarget;
	}
}
