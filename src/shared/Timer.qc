/*
 * Copyright (c) 2022-2024 Vera Visions LLC.
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
ncTimer::ncTimer(void)
{
	m_eReceiver = __NULL__;
	_m_ncTimerFunc = __NULL__;
	m_flTime = 0.0f;
	m_bRepeats = false;
}

/* wrapper to execute our trigger */
static void
_ncTimerWrapper(entity receiver, void() func)
{
	entity oldself = self;
	self = receiver;
	func();
	self = oldself;
}

void
ncTimer::_TimerThink(void)
{
	if (!m_eReceiver) {
		Destroy();
		return;
	}

	_ncTimerWrapper(m_eReceiver, _m_ncTimerFunc);

	if (m_bRepeats == true)
		nextthink = time + m_flTime;
}

void
ncTimer::_TempTimerThink(void)
{
	_ncTimerWrapper(m_eReceiver, _m_ncTimerFunc);

	if (m_bRepeats == true)
		nextthink = time + m_flTime;
	else {
		think = Destroy;
		nextthink = time;
	}
}

ncTimer
ncTimer::ScheduleTimer(entity receiver, void() call, float interval, bool repeats)
{
	ncTimer ret;

	if (this)
		ret = this;
	else {
		ret = spawn(ncTimer);
		this = ret;
	}

	ret.m_eReceiver = receiver;
	ret.m_flTime = interval;
	ret._m_ncTimerFunc = call;
	ret.m_bRepeats = repeats;

	/* time to start running */
	ret.think = ncTimer::_TimerThink;
	ret.nextthink = time + interval;
	return ret;
}

ncTimer
ncTimer::TemporaryTimer(entity receiver, void() call, float interval, bool repeats)
{
	ncTimer ret;

	if (this)
		ret = this;
	else {
		ret = spawn(ncTimer);
		this = ret;
	}

	ret.m_eReceiver = receiver;
	ret.m_flTime = interval;
	ret._m_ncTimerFunc = call;
	ret.m_bRepeats = repeats;

	/* time to start running */
	ret.think = ncTimer::_TempTimerThink;
	ret.nextthink = time + interval;
	return ret;
}

void
ncTimer::RunTimer(void)
{
	think = ncTimer::_TimerThink;
	nextthink = time + m_flTime;
}

ncTimer
ncTimer::SetupTimer(entity receiver, void() call, float interval, bool repeats)
{
	ncTimer ret;

	if (this)
		ret = this;
	else {
		ret = spawn(ncTimer);
		this = ret;
	}

	ret.m_eReceiver = receiver;
	ret.m_flTime = interval;
	ret._m_ncTimerFunc = call;
	ret.m_bRepeats = repeats;
	return ret;
}

void
ncTimer::OnRemoveEntity(void)
{
	nextthink = 0.0f;
	think = __NULL__;
}

void
ncTimer::StopTimer(void)
{
	if (this) {
		nextthink = 0.0f;
		think = __NULL__;
	}
}

#ifdef SERVER
void
ncTimer::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_eReceiver", m_eReceiver);
	SaveString(handle, "_m_ncTimerFunc", getentityfieldstring(findentityfield("_m_ncTimerFunc"), this));
	SaveFloat(handle, "m_flTime", m_flTime);
	SaveBool(handle, "m_bRepeats", m_bRepeats);
}

void
ncTimer::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eReceiver":
		m_eReceiver = ReadEntity(strValue);
		break;
	case "_m_ncTimerFunc":
		_m_ncTimerFunc = externvalue(-1, strValue);
		break;
	case "m_flTime":
		m_flTime = ReadFloat(strValue);
		break;
	case "m_bRepeats":
		m_bRepeats = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}
#endif
