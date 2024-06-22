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

/** @ingroup nav
 *
 *  @{
 */

/** Links node wp towards w2. */
void NodeEdit_LinkNodes(node_t *, node_t *);
/** Unlinks node wp from going towards w2. */
void NodeEdit_UnlinkNodes(node_t *, node_t *);
/** Returns the id of the closest node in a node graph. */
int NodeEdit_FindClosestNode(vector);
/** Saves the specified nodegraph to disk with the specified filename. */
bool NodeEdit_SaveFile(string);
/** Loads the nodegraph from the specified filename off disk. */
bool NodeEdit_ReadFile(string, bool);
/** Flushes the nodegraph being passed. */
void NodeEdit_Flush(void);

void NodeEdit_Cmd(void);
void NodeEdit_DrawDebugInfo(void);

/** @} */ // end of nav
