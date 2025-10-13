/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
ncPointTrigger::ncPointTrigger(void)
{
}

void
ncPointTrigger::Respawn(void)
{
	InitPointTrigger();
}

void
ncPointTrigger::InitPointTrigger(void)
{
	SetOrigin(GetSpawnVector("origin"));
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);

#ifdef SERVER
	RestoreAngles();
	m_triggerEnabled = (m_triggerStartsDisabled) ? false : true;
	_RelinkToSpawnParent();
#endif
}

void
ncPointTrigger::DebugDraw(void)
{
#ifdef SERVER
	super::DebugDraw();
#endif
}
