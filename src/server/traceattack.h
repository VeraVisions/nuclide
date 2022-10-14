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

/** This class handles traceline/hitscan attacks. */
class
NSTraceAttack
{
private:
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

	virtual void _ApplyDamage(void);
	virtual void _FireSingle(vector,vector,float,float);

public:
	void NSTraceAttack(void);

	/** Call once your parameters are set up to cast the trace/hitscan */
	virtual void Fire(void);

	/** Sets the number of traces performed. Default is 1. */
	virtual void SetShots(int);
	/** Sets the position of where we're firing from. */
	virtual void SetOrigin(vector);
	/** Sets the amount of damage a single trace will do. */
	virtual void SetDamage(int);
	/** Sets the spread, which increases with distance. */
	virtual void SetSpread(vector);
	/** Sets the weapon associated with the trace. */
	virtual void SetWeapon(int);
	/** Sets the maximum range the trace will cast, before it is discarded. */
	virtual void SetRange(float);
	/** Sets the owner responsible for the trace. */
	virtual void SetOwner(entity);
	
	#ifdef BULLETPENETRATION
	/** Sets the maximum thickness that the trace is not allowed to penetrate.
	Your project needs to have the `BULLETPENETRATION` flag enabled. */
	virtual void SetPenetrationMaxThickness(float);
	/** Sets the power level of the traceline when penetrating surfaces.
	Your project needs to have the `BULLETPENETRATION` flag enabled. */
	virtual void SetPenetrationPower(int);
	#endif

};

NSTraceAttack g_traceAttack;