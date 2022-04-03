/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED item_food (1 0 0) (-8 -8 -8) (8 8 8)
This is a food item that will give the user 1 health when touched.

-------- KEYS --------
"targetname" : Name
"angles" : Sets the pitch, yaw and roll angles of the model.
"model" : Model file that will be displayed by the entity.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class item_food:NSEntity
{
	int m_iIsCan;

	void(void) item_food;

	virtual void(void) Setup;
	virtual void(entity) Touch;
};

void item_food::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}
	
	if (owner != __NULL__) {
		env_beverage bevOwner = (env_beverage)owner;
		bevOwner.m_iReady = TRUE;
	}
	
	Damage_Apply(eToucher, this, -1, 0, DMG_GENERIC);
	SetSolid(SOLID_NOT);
	remove(this);
}

void item_food::Setup(void)
{
	SetSolid(SOLID_TRIGGER);
	SetSize([-16,-16,-16], [16,16,16]);

	if (m_iIsCan) {
		sound(this, CHAN_ITEM, "weapons/g_bounce3.wav", 1.0f, ATTN_NORM);
	}
}

void item_food::item_food(void)
{
	// TODO: differentiate between item_sodacan and item_food
	m_iIsCan = 1;

	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_TOSS);

	if (m_iIsCan) {
		SetModel("models/can.mdl");
	}

	SetSize([0,0,0], [0,0,0]);
	think = Setup;
	nextthink = time + 1.0f;
}

CLASSEXPORT(item_sodacan, item_food)
