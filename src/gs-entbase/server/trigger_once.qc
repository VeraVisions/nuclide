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

/*QUAKED trigger_once (0 .5 .8) ? TO_MONSTERS TO_NOCLIENTS TO_PUSHABLES
A trigger volume which works only once.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"delay" : Delay until target is triggered.

-------- SPAWNFLAGS --------
TO_MONSTERS : Allow NPCs to activate this entity.
TO_NOCLIENTS : Don't allow players to activate this entity.
TO_PUSHABLES : Allow func_pushables to trigger this entity.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
	TO_MONSTERS,
	TO_NOCLIENTS,
	TO_PUSHABLES
};

class trigger_once:NSBrushTrigger
{
	string m_strOnStartTouch;
	string m_strOnTrigger;

	void(void) trigger_once;

	virtual void(void) Spawned;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_once::trigger_once(void)
{
	m_strOnStartTouch =
	m_strOnTrigger = __NULL__;
}

void
trigger_once::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strOnStartTouch", m_strOnStartTouch);
	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
}

void
trigger_once::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strOnStartTouch":
		m_strOnStartTouch = ReadString(strValue);
		break;
	case "m_strOnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_once::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnStartTouch":
		m_strOnStartTouch = PrepareOutput(m_strOnStartTouch, strValue);
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
trigger_once::Spawned(void)
{
	super::Spawned();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);

	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
}

void
trigger_once::Respawn(void)
{
	InitBrushTrigger();
	m_iValue = 0;
}

void
trigger_once::Touch(entity eToucher)
{
	if (GetMaster() == FALSE)
		return;
	if (HasSpawnFlags(TO_NOCLIENTS) && eToucher.flags & FL_CLIENT)
		return;
	if (!HasSpawnFlags(TO_MONSTERS) && eToucher.flags & FL_MONSTER)
		return;
	if (!HasSpawnFlags(TO_PUSHABLES) && eToucher.classname == "func_pushable")
		return;

	SetSolid(SOLID_NOT); /* make inactive */
	m_iValue = 1;

	if (!target) {
		UseOutput(eToucher, m_strOnStartTouch);
		return;
	}

	UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);
}
