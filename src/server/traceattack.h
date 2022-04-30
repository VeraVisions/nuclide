/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

void TraceAttack_FireBullets(int iShots, vector vecPos, int iDamage, vector vecSpread, int iWeapon);

#ifdef BULLETPENETRATION
void TraceAttack_SetPenetrationPower(int power);
#endif


class
NSTraceAttack
{
	/* multi-part damage */
	entity m_eMultiTarget;
	int m_iMultiValue;
	int m_iMultiBody;

	int m_iShots;
	float m_flDamage;
	vector m_vecSpread;
	int m_iWeapon;
	entity m_eOwner;
	float m_flRange;
	vector m_vecOrigin;

	/* bullet penetration */
#ifdef BULLETPENETRATION
	float m_flMaxThickness;
	float m_flRangeModifier;
	int m_iTotalPenetrations;
#endif

	void(void) NSTraceAttack;

	virtual void(void) _ApplyDamage;
	virtual void(vector, vector, float, float) _FireSingle;
	virtual void(void) Fire;

	virtual void(int) SetShots;
	virtual void(vector) SetOrigin;
	virtual void(int) SetDamage;
	virtual void(vector) SetSpread;
	virtual void(int) SetWeapon;
	virtual void(float) SetRange;
	virtual void(entity) SetOwner;

#ifdef BULLETPENETRATION
	virtual void(float) SetPenetrationMaxThickness;
	virtual void(int) SetPenetrationPower;
#endif
};

NSTraceAttack g_traceAttack;