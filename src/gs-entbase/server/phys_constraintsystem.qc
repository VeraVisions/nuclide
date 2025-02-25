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

var int g_phys_constraintsystems;

/*! \brief Server-Entity: Physics Constraint Grouping */
/*!QUAKED phys_constraintsystem (.5 .3 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Turns a series of constraints into a ragdoll, so it can be managed better by the physics simulator.

# KEYS
- "targetname" : Name

# NOTES

You specify the constraintsystem that the constraints belong to not in this entity, but
in the individual constraints themselves. Set the 'constraintsystem' key to an instance of this entity.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
@ingroup physics
*/
class
phys_constraintsystem:ncPhysicsConstraint
{
public:
	void phys_constraintsystem(void);

	virtual void Respawn(void);
	nonvirtual void AfterSpawn(void);
	nonvirtual float GetSystemID(void);
};

void
phys_constraintsystem::phys_constraintsystem(void)
{
	g_phys_constraintsystems += 1;
	jointgroup = (float)g_phys_constraintsystems;
}

void
phys_constraintsystem::Respawn(void)
{
	ScheduleThink(AfterSpawn, 0.0f);
}

void
phys_constraintsystem::AfterSpawn(void)
{

}

float
phys_constraintsystem::GetSystemID(void)
{
	return jointgroup;
}