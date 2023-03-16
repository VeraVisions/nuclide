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

int g_iCubeProcess;
entity g_eCubeCycle;
vector g_vecCubePos;
float g_dCubeSize;

void CMap_Check(void);
void CMap_Shoot(void);

/*!QUAKED env_cubemap (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Specifies a location for which a cubemap will be generated when the 
buildcubemaps console command is executed.

# KEYS
- "scale" : Texture dimension at which to render the cubemap. Default is "32".

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class
env_cubemap:NSEntity
{
public:
	void env_cubemap(void);
	virtual void SpawnKey(string,string);
	virtual bool CanSpawn(bool);

private:
	int m_iSize;
};

void
env_cubemap::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "scale":
		m_iSize = stoi(strKey);
		if (m_iSize <= 16) {
			m_iSize = 16;
		} else if (m_iSize <= 32) {
			m_iSize = 32;
		} else if (m_iSize <= 64) {
			m_iSize = 64;
		} else if (m_iSize <= 128) {
			m_iSize = 128;
		} else {
			m_iSize = 256;
		}
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

bool
env_cubemap::CanSpawn(bool clientSide)
{
	return true;
}

void
env_cubemap::env_cubemap(void)
{
	m_iSize = 32;
	isCSQC = true;
}

/*
=================
CMap_Check

	Checks whether or not a specific cubemap file was dumped, goes to the next
=================
*/
void
CMap_Shoot(void)
{
	string strReflectcube;
	if (self.owner) {
		env_cubemap tmp = (env_cubemap) self.owner;
		print("^3Cubemap processing...\n");
		g_vecCubePos = tmp.origin;
		g_dCubeSize = (float)tmp.m_iSize;

		g_view.SetClientAngle([0,0,0]);
		g_view.SetCameraAngle([0,0,0]);

		strReflectcube = sprintf(
					"env/%s_%d_%d_%d.ktx",
					mapname,
					g_vecCubePos[0],
					g_vecCubePos[1],
					g_vecCubePos[2]);
		localcmd(sprintf(
			"screenshot_cubemap %S %i\n",
			strReflectcube,
			tmp.m_iSize));
		self.think = CMap_Check;
		self.nextthink = time + 0.25f;
	} else {
		print("^2Cubemaps done...\n");
		localcmd("vid_reload\n");
		g_iCubeProcess = FALSE;
		remove(self);
	}
}

/*
=================
CMap_Check

	Checks whether or not a specific cubemap file was dumped, goes to the next
=================
*/
void
CMap_Check(void)
{
	self.owner = find(self.owner, classname, "env_cubemap");
	self.think = CMap_Shoot;
	self.nextthink = time + 0.1f; /* because sigh */
}

/*
=================
CMap_Build

	Called upon 'buildcubemaps'
=================
*/
void
CMap_Build(void)
{
	/* prevent command spam */
	if (g_iCubeProcess == TRUE) {
	        return;
	}

	localcmd("r_speeds 0\n");
	localcmd("show_fps 0\n");
	localcmd("r_showfields 0\n");
	localcmd("r_showshaders 0\n");
	localcmd("r_showbboxes 0\n");
	localcmd("r_wireframe 0\n");
	localcmd("r_hdr_irisadaptation 0\n");
	localcmd("r_postprocshader \"\"0\n");
	print("^4Building cubemaps...\n");
	g_eCubeCycle = spawn();
	g_eCubeCycle.owner = find(world, classname, "env_cubemap");

	if (g_eCubeCycle.owner) {
		g_eCubeCycle.think = CMap_Shoot;
		g_eCubeCycle.nextthink = time;
		g_iCubeProcess = TRUE;
	}
}
