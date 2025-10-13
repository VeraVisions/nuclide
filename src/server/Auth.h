/*
 * Copyright (c) 2025 Vera Visions LLC.
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

/** Authentication Manager.

Designed to be decentralized.

Goal: Tie any non-bot player slot to an account
somewhere on the web.
Multiple sources could be used to verify identities.
In our implementation, we'll be mainly targeting ActivityPub
as it is a W3C standard and therefore best suited for this
purpose.

Non-goal: Do not ask players to sign up to a new service. Do not
collect, sell or transmit user data under any circumstances. Do not
implement the authentication to be tied to a single external service
or specific implementation of a standard. Do not discriminate on behalf
of server administrators.

Justification: Remote identities can be used as storage, but can also help
tie multiple sessions to a single identity. It can also be used by single
server administrators (or their networks) to moderate.
You could limit sessions or participation to instances that select identities
may belong to in a non-punishing way as well. This is meant to be neutral.

# Cvars

## auth_enabled 0/1

When set, will enable GID verification of user identities.

## auth_connectUnauthorizedClients 0/1

When set, will only allow authorized clients to join the server.

## auth_instanceFilter [example.com[,example2.com]]

When set, will only allow verified users from a certain instances to join the server.

*/
class
ncAuthManager
{
public:
	void ncAuthManager(void);

	nonvirtual bool Connect(ncClient targetClient);
	nonvirtual void Disconnect(ncClient targetClient);
	nonvirtual bool AllowRespawn(ncClient targetClient);

private:
	nonvirtual void PassClient(ncClient targetClient);
	nonvirtual void FailClient(ncClient targetClient);
	nonvirtual void VerifyFingerprint(float requestID, string dataString);
};

var bool autocvar_auth_enabled = false;
var bool autocvar_auth_connectUnauthorizedClients = true;
var string autocvar_auth_limitToInstance = "";
