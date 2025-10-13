/*
 * Copyright (c) 2015-2021 Vera Visions L.L.C.
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

/*QUAKED item_ammo_crate (.3 .3 1) (-17 -17 -15) (17 17 15)


-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/ammo/crate/crate.vvm"
*/

typedef enum
{
	CRATE_CLOSED,
	CRATE_OPEN,
	CRATE_OPENING,
	CRATE_CLOSING
} ammocrate_state;

enum
{
	ANIM_AC_CLOSED = 0,
	ANIM_AC_OPENING,
	ANIM_AC_OPEN,
	ANIM_AC_CLOSING
};

class item_ammo_crate:ncRenderableEntity
{
public:
	void item_ammo_crate(void);

	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void PlayerUse(void);
	virtual void PlayerUseUnpressed(void);
	virtual void RestockPlayer(void);
	virtual void RestockAmmo(void);
	virtual void Open(void);
	virtual void Close(void);

private:
	ammocrate_state m_stState;
	ncPlayer m_eRestock;
};


void
item_ammo_crate::item_ammo_crate(void)
{
	m_stState = ANIM_AC_CLOSED;
	m_eRestock = __NULL__;
}


void
item_ammo_crate::Open(void)
{
	static void Opened(void) {
		SetFrame(ANIM_AC_OPEN);
		m_stState = CRATE_OPEN;

		/* close after 4 secs */
		think = Close;
		nextthink = time + 4.0f;
	}

	SetFrame(ANIM_AC_OPENING);
	m_stState = CRATE_OPENING;
	think = Opened;
	nextthink = time + 2.0f;
}

void
item_ammo_crate::Close(void)
{
	static void Closed(void) {
		SetFrame(ANIM_AC_CLOSED);
		m_stState = CRATE_CLOSED;
	}

	SetFrame(ANIM_AC_CLOSING);
	m_stState = CRATE_CLOSING;
	think = Closed;
	nextthink = time + 2.0f;
}

void
item_ammo_crate::RestockAmmo(void)
{
	if (eActivator.classname != "player")
		return;

	player pl = (player)eActivator;

	SoundDef_Play(this, CHAN_BODY, "ammo_container.use");

	for (int i = 0; i < g_weapons.length; i++)
		if (pl.g_items & g_weapons[i].id)
			for (int x = 0; x < 8; x++)
				Weapons_AddItem(pl, i, -1);
}

void
item_ammo_crate:: RestockPlayer(void)
{
	TWGameRules rules = (TWGameRules) g_grMode;
	m_eRestock.g_items = 0;
	rules.EquipLoadout(m_eRestock);
	Sound_Play(this, CHAN_BODY, "ammo_container.use");
	m_eRestock = __NULL__; /* signal the Unpressed function that we're done */
}

void
item_ammo_crate::PlayerUse(void)
{
	/* don't allow other players to use, while in-use */
	if (m_eRestock)
		return;

	if (m_stState == CRATE_CLOSED || m_stState == CRATE_CLOSING)
		Open();

	/* remember who used us */
	m_eRestock = (player)eActivator;

	if (Game_GetMode() == GAME_INVASION) {
		/* if we're still holding down a second from now, restock the player */
		think = RestockPlayer;
		nextthink = time + 1.0f;
	} else {
		RestockAmmo();
	}
}

void
item_ammo_crate:: PlayerUseUnpressed(void)
{
	/* kill any restocking operation in progress once un-pressed */
	think = __NULL__;
	nextthink = 0.0f;

	/* if somebody was successfully using us, close */
	if (!m_eRestock) {
		Close();
		return;
	}

	m_eRestock = __NULL__;

	if (Game_GetMode() == GAME_INVASION) {
		RestockAmmo();
	} else {
		think = Close;
		nextthink = time + 2.0f;
	}
}

void
item_ammo_crate::Respawn(void)
{
	if (Game_GetMode() == GAME_MISSIONMODE || Game_GetMode() == GAME_EDITOR) {
		if (!(gflags & GF_MISSION))
			Destroy();
	}

	if (Game_GetMode() == GAME_VEHICLE)
		Destroy();

	m_stState = CRATE_CLOSED;
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetModel(GetSpawnString("model"));
	SetAngles(GetSpawnAngles());
	SetSize([-17,-17,-15], [17,17,15]);
	SetOrigin(GetSpawnOrigin() + [0,0,15]);
	SetRenderFX(RFX_Q2PULSE);
	SetRenderColor([1.0,1.0,0.0]);
	SetFrame(ANIM_AC_CLOSED);
}

void
item_ammo_crate::Spawned(void)
{
	super::Spawned();
}
