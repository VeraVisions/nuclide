/*
 * Copyright (c) 2024 Vera Visions LLC.
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

bool
Cmd_ParseClientCommand(NSClient sender, string cmd, int commandArguments)
{
	switch (argv(0)) {
	case "say":
		if (commandArguments == 2)
			g_grMode.ChatMessageAll(sender, argv(1));
		else
			g_grMode.ChatMessageAll(sender, substring(cmd, 5, -2));
		break;
	case "say_team":
		if (commandArguments == 2)
			g_grMode.ChatMessageTeam(sender, argv(1));
		else
			g_grMode.ChatMessageTeam(sender, substring(cmd, 10, -2));
		break;
	case "spectate":
		if (sender.classname != "player")
			break;

		NSClientPlayer pl = (NSClientPlayer)sender;
		pl.MakeSpectator();
		break;
	case "play":
		if (sender.classname != "spectator")
			break;

		EntityDef_SpawnClassname("player");
		PutClientInServer();
		break;
	case "setpos":
		if (cvar("sv_cheats") == 1) {
			setorigin(sender, stov(argv(1)));
		}

		break;
	case "timeleft":
		string msg;
		string timestring;
		float timeleft;
		timeleft = cvar("timelimit") - (time / 60);
		timestring = Util_TimeToString(timeleft);
		msg = sprintf("we have %s minutes remaining", timestring);
		bprint(PRINT_CHAT, msg);
		break;
	default:
		clientcommand(sender, cmd);
	}
}