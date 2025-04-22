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

/** @defgroup bodyque Body Que
    @brief Dispatches copies of bodies, player corpses etc.
    @ingroup server

The body que is a minor abstraction that limits the amount of
bodies/corpses in an active game.

@{

*/

#ifdef SERVER
var bool autocvar_bodyque_forceRagdolls = false;
var int autocvar_bodyque_maxBodies = 4i;
var int autocvar_bodyque_maxRagdolls = 4i;

#define CORPSES_MAX autocvar_bodyque_maxBodies
#define RAGDOLLS_MAX autocvar_bodyque_maxRagdolls
#define FORCE_RAGDOLLS autocvar_bodyque_forceRagdolls

/** Initializes the BodyQue. Called in server's initents() */
void BodyQue_Init(void);

/** Dispatches a copy of the target actor into the BodyQue. */
ncRenderableEntity BodyQue_Spawn(ncActor pl, float anim);

/** Dispatches a copy of the target actor into the BodyQue. */
ncRagdoll BodyQue_SpawnRagdoll(ncActor pl, float anim);
#endif

/** @} */ // end of bodyque
