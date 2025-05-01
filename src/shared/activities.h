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

There are exceptions, like in the weapon animation system - a weapon might fire successfully but an animation for said event may not exist in the thing that fired it - since it's not directly relative to the weapon (we're passing an event off to our owner) it doesn't affect weapon functionality.

This system powers NPCs, but also weapons. So some weapon functionality
is only available when certain activities exist.

# Defining Activities In Models

The primary way of assigning activities to sequences within models
is to do so when compiling it. Formats such as **Half-Life MDL**
support activities, others do not.

In a Half-Life model's **qc** file, you will find them defined like so:

```
$sequence "idle1" "idle1" fps 20 loop ACT_IDLE 15 
$sequence "idle2" "idle2" fps 20 ACT_IDLE 1 
$sequence "idle3" "idle3" fps 20 ACT_IDLE 1 
$sequence "walk" "walk" LX fps 30 loop ACT_WALK 1 
$sequence "run" "run" LX fps 30 loop ACT_RUN 1 
```

Internally, the model compiler will convert `ACT_IDLE` to the value `1`. Models don't store names for activities - only IDs. Because of this, in order to define custom activities in the Half-Life engine you would need a modified model compiler and modified game code that are aware of your new activities, whereas we [define it externally in Nuclide](@ref activities_new).

There is currently no way to assign them to a model per external means in FTE, but there are plans to do so.

There are also plans of adding extensions to VVM (as implemented by IQM-FTE) models to handle activity support.

# Defining Activities in EntityDef

In addition to defining activities within a model file, an entityDef can override activities or define new activities for an entity on a non-model basis. You might want to leverage this during development anyway so you don't rebuild your models all the time, or if your artists don't want to define them in the model.

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
