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
	m_failSchedule = __NULL__;
}

void
ncSchedule::AdvanceLater(float timeDelta)
{
	m_inProgress = true;
	EntLog("Advancing %S in %f seconds.", m_name, timeDelta);
	ncTimer newTimer = __NULL__;
	newTimer = newTimer.TemporaryTimer(this, Advance, timeDelta, false);
}

bool
ncSchedule::InProgress(void)
{
	return (m_inProgress);
}

void
ncSchedule::Advance(void)
{
	string taskInput;
	string taskParms;
	bool shouldCancel = false;

	if (wasfreed(this)) {
		return;
	}

	/* Our actor is dead. Invalidate right away. */
	if (!m_controllingActor) {
		shouldCancel = true;
	} else {
		if (m_controllingActor.IsAlive() == false) {
			shouldCancel = true;
		}

		if (m_controllingActor.m_activeSchedule != this) {
			shouldCancel = true;
		}
	}

	if (shouldCancel == true) {
		ReleaseThink();
		Cancel();
		return;
	}

	m_onTask++;

	if (m_onTask > m_taskCount) {
		ReleaseThink();
		Cancel();
		return;
	}

	string taskString = m_scheduleDecl.GetString(sprintf("task_%i", m_onTask));

	if (STRING_SET(taskString)) {
		tokenize_console(taskString);
		taskInput = argv(0);
		taskParms = argv(1);
	} else {
		EntError("Task %i not defined! Cancelling schedule.", m_onTask);
		m_onTask = m_taskCount + 1i;
		ReleaseThink();
		Cancel();
		return;
	}

	m_inProgress = false;

	EntLog("Advancing %S to Task %i of %i.", m_name, m_onTask, m_taskCount);
	EntLog("Instructing %S to perform %S with parms %S", m_controllingActor.classname, taskInput, taskParms);
	m_controllingActor.Input(this, taskInput, substring(taskString, strlen(taskInput) + 1, -1));

	/* did we get scheduled for later? no? advance us ourselves */
	if (m_inProgress == false && m_bProgressOnMovement == false) {
		AdvanceLater(0.1);
	}
}

void
ncSchedule::Cancel(void)
{
	if (wasfreed(this)) {
		return;
	}

	EntLog("Schedule for %S (%d) terminated.", m_controllingActor.classname, num_for_edict(m_controllingActor));

	/* TODO: Let NPC know that it's done? */
	if (m_controllingActor) {
		if (m_controllingActor.m_activeSchedule == this) {
			m_controllingActor.m_activeSchedule = __NULL__;

			if ((m_onTask <= m_taskCount) && STRING_SET(m_failSchedule)) {
				m_controllingActor.Input(this, "PerformSchedule", m_failSchedule);
			}

			m_controllingActor = __NULL__;
		}
	}

	Destroy();
}

bool
ncSchedule::ProgressOnMovement(void)
{
	return (m_bProgressOnMovement);
}

void
ncSchedule::Think(void)
{
	bool shouldCancel = false;

	/* Our actor is dead. Invalidate right away. */
	if (!m_controllingActor) {
		shouldCancel = true;
	} else {
		if (m_controllingActor.IsAlive() == false) {
			shouldCancel = true;
		}

		if (m_controllingActor.m_activeSchedule != this) {
			shouldCancel = true;
		}
	}

	if (shouldCancel == true) {
		ReleaseThink();
		Cancel();
		return;
	}

	/* continue next tic */
	ScheduleThink(Think, 0.0f);
}

void
ncSchedule::Message(string messageString)
{
	bool lookUpValue = m_scheduleDecl.GetBool(sprintf("fail_on%s", messageString));
	string lookUpString = m_scheduleDecl.GetString(messageString);
	EntLog("^2%S received %S", m_name, messageString);

	if (STRING_SET(lookUpString)) {
		string taskInput;
		string taskParameter;
		tokenize_console(lookUpString);
		taskInput = argv(0);
		taskParameter =  substring(lookUpString, strlen(taskInput) + 1, -1);
		EntLog("^3triggering Input %S with parameter %S", taskInput, taskParameter);
		m_controllingActor.Input(this, taskInput, taskParameter);
	}

	if (lookUpValue) {
		EntLog("^1schedule killed by message.", taskInput, taskParameter);
		ReleaseThink();
		Cancel();
	}
}

void
ncSchedule::SetFailSchedule(string failSchedule)
{
	m_failSchedule = failSchedule;
}

bool
ncSchedule::AssignActor(ncActor targetActor)
{
	m_controllingActor = targetActor;
	m_controllingActor.m_activeSchedule = this;

	if (m_controllingActor.IsAlive() == false) {
		return (false);
	}

	EntLog("Schedule %S (%d) created and active.\n\t\tControlling %S (%d)\n\t\tTotal tasks: %i", m_name, num_for_edict(this), m_controllingActor.classname, num_for_edict(m_controllingActor), m_taskCount);

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

	newSchedule.m_name = scheduleDecl;
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
