/*
 * Copyright (c) 2025 Vera Visions LLC.
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

/*! \brief Server-Entity: Trigger-Based Round End-er */
/*!QUAKED trigger_endround (.5 .5 .5) ?
# OVERVIEW
Requests the game rules to end the round.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Zombie Panic! (2004).

@ingroup serverentity
@ingroup brushentity
*/

class
trigger_endround:ncBrushTrigger
{
public:
	void trigger_endround(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Touch(entity);
};

void
trigger_endround::trigger_endround(void)
{
}

void
trigger_endround::Save(float handle)
{
	super::Save(handle);
}

void
trigger_endround::Restore(string strKey, string setValue)
{
	switch (strKey) {
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_endround::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	default:
		super::SpawnKey(strKey, setValue);
		break;
	}
}

void
trigger_endround::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_endround::Trigger(entity act, triggermode_t unused)
{
	g_grMode.Input(act, "EndRound", "");
}

void
trigger_endround::Touch(entity eToucher)
{
	Trigger(eToucher, TRIG_TOGGLE);
}
