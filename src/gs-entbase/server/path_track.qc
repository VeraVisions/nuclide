/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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
	PATHTRACK_DISABLED,
	PATHTRACK_FIREONCE,
	PATHTRACK_BRANCHREVERSE,
	PATHTRACK_DISABLETRAIN
};

/*!QUAKED path_track (.5 .3 0) (-8 -8 -8) (8 8 8) DISABLED FIRE_ONCE BRANCHREVERSE DISABLETRAIN
# OVERVIEW
Node entities used for func_tracktrains.
It's like a path_corner, but for tracktrains.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "altpath" : When enabled, will point to this instead.
- "netname" : Target to trigger when the train gets stopped here.

# INPUTS
- "ToggleAlternatePath" : Toggles between `target` and `altpath`.
- "EnableAlternatePath" : Next node will be the one set in `altpath`.
- "DisableAlternatePath" : Next node will be the one set in `target`.
- "TogglePath" : Toggles the ability to use this node.
- "EnablePath" : Enables the ability to use this node.
- "DisablePath" : Disables the ability to use this node.

# SPAWNFLAGS
- DISABLED (1) : Start disabled.
- FIRE_ONCE (2) : Fire pass target once.
- BRANCHREVERSE (4) : Complicated.
- DISABLETRAIN (8) : Disables train when it passes.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/

class
path_track:path_corner
{
public:
	void path_track(void);

	nonvirtual void PathEndTrigger(entity, triggermode_t);

	/* overrides */
	virtual void DebugDraw(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	virtual string GetPathTarget(void);
	virtual string GetSelfTarget(void);
	virtual path_corner GetPathTargetEntity(void);
	virtual path_corner GetSelfTargetEntity(void);
	virtual bool DisablesTrain(void);

private:
	bool m_bTrackEnabled;
	bool m_bAltPath;
	string m_strAltPath;
	string m_strEndTrigger;
};

void
path_track::path_track(void)
{
	m_bAltPath = false;
	m_bTrackEnabled = true;
	m_strAltPath = __NULL__;
	m_strEndTrigger = __NULL__;
}

void
path_track::DebugDraw(void)
{
	vector pos = GetOrigin();
	pos[2] += 32;
	R_BeginPolygon("textures/editor/path_track", 0, 0);
	R_PolygonVertex(pos + v_right * 24 - v_up * 24, [1,1], [1,1,1], 1.0f);
	R_PolygonVertex(pos - v_right * 24 - v_up * 24, [0,1], [1,1,1], 1.0f);
	R_PolygonVertex(pos - v_right * 24 + v_up * 24, [0,0], [1,1,1], 1.0f);
	R_PolygonVertex(pos + v_right * 24 + v_up * 24, [1,0], [1,1,1], 1.0f);
	R_EndPolygon();

	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(GetOrigin(), [0,1], [1,1,1], 0.5f);
	R_PolygonVertex(pos, [1,1], [1,1,1], 0.5f);
	R_EndPolygon();
}


void
path_track::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "altpath":
		m_strAltPath = ReadString(setValue);
		break;
	case "netname":
		m_strEndTrigger = ReadString(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
path_track::Respawn(void)
{
	m_bTrackEnabled = HasSpawnFlags(PATHTRACK_DISABLED) ? false : true;
}

void
path_track::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_bAltPath", m_bAltPath);
	SaveBool(handle, "m_bTrackEnabled", m_bTrackEnabled);
	SaveString(handle, "m_strAltPath", m_strAltPath);
	SaveString(handle, "m_strEndTrigger", m_strEndTrigger);
}

void
path_track::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bAltPath":
		m_bAltPath = ReadBool(strValue);
		break;
	case "m_bTrackEnabled":
		m_bTrackEnabled = ReadBool(strValue);
		break;
	case "m_strAltPath":
		m_strAltPath = ReadString(strValue);
		break;
	case "m_strEndTrigger":
		m_strEndTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
path_track::Input(entity activatingEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "ToggleAlternatePath":
		Trigger(activatingEntity, TRIG_TOGGLE);
		break;
	case "EnableAlternatePath":
		Trigger(activatingEntity, TRIG_ON);
		break;
	case "DisableAlternatePath":
		Trigger(activatingEntity, TRIG_OFF);
		break;
	case "TogglePath":
		m_bTrackEnabled ^= true;
		break;
	case "EnablePath":
		m_bTrackEnabled = true;
		break;
	case "DisablePath":
		m_bTrackEnabled = false;
		break;
	default:
		super::Input(activatingEntity, inputName, dataField);
	}
}

void
path_track::Trigger(entity activatingEntity, triggermode_t triggerMode)
{
	/* no idea if this is accurate behaviour, but it should be compatible */
	if (m_strAltPath) {
		switch (triggerMode) {
		case TRIG_ON:
			m_bAltPath = true;
			break;
		case TRIG_OFF:
			m_bAltPath = false;
			break;
		default:
			m_bAltPath ^= true;
		}
	} else {
		switch (triggerMode) {
		case TRIG_ON:
			m_bTrackEnabled = true;
			break;
		case TRIG_OFF:
			m_bTrackEnabled = false;
			break;
		default:
			m_bTrackEnabled ^= true;
		}
	}
}

bool
path_track::DisablesTrain(void)
{
	return HasSpawnFlags(PATHTRACK_DISABLETRAIN) ? true : false;
}

string
path_track::GetPathTarget(void)
{
	string theTarget = target;

	if (m_bTrackEnabled == false){
		return targetname;
	}

	if (HasTriggerTarget() == false) {
		theTarget = targetname;
	}

	if (!m_strAltPath) {
		return theTarget;
	}

	return (m_bAltPath == false) ? theTarget : m_strAltPath;
}

string
path_track::GetSelfTarget(void)
{
	for (path_track f = __NULL__; (f = (path_track)find(f, ::classname, "path_track"));) {
		if (f.GetPathTarget() == targetname) {
			return f.targetname;
		}
	}

	return __NULL__;
}

path_corner
path_track::GetPathTargetEntity(void)
{
	string theTarget = GetPathTarget();

	for (path_track f = __NULL__; (f = (path_track)find(f, ::classname, "path_track"));) {
		if (f.targetname == theTarget && f.m_bTrackEnabled == true) {
			return f;
		}
	}

	return __NULL__;
}

path_corner
path_track::GetSelfTargetEntity(void)
{
	for (path_track f = __NULL__; (f = (path_track)find(f, ::classname, "path_track"));) {
		if (f.GetPathTarget() == targetname) {
			return f;
		}
	}

	return __NULL__;
}

void
path_track::PathEndTrigger(entity activatingEntity, triggermode_t triggerMode)
{
	if (!m_strEndTrigger)
		return;

	for (entity f = world; (f = find(f, ::targetname, m_strEndTrigger));) {
		NSTrigger trigger = (NSTrigger)f;

		EntLog("Triggering %S %S from %S", f.classname, trigger.targetname, activatingEntity.classname);

		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(activatingEntity, triggerMode);
		}
	}
}
