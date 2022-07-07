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

#define MASTER_DNS "master.frag-net.com"
#define MASTER_PORT 27950

float srv_fldAdress;
float srv_fldName;
float srv_fldPing;
float srv_fldPlayers;
float srv_fldMaxplayers;
float srv_fldMap;
float srv_fldGame;

/* returns IP of master server */
string Master_Resolve(void);

/* returns the total amount of games */
int Master_GetTotalServers(void);

/* returns the amount of internet games */
int Master_GetInternetServers(void);

/* get completely new list of servers, hard-reset the cache */
void Master_UpdateCache(void);

/* refresh the current server cache */
void Master_RefreshCache(void);

/* sort the server cache without refreshing */
void Master_ResortCache(void);

/* grab a new internet game list */
void Master_GetInternetList(void);

/* grab a new LAN list */
void Master_GetLANList(void);
