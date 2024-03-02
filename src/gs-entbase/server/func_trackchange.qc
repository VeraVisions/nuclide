/*
 * Copyright (c) 2023 Vera Visions LLC.
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
	FNCTRACKCHANGE_UNUSED1,
	FNCTRACKCHANGE_UNUSED2,
	FNCTRACKCHANGE_BOTTOM,
	FNCTRACKCHANGE_NOMOVE,
	FNCTRACKCHANGE_UNUSED3,
	FNCTRACKCHANGE_XAXIS,
	FNCTRACKCHANGE_YAXIS,
};

/*!QUAKED func_trackchange (0 .5 .8) ? x x x BOTTOM NOMOVE x X_AXIS Y_AXIS
# OVERVIEW
A rotating, moving platform that will transport func_tracktrain entities between two path_track entities.

# KEYS
- "targetname" : Name
- "height" : Travel altitude in game units.
- "rotation" : Amount of spinning rotation in degrees.
- "train" : Name of the train to be switched.
- "toptrack" : Name of the top track.
- "bottomtrack" : Name of the bottom track.
- "speed" : Movement and rotation speed in game units per second.

# SPAWNFLAGS
- BOTTOM (8) : Start at the bottom track.
- NOMOVE (16) : Only rotate, don't move.
- X_AXIS (64) : Rotate on the X-Axis.
- Y_AXIS (128) : Rotate on the Y-Axis.

# NOTES
This version of the entity is designed for interactive trains. If you want to use them
with automated (trigger controlled) func_tracktrain entities, use func_trackautochange.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
func_trackchange:func_platrot
{
public:
	void func_trackchange(void);

	/* overrides */
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void MoverFinishesMoving(void);
	virtual void MoverStartsMoving(void);

private:
	string m_strTrainName;
	string m_strTopTrack;
	string m_strBottomTrack;
};

void
func_trackchange::func_trackchange(void)
{
	m_strTrainName = __NULL__;
	m_strTopTrack = __NULL__;
	m_strBottomTrack = __NULL__;
}

void
func_trackchange::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "train":
		m_strTrainName = ReadString(setValue);
		break;
	case "toptrack":
		m_strTopTrack = ReadString(setValue);
		break;
	case "bottomtrack":
		m_strBottomTrack = ReadString(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
func_trackchange::Spawned(void)
{
	spawnflags |= 1;
	super::Spawned();
}

void
func_trackchange::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strTrainName", m_strTrainName);
	SaveString(handle, "m_strTopTrack", m_strTopTrack);
	SaveString(handle, "m_strBottomTrack", m_strBottomTrack);
}

void
func_trackchange::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_strTrainName":
		m_strTrainName = ReadString(setValue);
		break;
	case "m_strTopTrack":
		m_strTopTrack = ReadString(setValue);
		break;
	case "m_strBottomTrack":
		m_strBottomTrack = ReadString(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
func_trackchange::MoverStartsMoving(void)
{
	NSEntity ourTrain = (NSEntity)find(world, ::targetname, m_strTrainName);
	super::MoverStartsMoving();

	if (ourTrain) {
		ourTrain.target = __NULL__;
		ourTrain.SetVelocity(GetVelocity());
		ourTrain.SetAngularVelocity(GetAngularVelocity());
		ourTrain.ScheduleThink(ClearVelocity, 100.0f);
		EntLog("Changing %s to have no target.", m_strTrainName);
		EntLog("Velocity: %v; Angular Velocity: %v", GetVelocity(), GetAngularVelocity());
	} else {
		EntLog("No train to go with trackchange %S", targetname);
	}
}

void
func_trackchange::MoverFinishesMoving(void)
{
	NSEntity ourTrain = (NSEntity)find(world, ::targetname, m_strTrainName);
	super::MoverFinishesMoving();

	if (ourTrain) {
		ourTrain.ClearVelocity();

		if (GetMoverState() == MOVER_POS1) {
			EntLog("Changing %S from %S to %S", m_strTrainName, m_strBottomTrack, m_strTopTrack);
			ourTrain.target = m_strTopTrack;
		} else {
			EntLog("Changing %S from %S to %S", m_strTrainName, m_strBottomTrack, m_strBottomTrack);
			ourTrain.target = m_strBottomTrack;
		}
	} else {
		EntLog("No train to go with trackchange %S", targetname);
	}
}