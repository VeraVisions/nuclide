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

/** @ingroup client
 *
 *  @{
 */

/** Tasked with managing overview/radar type widgets.
It's able to load different types of overviews, in addition to none at all.

It's able to load HLTV styled overviews used in GoldSrc and Source.
@ingroup baseclass
*/
class
NSRadar:NSView
{
public:
	void NSRadar(void);

	/** Init a radar for the map we're currently on. */
	nonvirtual NSRadar InitForCurrentMap(void);
	/** Init a radar for a specified map, will automatically choose the best available type. */
	nonvirtual NSRadar InitWithMapname(string);

	/** Init as Overview from GoldSrc HLTV script file. */
	nonvirtual NSRadar InitFromHLTVScript(string);
	/** Init as Overview from Source Engine HLTV script file. */
	nonvirtual NSRadar InitFromSourceHLTVScript(string);
	/** Init a wireframe overview. */
	nonvirtual NSRadar InitWireframe(void);
	/** Init an empty overview. */
	nonvirtual NSRadar InitEmpty(void);

	nonvirtual void RenderOverviewPlane(void);
	nonvirtual void RenderWireframePlane(void);

	nonvirtual void SetRadarPitch(float);

	virtual void RenderPlayerIcon(entity);

	/* overrides */
	virtual void RenderView(void);
	virtual void SetupView(void);


private:
	/* internal */
	vector m_vecOrigin;
	bool m_bRotated;
	string m_strMaterial;
	float m_flScale;
	float m_flHeight;
	float m_flZoom;

	vector m_vecVert1;
	vector m_vecVert2;
	vector m_vecVert3;
	vector m_vecVert4;

	bool m_bShowPlayers;

	float m_flRadarPitch;

	nonvirtual void CalculateVertices(void);
	nonvirtual void CalculateVerticesSource(float, float);
};

/** @} */ // end of client