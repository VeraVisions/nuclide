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

static ncDict g_activitiesDecl;

void
Activities_Init(void)
{
	Activities_Shutdown();
	g_activitiesDecl = ncDict::LoadDeclFromFile("activities", "typeinfo/activities.decl");
}

void
Activities_Shutdown(void)
{
	if (g_activitiesDecl) {
		remove(g_activitiesDecl);
		g_activitiesDecl = 0;
	}
}

static bool
Activities_Enabled(void)
{
	return (g_activitiesDecl) ? (true) : (false);
}

static float
Activities_GetActID(string actNameCheck)
{
	if (Activities_Enabled() == false) {
		return (ACTIVITY_NOTFOUND);
	}

	string actValue = g_activitiesDecl.GetString(actNameCheck);

	if (STRING_SET(actValue)) {
		return stof(actValue);
	}

	return (ACTIVITY_NOTFOUND);
}

float
Activities_GetSequenceForEntity(ncEntity targetEntity, string activityName)
{
	float actCount;
	string actNameCheck;
	string fireValue;

	if (Activities_Enabled() == false) {
		return (ACTIVITY_NOTFOUND);
	}

	/* check within sub-def, then classname decl */
	actNameCheck = strcat("act_", activityName);
	fireValue = targetEntity.GetSpawnString(actNameCheck);

	/* not in class decl either. look it up in the model */
	if (!STRING_SET(fireValue)) {
		float actValue = Activities_GetActID(actNameCheck);

		if (actValue != ACTIVITY_NOTFOUND) {
			/* look it up in the model itself now */
			float frameGroup = frameforaction(targetEntity.modelindex, actValue);
			return (frameGroup);
		}
	} else {
		actCount = tokenizebyseparator(fireValue, ",");

		if (actCount == 1) {
			return stof(fireValue);
		} else {
			float randomValue = floor(pseudorandom() * actCount);
			string commandString = argv(randomValue);
			return stof(Constants_LookUp(commandString,commandString));
		}
	}

	/* not in fireInfo, not in model... skip! */
	return (ACTIVITY_NOTFOUND);
}

float
Activities_GetSequenceForEntityDef(ncEntity targetEntity, string activityName, string subDef)
{
	float actCount;
	string actNameCheck;
	string fireValue;

	if (Activities_Enabled() == false) {
		return (ACTIVITY_NOTFOUND);
	}

	/* check within sub-def, then classname decl */
	actNameCheck = strcat("act_", activityName);
	fireValue = targetEntity.GetSubDefString(subDef, actNameCheck);

	/* not in class decl either. look it up in the model */
	if (!STRING_SET(fireValue)) {
		return Activities_GetSequenceForEntity(targetEntity, actNameCheck);
	} else {
		actCount = tokenizebyseparator(fireValue, ",");

		if (actCount == 1) {
			return stof(unpackStringCommand(fireValue));
		} else {
			float randomValue = floor(pseudorandom() * actCount);
			return stof(unpackStringCommand(argv(randomValue)));
		}
	}

	/* not in fireInfo, not in model... skip! */
	return (ACTIVITY_NOTFOUND);
}
