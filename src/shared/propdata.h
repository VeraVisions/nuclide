/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*
	Prop-Data specs

	According to Source SDK's propdata.txt we've got
	a kinda sorta hacky definition table for this stuff:

	"PropData.txt"
	{

		"sometype"
		{
			// .. key/field attributes
			// e.g.
			"health" "10"
			"breakable_model" "somematerial"
		}

		"BreakableModels"
		{
			// completely unrelated to types defined in propdata.txt
			// but somehow still part of it?

			"somematerial"
			{
				// model path / fadeout time pair
				// e.g.
				"foo.vvm" "2.5"
			}
		}
	}

	The idea is that props specify the type of prop they are ("sometype") and it defines
	a set of sensible defaults.

	However, props can override any parts of this inside the model data itself.
	Currently no model format FTEQW supports allows for reading of said propdata.
	However we'll be loading "foobar.vvm.propdata" to remedy this for those.
*/

var string g_curPropData;

typedef enumflags
{
	PDFL_BLOCKLOS,		/* Does this block an AIs light of sight? */
	PDFL_AIWALKABLE,	/* can AI walk on this? */
	PDFL_ALLOWSTATIC	/* static simulation possible? */
} propdataFlag_t;

typedef struct
{
	string name;
	string base;
	float health;		/* health until break */
	propdataFlag_t flags;
	float damage_bullets;	/* dmg multipliers */
	float damage_melee;
	float damage_explosive;
	float explosive_damage;	/* once the damage/radius keys are set, make explosion upon break */
	float explosive_radius;
	string breakable_model;	/* name of BreakableModels entry in PropData.txt */
	int breakable_count;
} propdata_t;

/* entity will have to have a .propdata field pointing to a propdata id */
propdata_t *g_propdata;
int g_propdata_count;
var hashtable g_hashpropdata;

/* necessary API functions */
void PropData_Init(void);
void PropData_Shutdown(void);

int PropData_Load(string);	/* called when we read entity data, returns -1 when not found */
int PropData_ForModel(string);	/* called when we set a model, returns -1 when not found */
//int PropData_Read(string);	/* this just handles the contents of a prop_data model string */

void PropData_SetStage(string);
void PropData_Finish(void);

/* querying API */
typedef enum
{
	PROPINFO_HEALTH,
	PROPINFO_FLAGS,
	PROPINFO_DMG_BULLET,
	PROPINFO_DMG_MELEE,
	PROPINFO_DMG_EXPLOSIVE,
	PROPINFO_EXPLOSIVE_DMG,
	PROPINFO_EXPLOSIVE_RADIUS,
	PROPINFO_BREAKMODEL,
	PROPINFO_BREAKCOUNT
} propinfo_t;
__variant Prop_GetInfo(int, int);

typedef struct
{
	string model;
	float fadetime;
} breakmodel_t;

/* entity will have a .breakmodel field pointing to a breakmodel id */
propdata_t *g_breakmodel;
int g_breakmodel_count;

/* necessary API functions */
//void BreakModel_Init(void);
//void BreakModel_Shutdown(void);

//int BreakModel_Load(string);	/* called when we precache a model, returns -1 when not found */
//int BreakModel_Read(string);	/* this just handles the contents of a prop_data model string */
