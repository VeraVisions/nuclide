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

/*QUAKED func_pushable (0 .5 .8) ? SF_TRIGGER SF_TOUCH SF_PRESSURE
This is essentially the same entity as a func_breakable, but
a player can push and pull it around the level.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.

-------- NOTES --------
It uses stepping player physics to move around.
Please look at func_breakable for more entity keys, inputs and outputs.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class func_pushable:func_breakable
{
	entity m_pPuller;
	entity m_eCollBox;

	void(void) func_pushable;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) customphysics;
	virtual void(void) Respawn;
	virtual void(entity) Touch;
	virtual void(void) OnPlayerUse;
};

void
func_pushable::Save(float handle)
{
	SaveFloat(handle, "puller", num_for_edict(m_pPuller));
	SaveFloat(handle, "collbox", num_for_edict(m_eCollBox));
	super::Save(handle);
}

void
func_pushable::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "puller":
		m_pPuller = edict_num(ReadFloat(strValue));
		break;
	case "collbox":
		m_eCollBox = edict_num(ReadFloat(strValue));
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_pushable::customphysics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_angles = [0,0,0];
	input_timelength = frametime;

	/* we're destroyed, most likely */
	if (m_eCollBox)
	if (modelindex == 0) {
		m_eCollBox.solid = SOLID_NOT;
	} else {
		m_eCollBox.solid = SOLID_BBOX;
	}

	/* when we pull the box, it'll follow us whereever we go, just not too fast so it doesn't clip into us! */
	if (!m_pPuller.button5) {
		m_pPuller = world;
	} else {
		/* drag us, make sure we don't collide */
		velocity[0] = m_pPuller.velocity[0] * 0.9f;
		velocity[1] = m_pPuller.velocity[1] * 0.9f;
	}

	/* see if we're clipping against entities or other func_pushable_bbox helper entities */
	vector position = WorldSpaceCenter();

	/* if we're too far away from our box, split */
	if ((vlen(m_pPuller.origin - position) - vlen(size)) > 64)
		m_pPuller = world;

	tracebox(position, -(size/2) * 0.95f, (size/2) * 0.95f, \
		position + (velocity * input_timelength), MOVE_NORMAL, this);

	if (trace_fraction < 1.0f)
		return;

	/* run the physics, then fix our helper bbox! */
	friction = 0.5f;

	if (vlen(velocity))
		runstandardplayerphysics(this);

	setorigin(m_eCollBox, position);
}

void
func_pushable::Touch(entity eToucher)
{
	/* don't cause bounces */
	if (eToucher.movetype == MOVETYPE_NONE) {
		return;
	}

	/* check if we're inside the pushable */
	if (eToucher.origin[0] >= absmin[0] && eToucher.origin[0] <= absmax[0])
	if (eToucher.origin[1] >= absmin[1] && eToucher.origin[1] <= absmax[1])
		return;

	/* check if we're above the pushable... */
	if ((eToucher.absmin[2] + 16) >= absmax[2]) {
		return;
	}

	/* get the direction of the pushing player towards the pushable, then get a matrix */
	makevectors(vectoangles(eToucher.origin - WorldSpaceCenter()));

	/* add forward direction times speed */
	velocity = v_forward * -64;
}

void
func_pushable::OnPlayerUse(void)
{
	m_pPuller = eActivator;
}

void
func_pushable::Respawn(void)
{
	super::Respawn();
	//SetSolid(SOLID_BSP);
	SetOrigin(GetSpawnOrigin());
	SetMovetype(MOVETYPE_STEP);
	PlayerUse = OnPlayerUse;

	if (!m_eCollBox) {
		m_eCollBox = spawn();
		m_eCollBox.classname = "func_pushable_bbox";
		m_eCollBox.solid = SOLID_BBOX;
		m_eCollBox.owner = this;
		setsize(m_eCollBox, -(size/2) * 0.9f, (size/2) * 0.9f);
		setorigin(m_eCollBox, WorldSpaceCenter());
	}
}

void
func_pushable::func_pushable(void)
{
}
