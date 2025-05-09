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

/* dependency from item_food.cpp */
void item_sodacan(void);

typedef enum
{
	SKIN_COCACOLA = 0,
	SKIN_SPRITE,
	SKIN_DIETCOKE,
	SKIN_ORANGE,
	SKIN_SURGE,
	SKIN_MOXIE,
	SKIN_RANDOM
} sodaskin_t;

/*! \brief Server-Entity: Health Refuelling Beverage */
/*!QUAKED env_beverage (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Upon being triggered, the entity will spawn item_food in its place in
the shape of a soda can.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "health" : Amount of soda-cans that can be dispensed at maximum
- "angles" : Sets the pitch, yaw and roll angles of the soda
- "skin"   : Sets the beverage type. Values from 0-6 are valid. Check notes.

# NOTES
Mainly used in vending machines. You can choose a few select types of beverage.

Beverage-list:
	- 0 : Coca Cola
	- 1 : Sprite
	- 2 : Diet Coke
	- 3 : Orange
	- 4 : Surge
	- 5 : Moxie
	- 6 : Random (will pack one of the above, picked at the start of the map)

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
env_beverage:ncRenderableEntity
{
public:
	void env_beverage(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Precache(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);

private:
	int m_usesLeft;
	sodaskin_t m_sodaSkin;
};

void
env_beverage::env_beverage(void)
{
	m_usesLeft = 15;
	m_sodaSkin = 0;
}

void
env_beverage::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_usesLeft", m_usesLeft);
	SaveFloat(handle, "m_sodaSkin", m_sodaSkin);
}

void
env_beverage::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_usesLeft":
		m_usesLeft = ReadInt(setValue);
		break;
	case "m_sodaSkin":
		m_sodaSkin = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_beverage::Precache(void)
{
	precache.Model("models/can.mdl");
	precache.Sound("weapons/g_bounce3.wav");
}

void
env_beverage::Respawn(void)
{
	SetValue(1i);
	m_usesLeft = GetSpawnInt("health");
	m_sodaSkin = GetSpawnInt("skin");

	if (m_sodaSkin == SKIN_RANDOM) {
		m_sodaSkin = rint(random(SKIN_COCACOLA, SKIN_MOXIE));
	}
}

void
env_beverage::Trigger(entity act, triggermode_t unused)
{
	if (GetValue(this) == false || m_usesLeft <= 0) {
		return;
	}

	ncEntity eCan = spawn(ncEntity);
	eCan.Spawn();
	eCan.SetOrigin(GetOrigin());
	eCan.SetAngles(GetAngles());
	eCan.SetOwner(this);
	eCan.ScheduleThink(item_sodacan, 0.0f);
	eCan.SetSkin((float)m_sodaSkin);

	m_usesLeft--;
	SetValue(0i);
}
