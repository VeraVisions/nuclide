/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/** @defgroup activities Activities
    @brief Universal look-up system for named animation sequences
    @ingroup shared

    Instead of hard-coding framegroups/sequences in the code or
in the decl we have access to a universal look-up system for named
sequences. The system is fully extendable through external means.

# Defining New Activities {#activities_new}

Global activities can be defined within `decls/typeinfo/activities.decl`
which will look a lot like the following:

```
typeInfo activities {
	"act_reset" "0"
	"act_idle" "1"
	"act_walk" "2"
	"act_run" "3"
}
```

# Behaviour

For example, when entities try to look up `GetAct("walk")`, it
will figure out if an activity with the ID of `2` exists inside for the entity.
If not, it will return `ACTIVITY_NOTFOUND` and the code
will skip performing an action altogether.

Generally, if an activity does not exist for an entity/model,
said activity never takes place. Neither visually nor functionally.

This system powers NPCs, but also weapons. So some weapon functionality
is only available when certain activities exist.

# Defining Activities In Models

The primary way of assigning activities to sequences within models
is to do so when compiling it. Formats such as **Half-Life MDL**
support activities, others do not.

There is currently no way to assign them to a model per external means.

# Defining Activities in EntityDef

An entityDef can override activities or define new activities for an
entity on a non-model basis.

For this, you will simply define activities in your entityDef decl
as you would in @ref activities_new, but instead of the **value**
being the supposed internal act ID it will have to match the
numeric value of the animation sequence in the model that is
defined within the decl.

Simply put, if you want the very first animation in the model
to be an idle animation, add this line to your entityDef:

```
"act_idle"	"0"
```

@{

*/

/** Initializes the sub-system for Activities. */
void Activities_Init(void);

/** Shuts the Activities system down. Every query will return `ACTIVITY_NOTFOUND`. */
void Activities_Shutdown(void);

/** Looks up the animation sequence for an entity by name of activity.

@param targetEntity the entity to query.
@param actNameCheck the name of activity to look up for this entity
@return The id of this entity's animation sequence that matches said activity. Returns `ACTIVITY_NOTFOUND` when not valid. */
float Activities_GetSequenceForEntity(ncEntity targetEntity, string actNameCheck);


/** Looks up the animation sequence by name of activity in another entityDef (or fireInfo), before looking it up in an entity.

@param targetEntity the entity to query.
@param actNameCheck the name of activity to look up for this entity
@param subDef the name of entityDef in which we'll look it up first
@return The id of this entity's animation sequence that matches said activity. Returns `ACTIVITY_NOTFOUND` when not valid. */
float Activities_GetSequenceForEntityDef(ncEntity targetEntity, string actNameCheck, string subDef);

#define ACTIVITY_NOTFOUND -1 /**< Activity does not exist. */

/** @} */ // end of activities
