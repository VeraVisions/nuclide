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

/** This entity class represents an interactive projectile.
Objects such as rockets, grenades, bolts etc. should ideally be this. */
class NSProjectile:NSSurfacePropEntity
{
private:
	/* sprite animation gubbins */
	int m_iProjectileAnimEnd;
	int m_iProjectileAnimStart;
	float m_flProjectileFramerate;
	virtual void m_pImpact(entity, entity) = 0;

	nonvirtual void _AnimateThink(void);
	nonvirtual void _AnimateThinkDead(void);

public:
	void NSProjectile(void);

	/** Sets the function that'll be called upon impact of the projectile onto a surface. */
	nonvirtual void SetImpact(void(entity, entity));
	/** When called, will animated between two frame positions at a specified framerate on loop. */
	nonvirtual void Animate(int, int, float);
	/** When called, will animated between two frame positions at a specified framerate and remove itself when it has finished playing the sequence. */
	nonvirtual void AnimateOnce(int, int, float);

	/** Called upon the projectile touching another object. */
	virtual void Touch(entity);
	virtual void Spawned(void);
};
