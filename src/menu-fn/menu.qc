/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

menupage_t g_mpage[] = {
	{ menu_main_init, menu_main_draw, menu_main_input },
	{ menu_configuration_init, menu_configuration_draw, menu_configuration_input },
	{ menu_audio_init, menu_audio_draw, menu_audio_input },
	{ menu_contentcontrol_init, menu_contentcontrol_draw, menu_contentcontrol_input },
	{ menu_controls_init, menu_controls_draw, menu_controls_input },
	{ menu_advancedcontrols_init, menu_advancedcontrols_draw, menu_advancedcontrols_input },
	{ menu_video_init, menu_video_draw, menu_video_input },
	{ menu_videomodes_init, menu_videomodes_draw, menu_videomodes_input },
	{ menu_videooptions_init, menu_videooptions_draw, menu_videooptions_input },
	{ menu_customgame_init, menu_customgame_draw, menu_customgame_input },
	{ menu_loadgame_init, menu_loadgame_draw, menu_loadgame_input },
	{ menu_multiplayer_init, menu_multiplayer_draw, menu_multiplayer_input },
	{ menu_customize_init, menu_customize_draw, menu_customize_input },
	{ menu_advancedcustomize_init, menu_advancedcustomize_draw, menu_advancedcustomize_input },
	{ menu_internetgames_init, menu_internetgames_draw, menu_internetgames_input },
	{ menu_addserver_init, menu_addserver_draw, menu_addserver_input },
	{ menu_chatrooms_init, menu_chatrooms_draw, menu_chatrooms_input },
	{ menu_chatroomslist_init, menu_chatroomslist_draw, menu_chatroomslist_input },
	{ menu_creategame_init, menu_creategame_draw, menu_creategame_input },
	{ menu_creategameinet_init, menu_creategameinet_draw, menu_creategameinet_input },
	{ menu_advancedmpoptions_init, menu_advancedmpoptions_draw, menu_advancedmpoptions_input },
	{ menu_filter_init, menu_filter_draw, menu_filter_input },
	{ menu_viewgameinfo_init, menu_viewgameinfo_draw, menu_viewgameinfo_input },
	{ menu_langames_init, menu_langames_draw, menu_langames_input },
	{ menu_spectategames_init, menu_spectategames_draw, menu_spectategames_input },
	{ menu_newgame_init, menu_newgame_draw, menu_newgame_input },
	{ menu_viewreadme_init, menu_viewreadme_draw, menu_viewreadme_input },
	{ menu_updates_init, menu_updates_draw, menu_updates_input }
};

void
main_init(void)
{
	for (int i = 0; i < g_mpage.length; i++) {
		g_mpage[i].m_init();
	}

	header = spawn(CHeader);
}

void
main_draw(void)
{
	g_mpage[g_menupage].m_draw();
	header.Draw();
}

void
main_input(float evtype, float scanx, float chary, float devid)
{
	g_mpage[g_menupage].m_input(evtype, scanx, chary, devid);
}
