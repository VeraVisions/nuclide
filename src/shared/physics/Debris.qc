/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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

#ifdef CLIENT
void
ncDebris::KeepMoving(void)
{
	think = KeepMoving;
	nextthink = time;
}

void
ncDebris::ncDebris(void)
{
	m_decalImpact = __NULL__;
	m_timeUntilNextDecalPlacement = 0.0f;
	touch = _TouchHandler;
	think = KeepMoving;
	nextthink = time;
	dimension_hit = 1;
	dimension_solid = 255;
}

void
ncDebris::Touch(entity touchingEnt)
{
	if (m_timeUntilNextDecalPlacement > time) {
		return;
	}

	if (STRING_SET(m_decalImpact)) {
		DecalGroups_Place(m_decalImpact, origin);
		m_timeUntilNextDecalPlacement = time + 1.0f;
	}
}

void
ncDebris::SetImpactDecal(string impactDecal)
{
	m_decalImpact = impactDecal;
}
#endif
