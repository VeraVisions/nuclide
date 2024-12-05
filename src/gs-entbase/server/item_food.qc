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

/*! \brief Server-Entity: Food Pickup */
/*!QUAKED item_food (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
This is a food item that will give the user 1 health when touched.

# KEYS
- "targetname" : Name
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "model" : Model file that will be displayed by the entity.

# TRIVIA
This entity was introduced in Half-Life (1998).
It's also known as item_sodacan.

@ingroup serverentity
@ingroup pointentity
*/
class
item_food:ncRenderableEntity
{
public:
	void item_food(void);

	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	nonvirtual void Setup(void);
	virtual void Touch(entity);

private:
	int m_iIsCan;
};

void
item_food::item_food(void)
{
	// TODO: differentiate between item_sodacan and item_food
	m_iIsCan = 1;
}

void
item_food::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iIsCan", m_iIsCan);
}

void
item_food::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iIsCan":
		m_iIsCan = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
item_food::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_TOSS);

	//if (m_iIsCan) {
		SetModel("models/can.mdl");
	//}

	SetSize([0,0,0], [0,0,0]);
	ScheduleThink(Setup, 1.0f);
}

void
item_food::Setup(void)
{
	SetSolid(SOLID_TRIGGER);
	SetSize([-16,-16,-16], [16,16,16]);

	//if (m_iIsCan) {
		sound(this, CHAN_ITEM, "weapons/g_bounce3.wav", 1.0f, ATTN_NORM);
	//}
}

void
item_food::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}
	
	if (owner != __NULL__) {
		env_beverage bevOwner = (env_beverage)owner;
		bevOwner.m_bReady = true;
	}

	eToucher.health = bound(0, eToucher.health + 1, eToucher.max_health);
	SetSolid(SOLID_NOT);
	Destroy();
}

CLASSEXPORT(item_sodacan, item_food)
