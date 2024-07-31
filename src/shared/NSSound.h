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

class NSSound:NSPointTrigger {
public:
	void NSSound( void );

	nonvirtual void SetSample( string );
	nonvirtual void SetVolume( float );
	nonvirtual void SetRadius( float );
	nonvirtual void SetSoundOffset( float );
	nonvirtual void MakeOmniDirectional( void );
	nonvirtual void MakeDirectional( void );
	nonvirtual void EnableReverb( void );
	nonvirtual void DisableReverb( void );
	nonvirtual virtual void Play( void );

private:
	float m_radius;
	float m_volume;
	string m_sample;
	bool m_omniDirectional;
	float m_offset;
};

void NSSound::NSSound( void ) {
	m_radius = 128.0f;
	m_volume = 0.5f;
	m_sample = "common/null.wav";
}

void NSSound::SetSample( string newSample ) {
	m_sample = newSample;
}

void NSSound::SetVolume( float newVolume ) {
	m_volume = newVolume;
}

void NSSound::SetRadius( float newRadius ) {
	m_radius = newRadius;
}

void NSSound::SetSoundOffset( float newRadius ) {
	m_offset = newRadius;
}

void NSSound::MakeOmniDirectional( void ) {
	m_omniDirectional = true;
}

void NSSound::MakeDirectional( void ) {
	m_omniDirectional = false;
}

void NSSound::EnableReverb( void ) {
	m_ignoreReverb = false;
}

void NSSound::DisableReverb( void ) {
	m_ignoreReverb = true;
}

void NSSound::Play( void ) {
	float soundFlags = 0;

	if ( m_ignoreReverb ) {
		soundFlags |= SOUNDFLAG_NOREVERB;
	}
#ifdef CLIENT
	if ( m_omniDirectional ) {
		soundFlags |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	sound( this, CHAN_AUTO, m_sample, m_volume, m_radius, m_pitch, soundFlags, m_offset );
}
