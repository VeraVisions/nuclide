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

#define TCP_BUFFER_LENGTH 32

/** State of a TCP connection. */
typedef enum
{
	STATE_DISCONNECTED, /**< We're disconnected/unconnected. */
	STATE_CONNECTING, /**< We're in the process of connecting. */
	STATE_CONNECTED	/**< We're fully connected. */
} tcpstate_t;

typedef struct
{
	filestream m_fSocket;
	string m_strBuffer[TCP_BUFFER_LENGTH];
	int m_iBufferLines;
	tcpstate_t m_iState;
} tcpinfo_t;

/** Open a TCP socket connection.

@param in Pointer to a tcpinfo_t struct to save state into.
@param path The address:port to which we should connect to.
@return The descriptor for the newly opened socket. Will be below 0 if invalid. */
int TCP_Connect(tcpinfo_t *in, string path);

/** Closes a TCP socket connection.

@parm in Pointer to a tcpinfo_t that is to be closed. */
void TCP_Disconnect(tcpinfo_t *in);

/** Send a string buffer to a specified TCP connection.

@param in Pointer to an active TCP connection.
@param msg The message to send to the TCP connection. */
int TCP_Send(tcpinfo_t *in, string msg);

/** Receive the latest message from a TCP connection.

@param in Pointer to an active TCP connection.*/
string TCP_Receive(tcpinfo_t *in);

/** You want to run this every frame.

@param in Pointer to an active TCP connection. */
void TCP_Frame(tcpinfo_t *in);

/** Returns the tcpstate_t of a connection.

@param in Pointer to an active TCP connection.*/
tcpstate_t TCP_GetState(tcpinfo_t *in);
