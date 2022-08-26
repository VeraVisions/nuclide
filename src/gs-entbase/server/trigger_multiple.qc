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

/*QUAKED trigger_multiple (0 .5 .8) ? TM_MONSTERS TM_NOCLIENTS TM_PUSHABLES
A trigger volume which works more than once. 

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"delay" : Delay until target is triggered.
"wait" : Time until this entity can trigger again

-------- OUTPUTS ---------
"OnStartTouch": Triggered when something starts touching this volume
"OnEndTouchAll": Triggered when nothing touched the entity no more

-------- SPAWNFLAGS --------
TM_MONSTERS : Allow NPCs to activate this entity.
TM_NOCLIENTS : Don't allow players to activate this entity.
TM_PUSHABLES : Allow func_pushables to trigger this entity.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
	TM_MONSTERS,
	TM_NOCLIENTS,
	TM_PUSHABLES
};

class
trigger_multiple:NSBrushTrigger
{
	float m_flWait;

	/* Input/Output */
	string m_strOnStartTouch;
	string m_strOnEndTouchAll;
	string m_strOnTrigger;

	void(void) trigger_multiple;

	virtual void(void) Spawned;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;

	virtual void(entity) EndTouch;
};

void
trigger_multiple::trigger_multiple(void)
{
	m_flWait = 0.0f;

	/* Input/Output */
	m_strOnStartTouch =
	m_strOnEndTouchAll =
	m_strOnTrigger =  __NULL__;
}

void
trigger_multiple::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveString(handle, "m_strOnStartTouch", m_strOnStartTouch);
	SaveString(handle, "m_strOnEndTouchAll", m_strOnEndTouchAll);
	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
}

void
trigger_multiple::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_strOnStartTouch":
		m_strOnStartTouch = ReadString(strValue);
		break;
	case "m_strOnEndTouchAll":
		m_strOnEndTouchAll = ReadString(strValue);
		break;
	case "m_strOnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_multiple::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "wait":
		m_flWait = stof(strValue);
		break;
	case "OnStartTouch":
	case "OnStartTouchAll":
		m_strOnStartTouch = PrepareOutput(m_strOnStartTouch, strValue);
		break;
	case "OnEndTouchAll":
		m_strOnEndTouchAll = PrepareOutput(m_strOnEndTouchAll, strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = PrepareOutput(m_strOnTrigger, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_multiple::Spawned(void)
{
	super::Spawned();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);
	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
	if (m_strOnEndTouchAll)
		m_strOnEndTouchAll = CreateOutput(m_strOnEndTouchAll);
}

void
trigger_multiple::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_multiple::Touch(entity eToucher)
{
	if (GetMaster() == FALSE)
		return;
	if (HasSpawnFlags(TM_NOCLIENTS) && eToucher.flags & FL_CLIENT)
		return;
	if (!HasSpawnFlags(TM_MONSTERS) && eToucher.flags & FL_MONSTER)
		return;
	if (!HasSpawnFlags(TM_PUSHABLES) && eToucher.classname == "func_pushable")
		return;

	if (g_grMode.IsTeamplay() == TRUE) {
		if (m_iTeam > 0 && eActivator.team != m_iTeam + 1) {
			return;
		}
	}

	/* if the target key isn't used, assume we're using the new I/O system */
	if (HasTriggerTarget() == false)
		UseOutput(eToucher, m_strOnStartTouch);
	else
		UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);

	/* This is effectively a trigger_once...*/
	if (m_flWait != -1) {
		ScheduleThink(Respawn, m_flWait);
	}

	SetSolid(SOLID_NOT);
}

void
trigger_multiple::EndTouch(entity eToucher)
{
	if (m_strOnEndTouchAll)
		UseOutput(eToucher, m_strOnEndTouchAll);
}
