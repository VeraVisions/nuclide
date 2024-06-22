/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/*! \brief Server-Entity: Fixed Physics Constraint */
/*!QUAKED phys_constraint (.5 .3 0) (-8 -8 -8) (8 8 8) BREAKCOLL x INACTIVE MASS NOCONNECT
# OVERVIEW
Creates a fixed connection between two entities.

# KEYS
- "targetname" : Name
- "attach1" : Entity 1
- "attach2" : Entity 2

# INPUTS
- "Break" : Forcefully break the constraint.
- "TurnOn" : Turn 
- "TurnOff" : Disables the constraint

# SPAWNFLAGS
- BREAKCOLL (1) : No collision until the connection breaks.
- INACTIVE (4) : Starts inactive.
- MASS (8) : Mass Hack.
- NOCONNECT (16) : Will not connect entities until turned on via Inputs.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup server
@ingroup pointentity
*/
class
phys_constraint:NSPhysicsConstraint
{
public:
	void phys_constraint(void);

	virtual void Respawn(void);
	nonvirtual void AfterSpawn(void);
};

void
phys_constraint::phys_constraint(void)
{

}

void
phys_constraint::Respawn(void)
{
	ScheduleThink(AfterSpawn, 0.0f);
}

void
phys_constraint::AfterSpawn(void)
{
	SetConstraintType(CONSTRAINT_FIXED);
	SetOrigin(GetSpawnVector("origin"));

	SetEntity1(find(world, ::targetname, m_strEnt1));

	if (m_strEnt2)
		SetEntity2(find(world, ::targetname, m_strEnt2));
	else
		SetEntity2(this);
}