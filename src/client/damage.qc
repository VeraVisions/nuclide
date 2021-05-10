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

var string g_damage_spr_t;
var string g_damage_spr_b;
var string g_damage_spr_l;
var string g_damage_spr_r;

void
Damage_Precache(void)
{
	g_damage_spr_t = spriteframe("sprites/640_pain.spr", 0, 0.0f);
	g_damage_spr_r = spriteframe("sprites/640_pain.spr", 1, 0.0f);
	g_damage_spr_b = spriteframe("sprites/640_pain.spr", 2, 0.0f);
	g_damage_spr_l = spriteframe("sprites/640_pain.spr", 3, 0.0f);
}

void
Damage_Draw(void)
{
	vector center;
	vector rel_pos;
	float fw, fw_alpha;
	float rt, rt_alpha;

	if (pSeat->m_flDamageAlpha <= 0.0) {
		return;
	}

	center = video_mins + (video_res / 2);

	/* the pos relative to the player + view_dir determines which
	 * and how bright each indicator is drawn. so first get the relative
	 * position between us and the attacker, then calculate the strength
	 * of each direction based on a dotproduct tested against our
	 * camera direction.
	 */
	rel_pos = normalize(pSeat->m_vecDamagePos - getproperty(VF_ORIGIN));
	makevectors(getproperty(VF_CL_VIEWANGLES));
	fw = dotproduct(rel_pos, v_forward);
	rt = dotproduct(rel_pos, v_right);

	fw_alpha = fabs(fw) * pSeat->m_flDamageAlpha;
	if (fw > 0.25f) {
		drawpic(center + [-64,-102], g_damage_spr_t, 
			[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
	} else if (fw < -0.25f) {
		drawpic(center + [-64,70], g_damage_spr_b,
			[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
	}

	rt_alpha = fabs(rt) * pSeat->m_flDamageAlpha;
	if (rt > 0.25f) {
		drawpic(center + [70,-64], g_damage_spr_r,
			[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
	} else if (rt < -0.25f) {
		drawpic(center + [-102,-64], g_damage_spr_l,
			[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
	}

	pSeat->m_flDamageAlpha -= clframetime;
}

/*
 * engine specific callback for when dmg_ fields are set on the client side.
 * might want to replace it at some point? probably not...
 * hence why 'save' and 'take' are unused.
 */
float
CSQC_Parse_Damage(float save, float take, vector abs_pos)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];

	/* FIXME: while a player shooting you from [0,0,0] is unlikely, it's
	 * not impossible. we only do this to lazily seperate players from
	 * entities belonging to world
	 */
	if (abs_pos) {
		pSeat->m_vecDamagePos = abs_pos;
		pSeat->m_flDamageAlpha = 1.0f;
	}

	return (1);
}
