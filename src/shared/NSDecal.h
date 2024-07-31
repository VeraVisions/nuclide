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

/*! \brief This entity class represents decals  */

/*!QUAKED NSDecal (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW

@ingroup baseclass
*/
class
NSDecal
{
public:
	void NSDecal(void);

#ifdef SERVER
	virtual float SendEntity(entity, float);
#else
	virtual void ReceiveEntity(void);
	virtual float predraw(void);
	virtual void BuildShader(void);
#endif

	/** Paint the given decal at the specified position. */
	virtual void Place(vector, string);

private:
	string m_strShader;
	string m_strTexture;
};

typedef struct
{
	float fraction;
	vector normal;
	vector endpos;
} traced_t;

traced_t g_tracedDecal;

void
decal_pickwall(entity dself, vector vpos)
{
	traced_t tmp[6];
	float frac = 1.0f;

	g_tracedDecal.fraction = 1.0f;
	g_tracedDecal.endpos = [0,0,0];
	g_tracedDecal.normal = [0,0,0];

	/* unrolled, trace against walls in all 6 directions */
	makevectors([0, 0, 0]);
	traceline(vpos + (v_forward * -1), vpos + (v_forward * 128), 0, dself);
	tmp[0].fraction = trace_fraction;
	tmp[0].normal = trace_plane_normal;
	tmp[0].endpos = trace_endpos;
	traceline(vpos + (v_forward * 1), vpos + (v_forward * -128), 0, dself);
	tmp[1].fraction = trace_fraction;
	tmp[1].normal = trace_plane_normal;
	tmp[1].endpos = trace_endpos;
	traceline(vpos + (v_right * -1), vpos + (v_right * 128), 0, dself);
	tmp[2].fraction = trace_fraction;
	tmp[2].normal = trace_plane_normal;
	tmp[2].endpos = trace_endpos;
	traceline(vpos + (v_right * 1), vpos + (v_right * -128), 0, dself);
	tmp[3].fraction = trace_fraction;
	tmp[3].normal = trace_plane_normal;
	tmp[3].endpos = trace_endpos;
	traceline(vpos + (v_up * -1), vpos + (v_up * 128), 0, dself);
	tmp[4].fraction = trace_fraction;
	tmp[4].normal = trace_plane_normal;
	tmp[4].endpos = trace_endpos;
	traceline(vpos + (v_up * 1), vpos + (v_up * -128), 0, dself);
	tmp[5].fraction = trace_fraction;
	tmp[5].normal = trace_plane_normal;
	tmp[5].endpos = trace_endpos;

	/* pick whatever wall is closest */
	for (int i = 0; i < 6; i++) {
		if (tmp[i].fraction < frac) {
			frac = tmp[i].fraction;
			g_tracedDecal.fraction = tmp[i].fraction;
			g_tracedDecal.endpos = tmp[i].endpos;
			g_tracedDecal.normal = tmp[i].normal;
		}
	}
}

void Decals_Init(void);
NSDecal Decals_Next(vector pos);

/** Places a desired decal at the specified position. */
void Decals_Place(vector pos, string dname);

#ifdef CLIENT
string Decal_Precache(string decalTex);
void Decal_Parse(void);
void Decal_Reload(void);
void Decal_Shutdown(void);
#endif
