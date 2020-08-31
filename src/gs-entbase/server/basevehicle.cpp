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

class CBaseVehicle:CBaseTrigger
{
	entity m_eDriver;

	void(void) CBaseVehicle;
	vector m_vecPlayerPos;

	virtual void(void) PlayerAlign;
	virtual void(base_player) PlayerEnter;
	virtual void(base_player) PlayerLeave;
};

void
CBaseVehicle::PlayerAlign(void)
{
	vector vecPlayerPos;

	if (!m_eDriver)
		return;

	makevectors(angles);
	vecPlayerPos = origin + v_forward * m_vecPlayerPos[0];
	vecPlayerPos += v_right * m_vecPlayerPos[1];
	vecPlayerPos += v_up * m_vecPlayerPos[2];

	setorigin(m_eDriver, vecPlayerPos);
}

void
CBaseVehicle::PlayerEnter(base_player pl)
{
	vector offs;

	/* cache the position */
	offs = pl.origin - origin;

	makevectors(angles);
	m_vecPlayerPos[0] = dotproduct(offs, v_forward);
	m_vecPlayerPos[1] = dotproduct(offs, v_right);
	m_vecPlayerPos[2] = dotproduct(offs, v_up);
	pl.movetype = MOVETYPE_NOCLIP;
	m_eDriver = (entity)pl;
}

void
CBaseVehicle::PlayerLeave(base_player pl)
{
	pl.movetype = MOVETYPE_WALK;
	pl.flags &= ~FL_FROZEN;
	m_eDriver = __NULL__;
}

void
CBaseVehicle::CBaseVehicle(void)
{
	CBaseEntity::CBaseEntity();
}
