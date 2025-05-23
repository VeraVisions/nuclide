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

/*! \brief Server-Entity: AI Jump Hint */
/*!QUAKED trigger_monsterjump (.5 .5 .5) ?
# OVERVIEW
When monsters touch this volume, they will be forced to jump.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "speed" : Speed of the jump.
- "height" : Height of the jump.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
trigger_monsterjump:ncBrushTrigger
{
public:
	void trigger_monsterjump(void);
	
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);

private:
	float m_jumpSpeed;
	float m_jumpHeight;
};

void
trigger_monsterjump::trigger_monsterjump(void)
{
	m_jumpSpeed = 0.0f;
	m_jumpHeight = 0.0f;
}

void
trigger_monsterjump::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "speed":
		m_jumpSpeed = ReadFloat(setValue);
		break;
	case "height":
		m_jumpHeight = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
trigger_monsterjump::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "jumpSpeed", m_jumpSpeed);
	SaveFloat(handle, "jumpHeight", m_jumpHeight);
}

void
trigger_monsterjump::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "jumpSpeed":
		m_jumpSpeed = ReadFloat(setValue);
		break;
	case "jumpHeight":
		m_jumpHeight = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_monsterjump::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_monsterjump::Touch(entity touchingEntity)
{
	vector targetVelocity = g_vec_null;

	if (!(touchingEntity.flags & FL_MONSTER)) {
		return;
	}

	if (GetMaster(touchingEntity) == false) {
		return;
	}

	ncMonster theMonster = (ncMonster)touchingEntity;
	targetVelocity = theMonster.GetForward() * m_jumpSpeed;
	targetVelocity[2] += m_jumpHeight;
	theMonster.SetVelocity(targetVelocity);
}