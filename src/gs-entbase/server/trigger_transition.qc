/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

/*!QUAKED trigger_transition (.5 .5 .5) ?
# OVERVIEW
Defines level transition regions.
All entities touching this volume will carry across to the next level.

# KEYS
- "targetname" : Name

# NOTES
In order for this entity to work, one has to assign a working info_landmark entity to a trigger_changelevel, and give this entity the same targetname as said landmark.

In GoldSrc games, it appears that every point-entity that's part of the current PVS (mostly the 'room' and attached path-ways you're currently in) carries over to the next level - if a trigger_transition is not defined.
This is probably not what you want to ever do, especially in large outdoor maps where the 'room' is the entire map.

You can also have more than one trigger_transition with the same name, so if any entity is in any of them they will move with the player across the desired level.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
trigger_transition:NSBrushTrigger
{
public:
	void trigger_transition(void);

	/* overrides */
	virtual void Respawn(void);

	nonvirtual void SaveTransition(entity, bool);
	nonvirtual NSEntity FindCarrierEntity(string);
	nonvirtual void LoadTransition(void);
};

void
trigger_transition::trigger_transition(void)
{
}

void
trigger_transition::Respawn(void)
{
	InitBrushTrigger();
	SetSolid(SOLID_NOT);
}

void
trigger_transition::SaveTransition(entity pvsTest, bool usePVS)
{
	int i = 0i;
	filestream transFile = fopen("trans.dat", FILE_WRITE);

	if (transFile < 0) {
		error("Unable to write trans.dat for transitioning.");
	}

	/* loop through all entities */
	for (NSEntity a = __NULL__; (a = (NSEntity)findfloat(a, ::identity, 1));) {
		bool replicateEntity = false;
		//print(sprintf("TRANSITION: %i %S %S\n", i, a.classname, a.m_strGlobalName));

		/* if we're using the PVS, don't use the transition trigger as reference */
		if (usePVS == true && !a.m_strGlobalName) {
			if (checkpvs(a.origin, pvsTest) == true) {
				replicateEntity = true;

				/* these checks are somewhat safe assumptions. */
				if (a.classname == "player") {
					replicateEntity = false;
				}
				if (a.classname == "info_landmark") {
					replicateEntity = false;
				}

				/* to get rid of the 'out of model slots' error */
				if (a.model == "" && solid != SOLID_NOT) {
					replicateEntity = false;
				}

				/* one thing is verified in GoldSrc: no brushes carry over. */
				if (a.m_bIsBrush == true) {
					continue;
				}
			}
		} else if (WithinBounds(a) == true) {
			replicateEntity = true;
		}

		if (replicateEntity == true) {
			fputs(transFile, sprintf("ENTITY \"%i\" %S\n", i, a.classname));
			fputs(transFile, "{\n");
			a.Save(transFile);
			fputs(transFile, "}\n");
		} else if (a.m_strGlobalName) {
			fputs(transFile, sprintf("CONTINUE \"%i\" %S\n", i, a.m_strGlobalName));
			fputs(transFile, "{\n");
			a.Save(transFile);
			fputs(transFile, "}\n");
		} else {
			continue;
		}

		i++;
	}

	fclose(transFile);
}

NSEntity
trigger_transition::FindCarrierEntity(string globalName)
{
	for (NSEntity a = __NULL__; (a = (NSEntity)findfloat(a, ::identity, 1));) {
		if (a.m_strGlobalName == globalName) {
			return a;
		}
	}
	return __NULL__;
}

vector Landmark_GetPosition(void);

void
trigger_transition::LoadTransition(void)
{
	string lineFeed;
	bool isNew = false;
	NSEntity carrierEntity = __NULL__;

	filestream transFile = fopen("trans.dat", FILE_READ);

	if (transFile < 0) {
		error("this should never happen.");
	}

	print(sprintf("Found transition file. Will transition over entities.\n"));

	while ((lineFeed = fgets(transFile))) {
		int c = tokenize(lineFeed);

		/* start of an entity */
		if (argv(0) == "{") {
			continue;
		} else if (argv(0) == "}") {
			carrierEntity.TransitionComplete();
			carrierEntity = __NULL__;
			continue;
		}

		if (c == 3) {
			if (argv(0) == "CONTINUE") {
				carrierEntity = FindCarrierEntity(argv(2));
				isNew = false;
			} else if (argv(0) == "ENTITY") {
				carrierEntity = EntityDef_CreateClassname(argv(2));
				isNew = true;
			}
		} else if (c == 2) { /* key value pairs */
			if (carrierEntity) {
				switch (argv(0)) {
				case "model":
					if (isNew) {
						carrierEntity.Restore(argv(0), argv(1));
					}
				case "modelindex":
					break;
#if 0
				case "origin":
					vector newOrigin = stov(argv(1)) + Landmark_GetPosition();
					print(sprintf("Offsetting %S by %v\n", carrierEntity.m_strGlobalName, Landmark_GetPosition()));
					carrierEntity.m_vecRestoredOrigin = newOrigin;
					carrierEntity.Restore("origin", vtos(newOrigin));
					break;
#endif
				default:
					carrierEntity.Restore(argv(0), argv(1));
				}
			}
		}
	}

	fremove("trans.dat");
}

void
trigger_transition_pvsfallback(entity pvsTest)
{
	trigger_transition::SaveTransition(pvsTest, true);
}