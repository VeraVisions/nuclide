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

var float autocvar_tracktrain_dir = 1.0f;

/*QUAKED func_tracktrain (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

Moving platform following along path_* entities that's fully user controlled.
Very unfinished.
*/

enumflags
{
	FTRTRAIN_NOPITCH,
	FTRTRAIN_NOUSE,
	FTRTRAIN_UNUSED,
	FTRTRAIN_NONSOLID
};

class func_tracktrain:CBaseVehicle
{
	/* attributes... */
	float m_flMaxSpeed;
	float m_flStartSpeed;

	CBaseEntity m_ePath;
	CBaseEntity m_eOldPath;
	float m_flSpeed;
	vector m_vecControlMins;
	vector m_vecControlMaxs;

	void(void) func_tracktrain;

	virtual void(void) customphysics;
	virtual void(entity, int) Trigger;
	virtual void(void) CheckPathFW;
	virtual void(void) CheckPathRV;
	virtual void(void) UpdateAngles;
	virtual void(void) PlayerUse;
	virtual void(void) Realign;
	virtual void(void) Respawn;
};

void
func_tracktrain::Trigger(entity act, int state)
{
	m_flSpeed = 1.0f;
}

void
func_tracktrain::CheckPathFW(void)
{
	if (vlen(m_ePath.origin - origin) < 1.0f) {
		entity f;
		CBaseEntity current, next;
		current = (CBaseEntity)m_ePath;

		for (f = world; (f = find(f, ::targetname, current.target));) {
			/* we found the right entity */
			if (f.classname == "path_track" || f.classname == "path_corner") {
				CBaseTrigger oldtrig;
				oldtrig = (CBaseTrigger)m_ePath;
				oldtrig.Trigger(this, TRIG_TOGGLE);
				next = f;
				break;
			}
		}

		m_eOldPath = m_ePath;
		m_ePath = (entity)next;
	}
}

void
func_tracktrain::CheckPathRV(void)
{
	if (vlen(m_ePath.origin - origin) < 1.0f) {
		entity f;
		CBaseEntity current, next;
		current = (CBaseEntity)m_ePath;

		for (f = world; (f = find(f, ::target, current.targetname));) {
			/* we found the right entity */
			if (f.classname == "path_track" || f.classname == "path_corner") {
				next = f;
			}
		}

		m_eOldPath = m_ePath;
		m_ePath = (entity)next;
	}
}

void
func_tracktrain::UpdateAngles(void)
{
	vector new_ang;
	vector old_ang;
	vector tmp;
	float progress;
	CBaseEntity reallyold, reallynew;
	entity f;

	for (f = world; (f = find(f, ::target, m_eOldPath.targetname));) {
		if (f.classname == "path_track" || f.classname == "path_corner") {
				reallyold = f;
		}
	}
	
	for (f = world; (f = find(f, ::targetname, m_ePath.target));) {
		if (f.classname == "path_track" || f.classname == "path_corner") {
				reallynew = f;
		}
	}

	makevectors(vectoangles(m_eOldPath.origin - reallyold.origin));
	old_ang = v_forward;

	makevectors(vectoangles(m_ePath.origin - m_eOldPath.origin));
	new_ang = v_forward;

	progress = vlen(m_ePath.origin - origin);
	progress /= vlen(m_eOldPath.origin - m_ePath.origin);
	progress = 1.0f - progress;

	/* print(sprintf("%f %d %d\n", progress, vlen(m_ePath.origin - origin), vlen(m_eOldPath.origin - m_ePath.origin))); */

	tmp[0] = Math_Lerp(old_ang[0], new_ang[0], progress);
	tmp[1] = Math_Lerp(old_ang[1], new_ang[1], progress);
	tmp[2] = Math_Lerp(old_ang[2], new_ang[2], progress);
	angles = vectoangles(tmp);
}

void
func_tracktrain::customphysics(void)
{
	/* eject the dead */
	if (m_eDriver && m_eDriver.health <= 0) {
		PlayerLeave((base_player)m_eDriver);
	}

	if (m_eDriver) {
		if (m_eDriver.movement[0] > 0) {
			m_flSpeed = bound(0, m_flSpeed += frametime, 1.0f);
		} else if (m_eDriver.movement[0] < 0) {
			m_flSpeed = bound(0, m_flSpeed -= frametime, 1.0f);
		}
		m_eDriver.flags |= FL_FROZEN;
	}

	//m_flSpeed = autocvar_tracktrain_dir;

	if (m_flSpeed > 0.0f) {
		makevectors(vectoangles(m_ePath.origin - origin));
		velocity = (v_forward * (m_flMaxSpeed * m_flSpeed));
		setorigin(this, origin + (velocity * frametime));
		UpdateAngles();
	} else {
		makevectors(vectoangles(m_eOldPath.origin - origin));
		velocity = (v_forward * (m_flMaxSpeed * m_flSpeed));
		setorigin(this, origin + (velocity * frametime));
	}

	if (m_flSpeed > 0.0f)
		CheckPathFW();
	else if (m_flSpeed < 0.0f)
		CheckPathRV();

	PlayerAlign();

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void
func_tracktrain::PlayerUse(void)
{
	vector matrix;
	vector offs;
	offs = eActivator.origin - origin;

	makevectors(angles);
	matrix[0] = dotproduct(offs, v_forward);
	matrix[1] = -dotproduct(offs, v_right);
	matrix[2] = dotproduct(offs, v_up);

	if not (matrix[0] >= m_vecControlMins[0] && matrix[0] <= m_vecControlMaxs[0])
		return;
	if not (matrix[1] >= m_vecControlMins[1] && matrix[1] <= m_vecControlMaxs[1])
		return;
	if not (matrix[2] >= m_vecControlMins[2] && matrix[2] <= m_vecControlMaxs[2])
		return;

	if (m_eDriver == eActivator) {
		PlayerLeave((base_player)eActivator);
	} else if (!m_eDriver) {
		PlayerEnter((base_player)eActivator);
	}
}

void
func_tracktrain::Realign(void)
{
	entity t;
	entity f;
	CBaseEntity first, second;
	string strFirst, strSecond;

	first = second = t = f = __NULL__;

	for (f = world; (f = find(f, ::target, targetname));) {
		/* we found the right entity */
		if (f.classname == "func_tracktraincontrols") {
			t = f;
		}
	}

	if (t) {
		vector offs;
		offs = t.origin - origin;
		m_vecControlMins = t.mins + offs;
		m_vecControlMaxs = t.maxs + offs;
	} else if (!(spawnflags & FTRTRAIN_NOUSE)) {
		m_vecControlMins = [-1024,-1024,-1024];
		m_vecControlMaxs = m_vecControlMins * -1;
	}

	/* we rotate and position ourselves after the first path_track/corner */
	strFirst = target;
	for (f = world; (f = find(f, ::targetname, strFirst));) {
		/* we found the right entity */
		if (f.classname == "path_track" || f.classname == "path_corner") {
			first = (CBaseEntity)f;
		}
	}

	/* now get the second one... */
	strSecond = first.target;
	for (f = world; (f = find(f, ::targetname, strSecond));) {
		/* we found the right entity */
		if (f.classname == "path_track" || f.classname == "path_corner") {
			second = (CBaseEntity)f;
		}
	}

	if (first && second) {
		first = (CBaseEntity)first;
		second = (CBaseEntity)second;
		angles = vectoangles(first.origin - second.origin);
		setorigin(this, first.origin);
	}

	m_eOldPath = (entity)first;
	m_ePath = (entity)second;
}

void
func_tracktrain::Respawn(void)
{
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetAngles(m_oldAngle);
	owner = m_eDriver = __NULL__;
	velocity = [0,0,0];

	think = Realign;
	nextthink = time + 0.1f;

	m_flSpeed = m_flStartSpeed / m_flMaxSpeed;
}

void
func_tracktrain::func_tracktrain(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "speed":
			m_flMaxSpeed = stof(argv(i+1));
			break;
		case "startspeed":
			m_flStartSpeed = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	CBaseVehicle::CBaseVehicle();
}
