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

enumflags
{
	SF_NORENDERFX,
	SF_NORENDERAMT,
	SF_NORENDERMODE,
	SF_NORENDERCOLOR
};

/*! \brief Server-Entity: Controls Entity Rendering Modes */
/*!QUAKED env_render (1 .5 0) (-8 -8 -8) (8 8 8) SF_NORENDERFX SF_NORENDERAMT SF_NORENDERMODE SF_NORENDERCOLOR
# OVERVIEW
Changes the visual appearance of a target.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "rendermode" : Render-Mode the target changes to.
- "renderamt" : Render-Amount the target changes to.
- "rendercolor" : Render-Color the target changes to.
- "renderfx" : Render-FX the target changes to.

# SPAWNFLAGS
- SF_NORENDERFX (1) : Don't set the Render-FX attribute on the target.
- SF_NORENDERAMT (2) : Don't set the Render-Amount attribute on the target.
- SF_NORENDERMODE (4) : Don't set the Render-Mode attribute on the target.
- SF_NORENDERCOLOR (8) : Don't set the Render-Color attribute on the target.

# NOTES
The Render-FX values are currently unimplemented, except for the hologram setting.

Supported Render-Mode ("rendermode") values:
	- 0 : Normal; Default.
	- 1 : Color; Tints the entity after whatever "rendercolor" is set to.
	- 2 : Texture; ???
	- 3 : Glow; object scales against the camera depending on distance like a flare.
	- 4 : Solid; Make transparent by respecting transparent pixels (GoldSrc)
	- 5 : Additive; Blend the object additively against the world.
	- 6 : Fullbright; Render the object without lighting.

Supported Render-FX ("renderfx") values:
	- 0 : Normal
	- 1 : Slow pulse
	- 2 : Fast pulse
	- 3 : Slow, wide, pulse
	- 4 : Fast, wide, pulse
	- 5 : Slow fade away
	- 6 : Fast fade away
	- 7 : Slow become solid
	- 8 : Fast become solid
	- 9 : Slow strobe
	- 10 : Fast strobe
	- 11 : Faster strobe
	- 12 : Slow flicker
	- 13 : Fast flicker
	- 14 : Constant glow
	- 15 : Distort
	- 16 : Hologram

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup pointentity
*/
class
env_render:NSRenderableEntity
{
public:
	void env_render(void);
	
	virtual void Trigger(entity, triggermode_t);

};

void
env_render::env_render(void)
{
}

void
env_render::Trigger(entity act, triggermode_t state)
{
	for (entity e = world;
		(e = find(e, ::targetname, target));) {
		NSRenderableEntity trigger = (NSRenderableEntity)e;

		EntLog("Triggering with spawnflags %d", spawnflags);
			EntLog("\tTarget: %s", target);
		if (!HasSpawnFlags(SF_NORENDERMODE)) {
			EntLog("\tMode change from %d to %d", trigger.m_iRenderMode, m_iRenderMode);
			trigger.SetRenderMode(m_iRenderMode);
		}
		if (!HasSpawnFlags(SF_NORENDERCOLOR)) {
			EntLog("\tColor change from %v to %v", trigger.m_vecRenderColor, m_vecRenderColor);
			trigger.SetRenderColor(m_vecRenderColor);
		}
		if (!HasSpawnFlags(SF_NORENDERAMT)) {
			EntLog("\tAmt change from %d to %d", trigger.m_flRenderAmt, m_flRenderAmt);
			trigger.SetRenderAmt(m_flRenderAmt);
		}
		if (!HasSpawnFlags(SF_NORENDERFX)) {
			EntLog("\tFX change from %d to %d", trigger.m_iRenderFX, m_iRenderFX);
			trigger.SetRenderFX(m_iRenderFX);
		}
	}
}
