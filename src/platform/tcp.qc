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

int
TCP_Connect(tcpinfo_t *in, string path)
{
	in.m_fSocket = fopen(path, -1);

	if (in.m_fSocket < 0) {
		ncError("Unable to access %s", path);
	} else {
		/* we got at least this far */
		in.m_iState = STATE_CONNECTING;
	}

	return (int)in.m_fSocket;
}

void
TCP_Disconnect(tcpinfo_t *in)
{
	if (in.m_iState == STATE_DISCONNECTED)
		return;

	in.m_iState = STATE_DISCONNECTED;
	fclose(in.m_fSocket);
	in.m_fSocket = -1;
}

int
TCP_Send(tcpinfo_t *in, string msg)
{
	if (in.m_iState == STATE_DISCONNECTED) {
		dprint("^1TCP_Send^7: Can't send, we're disconnected\n");
		return (0);
	}

	/* the buffer is full. we've been unable to send messages for a while */
	if (in.m_iBufferLines >= (TCP_BUFFER_LENGTH - 1)) {
		dprint("^1TCP_Send^7: Buffer full.\n");
		return (0);
	}

	in.m_strBuffer[in.m_iBufferLines] = msg;
	in.m_iBufferLines++;
	return (1);
}

string
TCP_Receive(tcpinfo_t *in)
{
	/* not even open */
	if (in.m_fSocket <= 0)
		return ("");

	return fgets(in.m_fSocket);
}

/* you want to run this every frame */
void
TCP_Frame(tcpinfo_t *in)
{
	string out;

	/* not even open */
	if (in.m_iState == STATE_DISCONNECTED)
		return;

	/* got nothing worth sending */
	if (in.m_strBuffer[0] == "" || in.m_iBufferLines <= 0)
		return;

	/* if the send was unsuccessful, try next frame */
	out = (string)memalloc(strlen(in.m_strBuffer[0]));

	for (float i = 0; i < strlen(in.m_strBuffer[0]); i++)
		out[i] = str2chr(in.m_strBuffer[0], i);

	if (fwrite(in.m_fSocket, (void *)out, strlen(in.m_strBuffer[0])) <= 0) {
		dprint("^1TCP_Frame^7: Unsuccessful frame\n");
		memfree((__variant *)out);
		return;
	}

	ncLog("Sent %s", in.m_strBuffer[0]);

	/* at least one successful write went through */
	in.m_iState = STATE_CONNECTED;

	/* a send was successful after here */
	for (int i = 0; i < (TCP_BUFFER_LENGTH - 1); i++) {
		in.m_strBuffer[i] = in.m_strBuffer[i+1];
	}

	in.m_iBufferLines--;
	memfree((__variant *)out);
}

tcpstate_t
TCP_GetState(tcpinfo_t *in)
{
	if (!in)
		return STATE_DISCONNECTED;

	return in.m_iState;
}
