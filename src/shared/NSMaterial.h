/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/** Parent-class of all materials, used for footsteps, impacts and more. */
class
NSMaterial
{
private:
	string m_strMaterialName;
	
	bool m_bPenetrable;
	bool m_bFootsteps;
	float m_flFriction;
	string m_strStepSound;

	nonvirtual void _PrecacheAndExit(string);

public:
	void NSMaterial(void);

	/** Returns the friction multiplier of this surface. */
	virtual float GetFriction(void);
	/** Returns whether the material creates footstep sounds. */
	virtual bool Footsteps(void);
	/** Returns whether or not the material is penetrable. */
	virtual bool Penetrable(void);
	/** Called whenever a client makes a stepping sound. */
	virtual void FootstepSound(NSClient);
	/** Called whenever a bullet impact happens onto this material. */
	virtual void Impact(vector,vector);

	/** Called upon init for each registered game material. */
	virtual void Precache(void);

};

hashtable g_hashMaterials;
hashtable hashMaterials;

void Materials_Init(void);
NSMaterial Material_FromTexture(string);

/* legacy material compatibility */

/** hlmaterial to classname mapper table */
typedef struct
{
	string id;
	string matclass;
} hlmaterials_lut;

hlmaterials_lut *g_hlmlut;
var int g_hlmlut_count;
var int g_hlmaterial_entries;

var bool g_materialsAreLegacy;

/* FIXME: world.... sigh, we should box this into a worldspawn class */
.string materials_file;