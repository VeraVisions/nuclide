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

class
ncNodeEditor
{
	/** Links node wp towards w2. */
	nonvirtual void LinkNodes(graphNode_t *, graphNode_t *);
	/** Unlinks node wp from going towards w2. */
	nonvirtual void UnlinkNodes(graphNode_t *, graphNode_t *);
	/** Returns the id of the closest node in a node graph. */
	nonvirtual int FindClosestNode(vector);
	/** Saves the specified nodegraph to disk with the specified filename. */
	nonvirtual bool SaveFile(string);
	/** Loads the nodegraph from the specified filename off disk. */
	nonvirtual bool ReadFile(string, bool);
	/** Flushes the nodegraph being passed. */
	nonvirtual void Flush(void);

	nonvirtual void Cmd(void);
	nonvirtual void DrawDebugInfo(void);

private:
	nonvirtual void AutoLink(int wpidx);
	nonvirtual void CreateNode(entity ePlayer, int iAutoLink);
	nonvirtual void DeleteNode(int iID);
	nonvirtual void SetRadius(int iID, float flRadValue);
	nonvirtual void LinkFlag(int linkFlag);
	nonvirtual void Unlink(void);
	nonvirtual void UnlinkTwo(void);
	nonvirtual void HelperSpawns(void);
	nonvirtual void GoToPoint(entity pl);
	nonvirtual void ConnectOne(void);
	nonvirtual void ConnectTwo(void);
	nonvirtual void LoadCurrentMapNavMesh(void);
};

/** @} */ // end of nav
