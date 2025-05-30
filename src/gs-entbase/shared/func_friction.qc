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

/*! \brief Shared-Entity: Ground Friction Override Volume */
/*!QUAKED func_friction (0 .5 .8) ?
# OVERVIEW
Volume that permanently adds a modifier that affects an entities' friction.
Higher value = less friction.

# KEYS
- "targetname" : Name
- "modifier" : Friction modifier.

# NOTES
Similar to trigger_gravity in that you want to make sure the friction is reset
around the primary volume in case that's the effect that you desire.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup brushentity
*/
class func_friction:ncEntity
{
public:
	void func_friction(void);
	
	virtual void Touch(entity);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);

private:
	float m_flFriction;
};

void
func_friction::Touch(entity eToucher)
{
	eToucher.friction = m_flFriction;
}

void
func_friction::Respawn(void)
{
	SetModel(model);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSPTRIGGER);

	solid = SOLID_BSPTRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void
func_friction::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "modifier":
		m_flFriction = stof(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
func_friction::func_friction(void)
{
}
