/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

enum
{
	CHAINSAW_STARTFIRE,
	CHAINSAW_CONTINUEFIRE,
	CHAINSAW_STOPFIRE,
	CHAINSAW_DEPLOY,
	CHAINSAW_HOLSTER,
	CHAINSAW_IDLE1,
	CHAINSAW_IDLE2,
};

void w_chainsaw_precache(void)
{
	precache_sound("sh/chainsaw_cutinto.wav");
	precache_sound("sh/chainsaw_cutintoflesh.wav");
	precache_sound("sh/chainsaw_idle.wav");
	precache_sound("sh/chainsaw_idle2.wav");
	precache_sound("sh/chainsaw_pullout.wav");
	precache_sound("sh/chainsaw_startup.wav");
	precache_model("models/v_chainsaw.mdl");
	precache_model("models/p_saw.mdl");
}

void w_chainsaw_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}
string w_chainsaw_pmodel(void)
{
	return "models/p_saw.mdl";
}
string w_chainsaw_deathmsg(void)
{
	return "%s killed %s with chainsaw.";
}

void w_chainsaw_draw(void)
{
	Weapons_SetModel("models/v_chainsaw.mdl");
	Weapons_ViewAnimation(CHAINSAW_DEPLOY);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

void w_chainsaw_holster(void)
{
	Weapons_ViewAnimation(CHAINSAW_HOLSTER);
}
void w_chainsaw_primary(void)
{
	player pl = (player)self;
	
	if (pl.w_attack_next) {
		return;
	}

	pl.a_ammo3 = 1;
	Weapons_ViewAnimation(CHAINSAW_CONTINUEFIRE);

#ifdef SSQC
	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	
	if (trace_fraction >= 1.0) {
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/chainsaw_idle2.wav", 1, ATTN_NORM);
		pl.w_attack_next = 0.2f;
	} else {
		Effect_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
		
		if (trace_ent.takedamage) {
			if (trace_ent.iBleeds) {
				/* Push the player towards the victim */
				pl.velocity = normalize(trace_ent.origin - pl.origin) * 240;
			}

			Damage_Apply(trace_ent, self, 10, trace_endpos, FALSE );
			Weapons_PlaySound(pl, CHAN_WEAPON, "sh/chainsaw_cutintoflesh.wav", 1, ATTN_NORM);
		} else {
			Effect_CreateSpark(trace_endpos, trace_plane_normal);
			Weapons_PlaySound(pl, CHAN_WEAPON, "sh/chainsaw_cutinto.wav", 1, ATTN_NORM);
		}
		pl.w_attack_next = 0.1f;
	}
#endif

	pl.w_idle_next = 0.0f;
}

void w_chainsaw_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	if (pl.a_ammo3 == 1) {
		pl.a_ammo3 = 0;
		pl.w_idle_next = 1.0f;
		Weapons_ViewAnimation(CHAINSAW_STOPFIRE);
		return;
	} else {
		pl.w_idle_next = 10.0f;
	}

	if (random() < 0.5) {
		Weapons_ViewAnimation(CHAINSAW_IDLE1);
	} else {
		Weapons_ViewAnimation(CHAINSAW_IDLE2);
	}
}

float w_chainsaw_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void w_chainsaw_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/chainsaw.spr_0.tga", [0,48/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/chainsaw.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_chainsaw =
{
	ITEM_CHAINSAW,
	0,
	2,
	"sprites/640hud1.spr_0.tga",
	[48,16],
	[192,80],
	w_chainsaw_draw,
	w_chainsaw_holster,
	w_chainsaw_primary,
	w_chainsaw_release,
	w_chainsaw_release,
	w_chainsaw_release,
	__NULL__,
	w_chainsaw_precache,
	__NULL__,
	w_chainsaw_updateammo,
	__NULL__,
	w_chainsaw_pmodel,
	w_chainsaw_deathmsg,
	w_chainsaw_aimanim,
	w_chainsaw_hudpic
};
