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

/*QUAKED func_train (0 .5 .8) ? TRAIN_WAIT x x TRAIN_NOTSOLID
"targetname"    Name
"target"        First node.
"killtarget"    Target to kill when triggered.
"dmg"           Damage to inflict upon a person blocking the way.
"snd_move"      Path to sound sample which plays when it's moving.
"snd_stop"      Path to sound sample which plays when it stops moving.

Moving platform following along path_corner entities, aka nodes.
Most of its behaviour is controlled by the path_corner entities it passes over.
See the entity definition for path_corner to find out more.

Upon level entry, the func_train will spawn right where its first path_corner
node is. This is so you can light the func_train somewhere else - like a lonely
box somewhere outside the playable area.

Marking the func_train with the flag TRAIN_NOTSOLID will make entities not
collide with the train. This is best used for things in the distance or for
when lasers are following this train as a sort of guide.
*/

enumflags
{
	TRAIN_WAIT,
	TRAIN_UNUSED1,
	TRAIN_UNUSED2,
	TRAIN_NOTSOLID
};

string g_strTrainMoveSnd[] = {
	"common/null.wav",
	"plats/bigmove1.wav",
	"plats/bigmove2.wav",
	"plats/elevmove1.wav",
	"plats/elevmove2.wav",
	"plats/elevmove3.wav",
	"plats/freightmove1.wav",
	"plats/freightmove2.wav",
	"plats/heavymove1.wav",
	"plats/rackmove1.wav",
	"plats/railmove1.wav",
	"plats/squeekmove1.wav",
	"plats/talkmove1.wav",
	"plats/talkmove2.wav"
};
string g_strTrainStopSnd[] = {
	"common/null.wav",
	"plats/bigstop1.wav",
	"plats/bigstop2.wav",
	"plats/freightstop1.wav",
	"plats/heavystop2.wav",
	"plats/rackstop1.wav",
	"plats/railstop1.wav",
	"plats/squeekstop1.wav",
	"plats/talkstop1.wav"
};

class func_train:CBaseTrigger
{
	float m_flWait;
	float m_flSpeed;
	float m_flDamage;
	string m_strMoveSnd;
	string m_strStopSnd;
	string m_strOldTarget; /* specific to trains? */

	void(void) func_train;
	virtual void(void) NextPath;
	virtual void(void) GoToTarget;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(void) Blocked;
};

void
func_train::Blocked(void)
{
	/* HACK: Make corpses gib instantly */
	if (other.solid == SOLID_CORPSE) {
		Damage_Apply(other, this, 500, 0, DMG_EXPLODE);
		return;
	}

	if (other.takedamage != DAMAGE_NO) {
		Damage_Apply(other, this, m_flDamage, 0, DMG_CRUSH);
	} else {
		remove(other);
	}
}

void
func_train::GoToTarget(void)
{
	entity eNode;
	float flTravelTime;
	vector vecVelocity;
	vector vecWorldPos;

	eNode = find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	vecWorldPos[0] = absmin[0] + (0.5 * (absmax[0] - absmin[0]));
	vecWorldPos[1] = absmin[1] + (0.5 * (absmax[1] - absmin[1]));
	vecWorldPos[2] = absmin[2] + (0.5 * (absmax[2] - absmin[2]));

	vecVelocity = (eNode.origin - vecWorldPos);
	flTravelTime = (vlen(vecVelocity) / m_flSpeed);

	if (!flTravelTime) {
		print("^1func_train::^3GoToTarget^7: Distance short, going next\n");
		think = NextPath;
		nextthink = ltime;
		return;
	}

	/* more stuff for the ears */
	if (m_strMoveSnd) {
		sound(this, CHAN_VOICE, m_strMoveSnd, 1.0, ATTN_NORM);
	}

	velocity = (vecVelocity * (1 / flTravelTime));
	think = NextPath;
	nextthink = (ltime + flTravelTime);
}

void
func_train::NextPath(void)
{
	path_corner eNode;
	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	/* fire the path_corners' target */
	if (eNode.m_strMessage) {
		eNode.Trigger(this, TRIG_TOGGLE);
	}

	/* stuff for the ears */
	if (m_strStopSnd) {
		sound(this, CHAN_BODY, m_strStopSnd, 1.0, ATTN_NORM);
	}
	/* make the loopy noise stop */
	if (m_strMoveSnd) {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}

	SetOrigin(eNode.origin - (mins + maxs) * 0.5);
	m_flSpeed = eNode.m_flSpeed;
	m_flWait = eNode.m_flWait;
	target = eNode.target;
	velocity = [0,0,0];

	/* warp next frame */
	if (eNode.spawnflags & PC_TELEPORT) {
		print(sprintf("^1func_train::^3NextPath^7: Node %s wants %s to teleport\n", eNode.targetname, targetname));
		think = NextPath;
		nextthink = ltime;
		return;
	}

	/* stop until triggered again */
	if (eNode.spawnflags & PC_WAIT || spawnflags & TRAIN_WAIT) {
		return;
	}

	if (m_flWait > 0) {
		think = GoToTarget;
		nextthink = ltime + m_flWait;
	} else {
		GoToTarget();
	}
}

/* TODO: Handle state? */
void
func_train::Trigger(entity act, int state)
{
	GoToTarget();
}

void
func_train::Respawn(void)
{
	solid = spawnflags & TRAIN_NOTSOLID ? SOLID_NOT : SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	blocked = Blocked;
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);

	/* let's wait 1/4 a second to give the path_corner entities a chance to
	 * spawn in case they're after us in the ent lump */
	target = m_strOldTarget;
	think = NextPath;
	nextthink = ltime + 0.25f;
}

void
func_train::func_train(void)
{
	int a;
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "target":
			m_strOldTarget = argv(i+1);
			break;
		case "dmg":
			m_flDamage = stof(argv(i+1));
			break;
		case "movesnd":
			a = bound(0, stof(argv(i+1)), g_strTrainMoveSnd.length);
			m_strMoveSnd = g_strTrainMoveSnd[a];
			break;
		case "stopsnd":
			a = bound(0, stof(argv(i+1)), g_strTrainStopSnd.length);
			m_strStopSnd = g_strTrainStopSnd[a];
			break;
		case "snd_move":
			m_strMoveSnd = argv(i+1);
			break;
		case "snd_stop":
			m_strStopSnd = argv(i+1);
			break;
		default:
			break;
		}
	}

	if (m_strMoveSnd) {
		precache_sound(m_strMoveSnd);
	}
	if (m_strStopSnd) {
		precache_sound(m_strStopSnd);
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	CBaseTrigger::CBaseTrigger();
}
