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

/*! @file master.h
    @brief Master Server related functions.

    Various functions to help communicate with the master
    server(s).
*/

/** The default master server address. */
#define MASTER_DNS "master.frag-net.com"
/** The default port used to talk to the master server. */
#define MASTER_PORT 27950

float srv_fldAdress;
float srv_fldName;
float srv_fldPing;
float srv_fldPlayers;
float srv_fldMaxplayers;
float srv_fldMap;
float srv_fldGame;

/** Returns IP of master server. */
string Master_Resolve(void);

/** Returns the total amount of games from both LAN and Internet. */
int Master_GetTotalServers(void);

/** Returns the amount of internet games from the last refresh. */
int Master_GetInternetServers(void);

/** Returns the amount of LAN servers from the last refresh. */
int Master_GetLANServers(void);

/** Get completely new list of servers, hard-reset the cache. Forgets about all else. */
void Master_UpdateCache(void);

/** Refresh the current server cache. Will only talk to known servers. */
void Master_RefreshCache(void);

/** Re-Sort the server cache without refreshing. */
void Master_ResortCache(void);

/** Grab a NEW internet game list. Will flush any other lists. */
void Master_GetInternetList(void);

/** Grab a NEW LAN list. Will flush any other lists. */
void Master_GetLANList(void);
