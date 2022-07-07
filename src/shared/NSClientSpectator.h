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
	SPECFL_FLAGS
} NSClientSpectatorFlags_t;

typedef enum
{
	SPECMODE_FREE,
	SPECMODE_THIRDPERSON,
	SPECMODE_FIRSTPERSON,
	SPECMODE_OVERVIEW
} NSClientSpectatorMode_t;

typedef enumflags
{
	SPECFLAG_BUTTON_RELEASED,
};

class NSClientSpectator:NSClient
{
	PREDICTED_FLOAT(spec_ent);
	PREDICTED_FLOAT(spec_flags);
	NSClientSpectatorMode_t spec_mode; NSClientSpectatorMode_t spec_mode_net;

	vector spec_org;

	int sequence;

	void(void) NSClientSpectator;

	virtual void(void) ClientInput;

	virtual void(void) InputNext;
	virtual void(void) InputPrevious;
	virtual void(void) InputMode;

	virtual void(void) WarpToTarget;

	virtual void(void) PreFrame;
	virtual void(void) PostFrame;
	virtual void(void) SpectatorTrackPlayer;

	virtual bool(void) IsFakeSpectator;
	virtual bool(void) IsRealSpectator;
	virtual bool(void) IsDead;
	virtual bool(void) IsPlayer;

#ifdef SERVER
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual void(void) RunClientCommand;
#else
	virtual void(void) ClientInputFrame;
	virtual void(float,float) ReceiveEntity;
	virtual float(void) predraw;
#endif
};

#ifdef CLIENT
void Spectator_ReadEntity(float new);
#endif
