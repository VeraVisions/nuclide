/*
 * Copyright (c) 2024 Vera Visions LLC.
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
	EYESCANNER_SPAWNFL_DISABLED = 1,
};

enum
{
	EYESCANNER_FRAMEGROUP_CLOSED,
	EYESCANNER_FRAMEGROUP_OPEN,
	EYESCANNER_FRAMEGROUP_EXTEND,
	EYESCANNER_FRAMEGROUP_RETRACT,
};

/*! \brief Server-Entity: Iris Scanner */
/*!QUAKED item_eyescanner (0 .5 .8) ? DISABLED
# OVERVIEW
An Iris Scanner that animates and triggers different targets depending on who's using it.

# KEYS
- "targetname" : Name
- "locked_target" : Target when triggered.
- "unlocked_target" : Target when triggered.

# TRIVIA
This entity was introduced in Half-Life for PS2 (2001).

@ingroup server
@ingroup pointentity
*/
class
item_eyescanner:NSRenderableEntity
{
public:
	void item_eyescanner(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Trigger(entity,triggermode_t);
	virtual void OnPlayerUse(void);

	nonvirtual void Extend(void);
	nonvirtual void Retract(void);
	nonvirtual void AccessDenied(void);
	nonvirtual void AccessGranted(void);
	nonvirtual void StartFlashing(void);
	nonvirtual void StopFlashing(void);

private:
	entity m_toucher;
	entity m_chargeZone;
	string m_strLockedTarget;
	string m_strUnlockedTarget;
	int m_iAnimationCycle;
};

void
item_eyescanner::item_eyescanner(void)
{
	m_strLockedTarget = __NULL__;
	m_strUnlockedTarget = __NULL__;
}

void
item_eyescanner::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "locked_target":
		m_strLockedTarget = strValue;
		break;
	case "unlocked_target":
		m_strUnlockedTarget = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
item_eyescanner::AccessDenied(void)
{
	EntLog("Access denied.");
	StartFlashing();

	if (m_strLockedTarget) {
		target = m_strLockedTarget;
		UseTargets(eActivator, TRIG_TOGGLE, m_flDelay);
	}
}

void
item_eyescanner::AccessGranted(void)
{
	EntLog("Access granted.");
	StartFlashing();

	if (m_strUnlockedTarget) {
		target = m_strUnlockedTarget;
		UseTargets(eActivator, TRIG_TOGGLE, m_flDelay);
	}
}

void
item_eyescanner::StartFlashing(void)
{
	if (GetSkin() == 0) {
		m_iAnimationCycle = 0i;
	}

	SetSkin(GetSkin() + 1);
	m_iAnimationCycle++;

	if (GetSkin() > 3) 
		SetSkin(1);

	if (m_iAnimationCycle > 24) {
		ScheduleThink(StopFlashing, 0.1f);
	} else {
		ScheduleThink(StartFlashing, 0.1f);
	}
}

void
item_eyescanner::StopFlashing(void)
{
	SetSkin(0);
}

void
item_eyescanner::Extend(void)
{
	SetFrame(EYESCANNER_FRAMEGROUP_EXTEND);
}

void
item_eyescanner::Retract(void)
{
	SetFrame(EYESCANNER_FRAMEGROUP_RETRACT);
	m_toucher = __NULL__;
}

void
item_eyescanner::OnPlayerUse(void)
{
	if (HasSpawnFlags(EYESCANNER_SPAWNFL_DISABLED) == true) {
		AccessDenied();
		return;
	}

	AccessGranted();
}

void
item_eyescanner::Trigger(entity act, triggermode_t state)
{
	StartFlashing();
}

void
item_eyescanner::Respawn(void)
{
	static void item_eyescanner_retract(void) {
		item_eyescanner parent = (item_eyescanner)self.owner;
		parent.Retract();
	}

	static void item_eyescanner_notify(void) {
		item_eyescanner parent = (item_eyescanner)self.owner;
		parent.Extend();
		parent.m_toucher = other;
		think = item_eyescanner_retract;
		nextthink = time + 2.0f;
	}

	super::Respawn();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	SetModel("models/eye_scanner.mdl");
	//UpdateBounds();
	SetSize([-16,-16,0], [16,16,128]);
	PlayerUse = OnPlayerUse;

	if (!m_chargeZone) {
		m_chargeZone = spawn();
		setorigin(m_chargeZone, GetOrigin());
		m_chargeZone.solid = SOLID_TRIGGER;
		m_chargeZone.movetype = MOVETYPE_NONE;
		m_chargeZone.touch = item_eyescanner_notify;
		m_chargeZone.owner = this;
		setsize(m_chargeZone, [-96,-96, 0], [96,96, 128]);
	}
}
