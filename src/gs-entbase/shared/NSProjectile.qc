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

void
NSProjectile::ProjectileTouch(void)
{
	if (m_pImpact)
		m_pImpact(other, this);

	Destroy();
}

void
NSProjectile::SetImpact(void(entity a,entity b) func)
{
	m_pImpact = func;
}

void
NSProjectile::SetModel(string mdl)
{
	super::SetModel(mdl);
	SetSize([0,0,0], [0,0,0]);
}

void
NSProjectile::AnimateThink(void)
{
	frame++;

	if (frame > (float)m_iProjectileAnimEnd)
		frame = (float)m_iProjectileAnimStart;

	nextthink = time + m_flProjectileFramerate;
}

void
NSProjectile::Animate(int startframe, int endframe, float framerate)
{
	m_iProjectileAnimEnd = startframe;
	m_iProjectileAnimStart = endframe;
	m_flProjectileFramerate = framerate;
	frame = startframe;
	think = AnimateThink;
	nextthink = time + m_flProjectileFramerate;
}

void
NSProjectile::NSProjectile(void)
{
	touch = ProjectileTouch;

	SetMovetype(MOVETYPE_FLY);
	SetRenderColor([1,1,1]);
	SetRenderAmt(1.0);
	SetSolid(SOLID_BBOX);
	hitcontentsmaski |= CONTENTBIT_PROJECTILE;
}
