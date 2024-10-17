/*
 * Copyright (c) 2024 Vera Visions LLC.
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


void
NSSound::NSSound( void )
{
	m_radius = 128.0f;
	m_volume = 0.5f;
	m_sample = "common/null.wav";
	m_soundIndex = 0;
	m_offset = 0.0f;
	m_pitch = 100.0f;
	m_omniDirectional = false;
	m_ignoreReverb = false;
	m_forceLoop = true;
}

void
NSSound::Spawned( void )
{
	super::Spawned();
	m_soundIndex = getsoundindex(m_sample, false);

#ifdef SERVER
	pvsflags = PVSF_USEPHS;
#endif
}

void
NSSound::SetSample( string newSample )
{
	m_sample = newSample;
	m_soundIndex = getsoundindex(m_sample, true);
}

void
NSSound::SetVolume( float newVolume )
{
	m_volume = newVolume;
}

void
NSSound::SetPitch( float newPitch )
{
	m_pitch = newPitch;
}

void
NSSound::SetRadius( float newRadius )
{
	m_radius = newRadius;
}

void
NSSound::SetSoundOffset( float newOffset )
{
	m_offset = newOffset;
}

void
NSSound::MakeOmniDirectional( void )
{
	m_omniDirectional = true;
}

void
NSSound::MakeDirectional( void )
{
	m_omniDirectional = false;
}

void
NSSound::EnableReverb( void )
{
	m_ignoreReverb = false;
}

void
NSSound::DisableReverb( void )
{
	m_ignoreReverb = true;
}

void
NSSound::ForceLoop( bool forceLooping )
{
	m_forceLoop = forceLooping;

#ifdef SERVER
	if (m_forceLoop) {
		m_isLooping = true;
	} else {
		m_isLooping = false;
	}
	SendFlags |= SOUND_ENABLED;
#endif
}

void
NSSound::Play( void )
{
	float soundFlags = 0;

	if ( m_ignoreReverb ) {
		soundFlags |= SOUNDFLAG_NOREVERB;
	}
#ifdef CLIENT
	if ( m_omniDirectional ) {
		soundFlags |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	sound(this, CHAN_BODY, m_sample, m_volume, (cvar("s_nominaldistance") / m_radius), m_pitch, soundFlags, m_offset);
}

#ifdef SERVER
void
NSSound::Respawn(void)
{
	super::Respawn();
}

void
NSSound::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, RDENT_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, RDENT_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, RDENT_CHANGED_ORIGIN_Z)
	EVALUATE_FIELD(m_soundIndex, SOUND_SAMPLE)
	EVALUATE_FIELD(m_volume, SOUND_VOLUME)
	EVALUATE_FIELD(m_radius, SOUND_RADIUS)
	EVALUATE_FIELD(m_pitch, SOUND_PITCH)
	EVALUATE_FIELD(m_isLooping, SOUND_ENABLED)
}

float
NSSound::SendEntity(entity ePEnt, float flChanged)
{
	if (distance(ePEnt.origin, origin) >= m_radius) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_SOUND);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], SOUND_ORIGIN)
	SENDENTITY_COORD(origin[1], SOUND_ORIGIN)
	SENDENTITY_COORD(origin[2], SOUND_ORIGIN)
	SENDENTITY_FLOAT(m_soundIndex, SOUND_SAMPLE)
	SENDENTITY_FLOAT(m_volume, SOUND_VOLUME)
	SENDENTITY_FLOAT(m_radius, SOUND_RADIUS)
	SENDENTITY_FLOAT(m_pitch, SOUND_PITCH)
	SENDENTITY_BYTE(m_isLooping, SOUND_ENABLED)

	return (true);
}
#endif

#ifdef CLIENT
void
NSSound::ReceiveEntity(float isnew, float flChanged)
{
	READENTITY_COORD(origin[0], SOUND_ORIGIN)
	READENTITY_COORD(origin[1], SOUND_ORIGIN)
	READENTITY_COORD(origin[2], SOUND_ORIGIN)
	READENTITY_FLOAT(m_soundIndex, SOUND_SAMPLE)
	READENTITY_FLOAT(m_volume, SOUND_VOLUME)
	READENTITY_FLOAT(m_radius, SOUND_RADIUS)
	READENTITY_FLOAT(m_pitch, SOUND_PITCH)
	READENTITY_BYTE(m_isLooping, SOUND_ENABLED)

	if (flChanged & SOUND_ORIGIN) {
		SetSolid(SOLID_NOT);
		SetSize([0,0,0], [0,0,0]);
		Relink();
	}

	if (flChanged & SOUND_SAMPLE) {
		m_sample = soundnameforindex(m_soundIndex);
	}

	if (m_isLooping)
	SndEntLog("^2start ^7%S Volume: %d%%; Radius: %d units; Pitch: %d, Org: %v", m_sample, m_volume * 100, m_radius, m_pitch, origin);
	else
	SndEntLog("^1stop: ^7%S Volume: %d%%; Radius: %d units; Pitch: %d, Org: %v", m_sample, m_volume * 100, m_radius, m_pitch, origin);

	if (flChanged & SOUND_ENABLED)
	if (m_isLooping == true) {
		soundupdate(this, CHAN_BODY, m_sample, m_volume, (cvar("s_nominaldistance") / m_radius), m_pitch, SOUNDFLAG_FORCELOOP, 0);
	} else {
		OnRemoveEntity();
	}
}
#endif

void
NSSound::OnRemoveEntity(void)
{
	SndEntLog("stopping\n");
	StopSound(CHAN_BODY, true);
}
