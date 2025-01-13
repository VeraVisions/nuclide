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

enumflags
{
	SOUND_SAMPLE,
	SOUND_VOLUME,
	SOUND_RADIUS,
	SOUND_PITCH,
	SOUND_ORIGIN,
	SOUND_ENABLED
};

class
ncSound:ncPointTrigger
{
public:
	void ncSound( void );

	nonvirtual void SetSample( string );
	nonvirtual void SetVolume( float );
	nonvirtual void SetRadius( float );
	nonvirtual void SetPitch( float );
	nonvirtual void SetSoundOffset( float );
	nonvirtual void MakeOmniDirectional( void );
	nonvirtual void MakeDirectional( void );
	nonvirtual void EnableReverb( void );
	nonvirtual void DisableReverb( void );
	nonvirtual void ForceLoop( bool );
	nonvirtual void Play( void );

	virtual void Spawned(void);
	virtual void OnRemoveEntity(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
#endif

private:
	NETWORKED_FLOAT(m_radius)
	NETWORKED_FLOAT(m_volume)
	NETWORKED_FLOAT(m_soundIndex)
	NETWORKED_FLOAT(m_pitch)
	NETWORKED_BOOL(m_isLooping)
	string m_sample;
	bool m_omniDirectional;
	float m_offset;
	bool m_ignoreReverb;
	bool m_forceLoop;
};
