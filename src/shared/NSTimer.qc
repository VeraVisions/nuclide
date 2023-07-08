/*
 * Copyright (c) 2022 Vera Visions LLC.
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
NSTimer::NSTimer(void)
{
	m_eReceiver = __NULL__;
	_m_NSTimerFunc = __NULL__;
	m_flTime = 0.0f;
	m_bRepeats = false;
}

/* wrapper to execute our trigger */
static void
_NSTimerWrapper(entity receiver, void() func)
{
	entity oldself = self;
	self = receiver;
	func();
	self = oldself;
}

void
NSTimer::_TimerThink(void)
{
	_NSTimerWrapper(m_eReceiver, _m_NSTimerFunc);

	if (m_bRepeats == true)
		nextthink = time + m_flTime;
}

void
NSTimer::_TempTimerThink(void)
{
	_NSTimerWrapper(m_eReceiver, _m_NSTimerFunc);

	if (m_bRepeats == true)
		nextthink = time + m_flTime;
	else {
		think = Destroy;
		nextthink = time;
	}
}

NSTimer
NSTimer::ScheduleTimer(entity receiver, void() call, float interval, bool repeats)
{
	NSTimer ret;

	if (this)
		ret = this;
	else {
		ret = spawn(NSTimer);
		this = ret;
	}

	ret.m_eReceiver = receiver;
	ret.m_flTime = interval;
	ret._m_NSTimerFunc = call;
	ret.m_bRepeats = repeats;

	/* time to start running */
	ret.think = NSTimer::_TimerThink;
	ret.nextthink = time + interval;
	return ret;
}

NSTimer
NSTimer::TemporaryTimer(entity receiver, void() call, float interval, bool repeats)
{
	NSTimer ret;

	if (this)
		ret = this;
	else {
		ret = spawn(NSTimer);
		this = ret;
	}

	ret.m_eReceiver = receiver;
	ret.m_flTime = interval;
	ret._m_NSTimerFunc = call;
	ret.m_bRepeats = repeats;

	/* time to start running */
	ret.think = NSTimer::_TempTimerThink;
	ret.nextthink = time + interval;
	return ret;
}

void
NSTimer::RunTimer(void)
{
	think = NSTimer::_TimerThink;
	nextthink = time + m_flTime;
}

NSTimer
NSTimer::SetupTimer(entity receiver, void() call, float interval, bool repeats)
{
	NSTimer ret;

	if (this)
		ret = this;
	else {
		ret = spawn(NSTimer);
		this = ret;
	}

	ret.m_eReceiver = receiver;
	ret.m_flTime = interval;
	ret._m_NSTimerFunc = call;
	ret.m_bRepeats = repeats;
	return ret;
}

void
NSTimer::OnRemoveEntity(void)
{
	nextthink = 0.0f;
	think = __NULL__;
}

void
NSTimer::StopTimer(void)
{
	if (this) {
		nextthink = 0.0f;
		think = __NULL__;
	}
}

#ifdef SERVER
void
NSTimer::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_eReceiver", m_eReceiver);
	SaveString(handle, "_m_NSTimerFunc", getentityfieldstring(findentityfield("_m_NSTimerFunc"), this));
	SaveFloat(handle, "m_flTime", m_flTime);
	SaveBool(handle, "m_bRepeats", m_bRepeats);
}

void
NSTimer::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eReceiver":
		m_eReceiver = ReadEntity(strValue);
		break;
	case "_m_NSTimerFunc":
		_m_NSTimerFunc = externvalue(-1, strValue);
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