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

#ifdef SERVER
.ncSchedule m_activeSchedule;
#endif

void
ncSchedule::ncSchedule(void)
{
	m_onTask = 0i;
	m_taskCount = 0i;
	m_controllingActor = __NULL__;
	m_scheduleDecl = __NULL__;
}

void
ncSchedule::AdvanceLater(float timeDelta)
{
	EntLog("Advancing schedule in %f seconds.", timeDelta);
	ncTimer newTimer = __NULL__;
	newTimer = newTimer.TemporaryTimer(this, Advance, timeDelta, false);
}


void
ncSchedule::Advance(void)
{
	string taskInput;
	string taskParms;

	m_onTask++;

	if (m_onTask > m_taskCount) {
		Cancel();
		return;
	}

	string taskString = m_scheduleDecl.GetString(sprintf("task_%i", m_onTask));
	tokenize_console(taskString);
	taskInput = argv(0);
	taskParms = argv(1);

	EntLog("Advancing schedule to Task %i of %i.", m_onTask, m_taskCount);
	EntLog("Instructing %S to perform %S with parms %S", m_controllingActor.classname, taskInput, taskParms);
	m_controllingActor.Input(this, taskInput, taskParms);
}

void
ncSchedule::Cancel(void)
{
	EntLog("Schedule for %S (%d) terminated.", m_controllingActor.classname, num_for_edict(m_controllingActor));

	/* TODO: Let NPC know that it's done? */
	m_controllingActor.m_activeSchedule = __NULL__;
	m_controllingActor = __NULL__;
	Destroy();
}

void
ncSchedule::Think(void)
{
	/* Our actor is dead. Invalidate right away. */
	if (m_controllingActor.IsAlive() == false) {
		ReleaseThink();
		Cancel();
		return;
	}

	/* continue next tic */
	ScheduleThink(Think, 0.0f);
}

bool
ncSchedule::AssignActor(ncActor targetActor)
{
	m_controllingActor = targetActor;
	m_controllingActor.m_activeSchedule = this;

	if (m_controllingActor.IsAlive() == false) {
		return (false);
	}

	EntLog("Schedule %d created and active.", num_for_edict(this));
	EntLog("Controlling %S (%d)", m_controllingActor.classname, num_for_edict(m_controllingActor));
	EntLog("Total tasks: %i", m_taskCount);

	Advance();

	/* start thinking next tic */
	ScheduleThink(Think, 0.0f);

	return (true);
}

void
ncSchedule::SetTarget(ncEntity target)
{
	m_eTarget = target;
}

ncEntity
ncSchedule::GetTarget(void)
{
	return (m_eTarget);
}

ncSchedule
ncSchedule::CreateSchedule(ncActor targetActor, string scheduleDecl)
{
	ncSchedule newSchedule = spawn(ncSchedule);

	newSchedule.m_scheduleDecl = ncDict::LoadDeclFromFile(scheduleDecl, sprintf("schedules/%s.decl", scheduleDecl));

	if ((newSchedule.m_scheduleDecl.TokenCount() % 2) != 0) {
		newSchedule.Destroy();
		NSError("Schedule %S has keys set with no specified value!", scheduleDecl);
		return (__NULL__);
	}

	newSchedule.m_taskCount = (newSchedule.m_scheduleDecl.TokenCount() / 2);

	if (newSchedule.AssignActor(targetActor) == false) {
		newSchedule.Destroy();
		return (__NULL__);
	} else {
		return (newSchedule);
	}
}
