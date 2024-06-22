
class NSSound:NSPointTrigger {
	float m_radius;
	float m_volume;
	string m_sample;
	bool m_omniDirectional;
	float m_offset;

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
