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

/** @defgroup npc_schedules NPC: Schedules & Tasks
    @brief Scheduled tasks for computer controlled characters
    @ingroup npc
	@ingroup server

    # Schedules

	Computer controlled NPC actors execute [tasks](@ref npc_tasks)
within the game-world as part of a **Schedule**.

## Using Schedules

Schedules are defined within decl exclusively.

A schedule decl looks something like this:

```
scheduleDef dodgeEnemyFire
{
	"task_1"           "FindDodgeDirection 3"
	"task_2"           "Jump"

	"OnLightDamage"    "EndTask"
}
```

You will pass the name `dodgeEnemyFire` to ncSchedule::CreateSchedule() to
assign the the above decl, if defined, to the targetted actor.

The actor will then iterate over each of the `task_` keys, until it finishes
every task in the named schedule.

You can also define when a schedule should end, besides when it's running
out of tasks.
Specifying a named output of an actor (such as `OnLightDamage`) will,
if activated, trigger this schedule's' `EndTask` input.

# Tasks {#npc_tasks}

A task is a single action that an [NPC](@ref npc) can perform.
They are routinely part of a [Schedule](@ref npc_schedules).

A task is merely a predefined [Input](@ref inputoutput).
So anything an Input can provide, can be utilized in a task.

## Automatic Functionality

NPC classes call ncActor::SelectNewSchedule() routinely to
find a new purpose within the game world.

The function will then return the handle of a new ncSchedule, or __NULL__
if it's unable to do anything at all.

The NPC will then automatically perform the named schedule,
if it is valid of course.

## Testing Schedules

When [debugging](@ref debugging) schedules, it is most convenient to use the following **Input**
for this task:

```
input 125 PerformSchedule foobar
```

Will tell an actor with the entity id **125** to
perform the named schedule `foobar`.

@{

*/

class
ncSchedule:ncIO
{
public:
	void ncSchedule(void);

	/** Creates a schedule for an NPC and returns it. */
	nonvirtual ncSchedule CreateSchedule(ncActor targetActor, string scheduleDecl);
	nonvirtual void SetTarget(ncEntity target);
	nonvirtual ncEntity GetTarget(void);
	nonvirtual void Think(void);
	nonvirtual bool ProgressOnMovement(void);
	nonvirtual void SetFailSchedule(string);

private:
	string m_name;
	int m_taskCount;
	int m_onTask;
	ncActor m_controllingActor;
	ncDict m_scheduleDecl;
	ncEntity m_eTarget;
	bool m_inProgress;
	bool m_bProgressOnMovement;
	string m_failSchedule;

	nonvirtual bool AssignActor(ncActor targetActor);
	nonvirtual void Advance(void);
	nonvirtual void AdvanceLater(float timeDelta);
	nonvirtual void Cancel(void);
	nonvirtual void Message(string);
	nonvirtual bool InProgress(void);
};

/** @} */ // end of npc_schedules

