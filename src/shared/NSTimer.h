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

/** This class provides a way to trigger a function in the future.
It has the ability to clean itself up afterwards, too. */
class
NSTimer:NSEntity
{
private:
	entity m_eReceiver;
	virtual void(void) m_vFunc = 0;
	float m_flTime;
	bool m_bRepeats;

	virtual void _TimerThink(void);
	virtual void _TempTimerThink(void);

public:
	void NSTimer(void);

	/** When called, creates and sets up a new timer, starts immediately. */
	static NSTimer ScheduleTimer(entity, void(), float, bool);

	/** When called, creates a self garbage collecting version of a timer. */
	static NSTimer TemporaryTimer(entity, void(), float, bool);

	/** Runs the timer that's set up. */
	virtual void RunTimer(void);

	/** When called, sets up a timer that has to be run manually later. */
	static NSTimer SetupTimer(entity, void(), float, bool);

	/** Invalidates the timer when called. */
	nonvirtual void StopTimer(void);

	virtual void OnRemoveEntity(void);
};