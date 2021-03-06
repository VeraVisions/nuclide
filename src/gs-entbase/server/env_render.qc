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

/*QUAKED env_render (1 0 0) (-8 -8 -8) (8 8 8) SF_NORENDERFX SF_NORENDERAMT SF_NORENDERMODE SF_NORENDERCOLOR
Changes the visual appearance of a target.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"rendermode" : Render-Mode the target changes to.
"renderamt" : Render-Amount the target changes to.
"rendercolor" : Render-Color the target changes to.
"renderfx" : Render-FX the target changes to.

-------- SPAWNFLAGS --------
SF_NORENDERFX : Don't set the Render-FX attribute on the target.
SF_NORENDERAMT : Don't set the Render-Amount attribute on the target.
SF_NORENDERMODE : Don't set the Render-Mode attribute on the target.
SF_NORENDERCOLOR : Don't set the Render-Color attribute on the target.

-------- NOTES --------
The Render-FX values are currently unimplemented, except for the hologram setting.

Supported Render-Mode ("rendermode") values:
0 : Normal; Default.
1 : Color; Tints the entity after whatever "rendercolor" is set to.
2 : Texture; ???
3 : Glow; object scales against the camera depending on distance like a flare.
4 : Solid; Make transparent by respecting transparent pixels (GoldSrc)
5 : Additive; Blend the object additively against the world.
6 : Fullbright; Render the object without lighting.
7 : Trigger; Will only show when the console variable cl_showtriggers is set to 1.

Supported Render-FX ("renderfx") values:
0 : Normal
1 : Slow pulse
2 : Fast pulse
3 : Slow, wide, pulse
4 : Fast, wide, pulse
5 : Slow fade away
6 : Fast fade away
7 : Slow become solid
8 : Fast become solid
9 : Slow strobe
10 : Fast strobe
11 : Faster strobe
12 : Slow flicker
13 : Fast flicker
14 : Constant glow
15 : Distort
16 : Hologram

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

#ifdef GS_RENDERFX
enumflags
{
	SF_NORENDERFX,
	SF_NORENDERAMT,
	SF_NORENDERMODE,
	SF_NORENDERCOLOR
};

class env_render:CBaseTrigger
{
	void(void) env_render;
	virtual void(entity, int) Trigger;
};

void
env_render::Trigger(entity act, int state)
{
	for (entity e = world;
		(e = find(e, ::targetname, target));) {
		CBaseEntity trigger = (CBaseEntity)e;

		dprint(sprintf("^2env_render::^3Trigger^7: with spawnflags %d\n", spawnflags));
			dprint(sprintf("\tTarget: %s\n", target));
		if (!(spawnflags & SF_NORENDERMODE)) {
			dprint(sprintf("\tMode change from %d to %d\n", trigger.m_iRenderMode, m_iRenderMode));
			trigger.SetRenderMode(m_iRenderMode);
		}
		if (!(spawnflags & SF_NORENDERCOLOR)) {
			dprint(sprintf("\tColor change from %v to %v\n", trigger.m_vecRenderColor, m_vecRenderColor));
			trigger.SetRenderColor(m_vecRenderColor);
		}
		if (!(spawnflags & SF_NORENDERAMT)) {
			dprint(sprintf("\tAmt change from %d to %d\n", trigger.m_flRenderAmt, m_flRenderAmt));
			trigger.SetRenderAmt(m_flRenderAmt);
		}
		if (!(spawnflags & SF_NORENDERFX)) {
			dprint(sprintf("\tFX change from %i to %i\n", trigger.m_iRenderFX, m_iRenderFX));
			trigger.SetRenderFX(m_iRenderFX);
		}
	}
}

void
env_render::env_render(void)
{
	CBaseTrigger::CBaseTrigger();
}
#endif
