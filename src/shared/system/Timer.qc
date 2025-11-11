/*
 * Copyright (c) 2022-2025 Vera Visions LLC.
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
	if (!owner) {
		Destroy();
		return;
	}

	_ncTimerWrapper(owner, _m_ncTimerFunc);

	if (m_bRepeats == true) {
		think = ncTimer::_TempTimerThink;
		nextthink = time + m_flTime;
	}
}

void
ncTimer::_TempTimerThink(void)
{
	_ncTimerWrapper(owner, _m_ncTimerFunc);

	if (m_bRepeats == true) {
		think = ncTimer::_TempTimerThink;
		nextthink = time + m_flTime;
	} else {
		Destroy();
	}
}

ncTimer
ncTimer::ScheduleTimer(entity receiver, void() call, float interval, bool repeats)
{
	ncTimer ret = spawn(ncTimer);

	ret.owner = receiver;
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
	ncTimer ret = spawn(ncTimer);
	ret.owner = receiver;
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
	if (!m_bRepeats) {
		think = ncTimer::_TimerThink;
		nextthink = time + m_flTime;
	} else {
	
	}
}

ncTimer
ncTimer::SetupTimer(entity receiver, void() call, float interval, bool repeats)
{
	ncTimer ret = spawn(ncTimer);
	ret.owner = receiver;
	ret.m_flTime = interval;
	ret._m_ncTimerFunc = call;
	ret.m_bRepeats = repeats;
	return ret;
}

void
ncTimer::OnRemoveEntity(void)
{
	super::OnRemoveEntity();

	nextthink = 0.0f;
	think = __NULL__;
	owner = __NULL__;
	_m_ncTimerFunc = __NULL__;
	m_flTime = 0.0f;
	m_bRepeats = false;
}

void
ncTimer::StopTimer(void)
{
	if (this) {
		nextthink = 0.0f;
		think = __NULL__;
	}
}

void
ncTimer::WipeEntityTimers(entity targetEntity)
{
	for (entity scheduleTimers = world; (scheduleTimers = find(scheduleTimers, ::classname, "ncTimer"));) {
		ncTimer ourTimer = (ncTimer)scheduleTimers;

		if (ourTimer.owner == targetEntity || !ourTimer.owner) {
			ourTimer.Destroy();
		}
	}
}

#ifdef SERVER
void
ncTimer::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "ncTimerFunc", getentityfieldstring(findentityfield("_m_ncTimerFunc"), this));
	SaveFloat(handle, "flTime", m_flTime);
	SaveBool(handle, "bRepeats", m_bRepeats);
}

void
ncTimer::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "ncTimerFunc":
		_m_ncTimerFunc = externvalue(-1, setValue);
		break;
	case "flTime":
		m_flTime = ReadFloat(setValue);
		break;
	case "bRepeats":
		m_bRepeats = ReadBool(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
		break;
	}
}
#endif
