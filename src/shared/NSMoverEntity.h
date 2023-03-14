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

/** The state the NSMoverEntity is in. */
typedef enum
{
	MOVER_POS1, /**< At the initial starting position. */
	MOVER_POS2, /**< At the final destination. */
	MOVER_1TO2, /**< On its way to the final destination. */
	MOVER_2TO1 /**< on its way back to the starting position. */
} moverState_t;

/** The movement type of the NSMoverEntity. */
typedef enum
{
	MOVERTYPE_LINEAR, /**< Moves in a linear fashion. */
	MOVERTYPE_ACCELERATED, /**< Moved in an accelerated fashion. */
} moverType_t;


#define AREAPORTAL_CLOSED 0
#define AREAPORTAL_OPEN 1

/** NSMoverEntity is responsible for handling movement functions of
mainly brush-based entities that move and push other entities around
the game world. Your sub-class will define the type of movement and
the two positions within the entity will traverse - and then do so
at your request. */
class
NSMoverEntity:NSSurfacePropEntity
{
public:
	void NSMoverEntity(void);

	/** Returns a directional position from the current one. */
	nonvirtual vector GetDirectionalPosition(vector, float);
	/** Returns a directional angle from the current one. */
	nonvirtual vector GetDirectionalRotation(vector, float);

	/** Set the movement state. */
	nonvirtual void SetMoverState(moverState_t);
	/** Returns the movement state. */
	nonvirtual moverState_t GetMoverState(void);

	/** Set the movement type. */
	nonvirtual void SetMoverType(moverType_t);
	/** Returns the movement type. */
	nonvirtual moverType_t GetMoverType(void);

	/** Sets the initial starting position. */
	nonvirtual void SetMoverPosition1(vector);
	/** Returns the starting position. */
	nonvirtual vector GetMoverPosition1(void);

	/** Sets the final destination. */
	nonvirtual void SetMoverPosition2(vector);
	/** Returns the final destination. */
	nonvirtual vector GetMoverPosition2(void);

	/** Sets the initial starting angle. */
	nonvirtual void SetMoverRotation1(vector);
	/** Returns the starting angle. */
	nonvirtual vector GetMoverRotation1(void);

	/** Sets the final destination angle. */
	nonvirtual void SetMoverRotation2(vector);
	/** Returns the final destination angle. */
	nonvirtual vector GetMoverRotation2(void);

	/** Moves this entity to the specified position. */
	nonvirtual void MoveToPosition(vector, float);
	/** Rotates this entity to the desired angle. */
	nonvirtual void RotateToPosition(vector, float);
	/** Moves and rotates this entity to a desired location. */
	nonvirtual void MoveAndRotateToPosition(vector, vector, float);

	/** Moves to the reverse state. If a mover is at pos1, it'll go to pos2, etc. */
	nonvirtual void MoveToReverse(float);
	/** Rotates to the reversed state. */
	nonvirtual void RotateToReverse(float);
	/** Returns if the NSMoverEntity is currently moving. */
	nonvirtual bool IsMoving(void);

	/** Overridable: Called when the mover starts moving from its position to another. */
	virtual void MoverStartsMoving(void);
	/** Overridable: Called when the mover completes its movement to a destination. */
	virtual void MoverFinishesMoving(void);

	/* overrides */
#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string, string);
#endif

private:
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecPos3;
	vector m_vecPos4;
	moverState_t m_moverState;
	moverType_t m_moverType;
	int m_iPortalState;

	nonvirtual void _PortalOpen(void);
	nonvirtual void _PortalClose(void);
	nonvirtual void _ArrivedAtRotPosition1(void);
	nonvirtual void _ArrivedAtRotPosition2(void);
	nonvirtual void _BeginMoving(void);
};