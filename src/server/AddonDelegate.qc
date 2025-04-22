/*
 * Copyright (c) 2023-2025 Vera Visions LLC.
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

static void
ncAddonDelegate_Destroy(void)
{
	remove(self);
}

void
ncAddonDelegate::ncAddonDelegate(void)
{
	m_progHandle = 0;
	m_name = __NULL__;
}

/* init */
void
ncAddonDelegate::Load(void)
{
}

void
ncAddonDelegate::Shutdown(void)
{
}

bool
ncAddonDelegate::ConsoleCommand(ncPlayer pl, string cmd)
{
	return (false);
}

bool
ncAddonDelegate::ClientCommand(ncClient pl, string cmd)
{
	return (false);
}

void
ncAddonDelegate::PlayerConnect(ncPlayer pl)
{
}

void
ncAddonDelegate::PlayerDisconnect(ncPlayer pl)
{
}

void
ncAddonDelegate::NPCDeath(ncActor npc, ncEntity attacker, ncEntity inflictor)
{
}

void
ncAddonDelegate::PlayerDeath(ncPlayer deadPlayer, ncEntity inflictor, ncEntity attacker, string weaponDef)
{
}

void
ncAddonDelegate::PlayerSpawn(ncPlayer pl)
{
}

string
ncAddonDelegate::Name(void)
{
	return (m_name);
}

void
ncAddonDelegate::Close(void)
{
	Shutdown();

	printf("Closed addon %S.\n", m_name);
	m_progHandle = 0;
	m_name = __NULL__;
	think = ncAddonDelegate_Destroy;
	nextthink = time;
}

void
ncAddonDelegate::LinkProgs(void)
{
		ADDON_LINK(Load, "Plug_Load")
		ADDON_LINK(Shutdown, "Plug_Shutdown")
		ADDON_LINK(ConsoleCommand, "Plug_ConsoleCommand")
		ADDON_LINK(ClientCommand, "Plug_ClientCommand")
		ADDON_LINK(PlayerConnect, "Plug_PlayerConnect")
		ADDON_LINK(PlayerDisconnect, "Plug_PlayerDisconnect")
		ADDON_LINK(PlayerSpawn, "Plug_PlayerSpawn")
		ADDON_LINK(PlayerDeath, "Plug_PlayerDeath")
		ADDON_LINK(NPCDeath, "Plug_NPCDeath")
}

ncAddonDelegate
ncAddonDelegate::CreateFromProgs(string addonName, float progHandle)
{
	ncAddonDelegate newRule = __NULL__;

	if (progHandle) {
		newRule = spawn(ncAddonDelegate);
		newRule.m_progHandle = progHandle;
		newRule.m_name = addonName;
		newRule.LinkProgs();
	}

	return (newRule);
}
