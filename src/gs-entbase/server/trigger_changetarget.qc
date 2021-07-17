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

/*QUAKED trigger_changetarget (1 0 0) (-8 -8 -8) (8 8 8)
When triggered, trigger_changetarget changes the 'target' value of any entity
to something else.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered
"m_iszNewTarget" : Name of the new 'target' value for the targeted entity

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class trigger_changetarget:CBaseTrigger
{
	string m_strNewTarget;

	void(void) trigger_changetarget;

	virtual void(entity,int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
trigger_changetarget::Trigger(entity act, int state)
{
	CBaseEntity f;

	f = (CBaseEntity)find(world, ::targetname, target);

	if (f) {
		dprint("^2trigger_changetarget::^3Trigger^7: " \
		       "Changing %s (%s) target from '%s' to '%s'\n", \
		       target, f.classname, f.target, target);

		/* now change the target */
		f.target = m_strNewTarget;
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_changetarget::trigger_changetarget(void)
{
	CBaseTrigger::CBaseTrigger();
}
