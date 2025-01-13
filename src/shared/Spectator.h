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

typedef enumflags
{
	SPECFL_ORIGIN,
	SPECFL_VELOCITY,
	SPECFL_TARGET,
	SPECFL_MODE,
	SPECFL_FLAGS,
	SPECFL_TYPE,
} ncSpectatorFlags_t;

typedef enum
{
	SPECMODE_DEATHCAM,
	SPECMODE_LOCKEDCHASE,
	SPECMODE_THIRDPERSON,
	SPECMODE_FREE,
	SPECMODE_FIRSTPERSON,
	SPECMODE_FREEOVERVIEW,
	SPECMODE_CHASEOVERVIEW
} ncSpectatorMode_t;

#ifdef CLIENT
string g_specmodes[] = {
	"Death Cam",
	"Locked Chase Cam",
	"Free Chase Cam",
	"Free Look",
	"First Person",
	"Free Overview",
	"Chase Overview"
};
#endif

enumflags
{
	SPECFLAG_BUTTON_RELEASED,
};

/** This entity class represents every spectator client.

These types of clients are not meant to interfere with the gameplay,
they are merely observers.

ncPlayer is a sub-class which has the ability to interact with games.

When clients connect via the `spectate` command, they will findthemselves
of type ncSpectator.

@ingroup baseclass
*/
class
ncSpectator:ncClient
{
public:
	void ncSpectator(void);

	/* overrides */
	virtual void ProcessInput(void);
	virtual void PreFrame(void);
	virtual void PostFrame(void);
	virtual bool IsFakeSpectator(void);
	virtual bool IsRealSpectator(void);
	virtual bool IsDead(void);
	virtual bool IsPlayer(void);
	virtual void SharedInputFrame(void);

	/** Call to spectate the next spectating target. */
	virtual void InputNext(void);
	/** Call to spectate the previous player target. */
	virtual void InputPrevious(void);
	/** Call to change the spectating mode. */
	virtual void InputMode(void);

	/** Re-teleport to the target we're spectating. 
	Called once by InputNext/Previous. */
	virtual void WarpToTarget(void);

	/** Called every frame to track with our target player. */
	virtual void SpectatorTrackPlayer(void);

#ifdef CLIENT
	virtual void ClientInputFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
#endif
	
#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void ServerInputFrame(void);

	nonvirtual void SpectatorDeathcam(ncRenderableEntity, ncEntity, float);
#endif

private:
	PREDICTED_FLOAT(spec_ent)
	PREDICTED_FLOAT(spec_flags)
	ncSpectatorMode_t spec_mode; ncSpectatorMode_t spec_mode_net;
	float m_flDeathCam;
	float m_flLastSpecTargetChange;
	vector spec_org;
	int sequence;
};

#ifdef CLIENT
void Spectator_ReadEntity(float new);
#endif
