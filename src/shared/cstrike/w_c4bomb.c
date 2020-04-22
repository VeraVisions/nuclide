/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_c4bomb (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_c4.mdl"

COUNTER-STRIKE (1999) ENTITY

C4 Bomb Weapon, Bomb Defusal Gamemode Entity

Default arsenal for Terrorists

Can only be picked up by Terrorists and planted in
func_bombtarget brush entities.

*/

/* C4 entity logic */
#ifdef SERVER
class c4bomb:CBaseEntity
{
	entity m_eUser;
	float m_flBeepTime;
	float m_flExplodeTime;
	float m_flDefusalState;

	void(void) c4bomb;
	virtual void(void) PlayerUse;
	virtual void(void) Logic;
};

void
c4bomb::PlayerUse(void)
{
	m_eUser = eActivator;
	m_flDefusalState += frametime;
}

void
c4bomb::Logic(void)
{
	// If the guy who started using us stopped using us, reset the defuser counter
	if (m_eUser != world) {
		m_eUser= world;
		m_flDefusalState = 0.0f;
	}

	// If our time has passed, explode
	if (m_flExplodeTime < time) {
		CSMultiplayerRules rules = (CSMultiplayerRules)g_grMode;

		/* In Bomb Defusal, all Terrorists receive $3500
		 * if they won by detonating the bomb. */
		rules.RoundOver(TEAM_T, 3500, FALSE);
		Damage_Radius(origin, this.owner, 500, g_cstrike_bombradius, TRUE, WEAPON_C4BOMB);
		sound(this, CHAN_VOICE, "weapons/c4_explode1.wav", 1.0, ATTN_NONE);

		for (entity e = world; (e = find(e, ::classname, "func_bomb_target"));) {
			CBaseTrigger trigger = (CBaseTrigger)e;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger();
			}
		}

		m_flBeepTime = 0.0f;
		m_flDefusalState = 0;
		remove(this);
		return;
	}

	if (m_flBeepTime > time) {
		return;
	}
	m_flBeepTime = time + 1.5;

	if (m_flExplodeTime - time < 2) {
		sound(this, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NONE);
	} else if (m_flExplodeTime - time < 5) {
		sound(this, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 10) {
		sound(this, CHAN_VOICE, "weapons/c4_beep4.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 20) {
		sound(this, CHAN_VOICE, "weapons/c4_beep3.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 30) {
		sound(this, CHAN_VOICE, "weapons/c4_beep2.wav", 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "weapons/c4_beep1.wav", 1.0, ATTN_NORM);
	}
}

void
c4bomb::c4bomb(void)
{
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetModel("models/w_c4.mdl");
	SetSize([-6,-6,0], [6,6,6]);

	customphysics = Logic;
	m_flExplodeTime = time + 45.0f;

	sound(this, CHAN_WEAPON, "weapons/c4_plant.wav", 1.0f, ATTN_IDLE);
}
#endif

/* C4 weapon logic */

enum
{
	C4_IDLE,
	C4_DRAW,
	C4_DROP,
	C4_ENTERCODE
};

enum
{
	C4S_NONE,
	C4S_ENTERINGCODE,
	C4S_DROPPING,
	C4S_DONE
};

void
w_c4bomb_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_c4bomb.disarm");
	Sound_Precache("weapon_c4bomb.disarmed");
	Sound_Precache("weapon_c4bomb.explode");
	Sound_Precache("weapon_c4bomb.plant");
	precache_sound("weapons/c4_plant.wav");
	precache_sound("weapons/c4_beep1.wav");
	precache_sound("weapons/c4_beep2.wav");
	precache_sound("weapons/c4_beep3.wav");
	precache_sound("weapons/c4_beep4.wav");
	precache_sound("weapons/c4_beep5.wav");
	precache_sound("weapons/c4_explode1.wav");
#endif
	precache_model("models/v_c4.mdl");
	precache_model("models/w_c4.mdl");
	precache_model("models/p_c4.mdl");
}

void
w_c4bomb_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.a_ammo1, pl.a_ammo2, pl.a_ammo3);
#endif
}

string
w_c4bomb_wmodel(void)
{
	return "models/w_c4.mdl";
}

string
w_c4bomb_pmodel(void)
{
	return "models/p_c4.mdl";
}

string
w_c4bomb_deathmsg(void)
{
	return "";
}

void
w_c4bomb_draw(void)
{
	Weapons_SetModel("models/v_c4.mdl");
	Weapons_ViewAnimation(C4_DRAW);
}

void
w_c4bomb_release(void)
{
	player pl = (player)self;
	
	if (pl.a_ammo1 == C4S_DROPPING) {
		if (pl.w_idle_next <= 0.0f) {
			pl.a_ammo1 = C4S_DONE;
#ifdef SERVER
			c4bomb bomb = spawn(c4bomb);
			bomb.owner = pl;

			/* place directly below */
			traceline(pl.origin, pl.origin + [0,0,-64], FALSE, pl);
			setorigin(bomb, trace_endpos);

			Radio_BroadcastMessage(RADIO_BOMBPL);
			g_cs_bombplanted = TRUE;
			Weapons_RemoveItem(pl, WEAPON_C4BOMB);
#endif
		}
		return;
	}

	/* reset animation */
	if (pl.a_ammo1 != C4S_NONE) {
		Weapons_ViewAnimation(C4_IDLE);
	}
	pl.a_ammo1 = C4S_NONE;
	pl.w_idle_next = 0.0f;
}

void
w_c4bomb_primary(void)
{
	player pl = (player)self;

	if (!(pl.flags & FL_BOMBZONE)) {
		return;
	}

	pl.flags |= FL_FROZEN;

	switch (pl.a_ammo1) {
	case C4S_NONE:
			pl.a_ammo1 = C4S_ENTERINGCODE;
			Weapons_ViewAnimation(C4_ENTERCODE);
			pl.w_idle_next = 3.0f;
			break;
	case C4S_ENTERINGCODE:
			if (pl.w_idle_next <= 0.0f) {
				pl.a_ammo1 = C4S_DROPPING;
				Weapons_ViewAnimation(C4_DROP);
				pl.w_idle_next = 1.0f;
			}
			break;
	case C4S_DROPPING:
			w_c4bomb_release();
			return;
			break;
	default:
		break;
	}

	pl.w_attack_next = 0.0f;
}

float
w_c4bomb_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_C4 : ANIM_AIM_C4;
}

void
w_c4bomb_hud(void)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [96/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_c4bomb_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud1.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_c4bomb =
{
	ITEM_C4BOMB,
	4,
	0,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_c4bomb_draw,
	__NULL__,
	w_c4bomb_primary,
	__NULL__,
	__NULL__,
	w_c4bomb_release,
	w_c4bomb_hud,
	w_c4bomb_precache,
	__NULL__,
	w_c4bomb_updateammo,
	w_c4bomb_wmodel,
	w_c4bomb_pmodel,
	w_c4bomb_deathmsg,
	w_c4bomb_aimanim,
	w_c4bomb_hudpic
};

#ifdef SERVER
void
weapon_c4bomb(void)
{
	Weapons_InitItem(WEAPON_C4BOMB);
}
#endif
