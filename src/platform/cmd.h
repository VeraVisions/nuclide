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

/*! @file cmd.h
    @brief Console Commands

    Handles console commands that we deem helpful across the entire game platform.
    If you're building your own menu system, ensure to call Platform_RegisterCommands()
    somewhere in your m_init() function. In addition, all non-handled console commands
    in your menu's m_consolecommand() function should be forwarded to Platform_ConsoleCommand().
*/

/** Handles a platform library specific console command. Make this the `default` case in your m_consolecommand() function. */
bool Platform_ConsoleCommand(string commandString, int wordCount);

/** Called in order to register the platform library console commands. Called in your menu progs' m_init() function. */
void Platform_RegisterCommands(void);
