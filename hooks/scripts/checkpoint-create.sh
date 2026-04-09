#!/bin/bash
# checkpoint-create.sh - Deterministically create a Context Engine checkpoint
#
# Past versions of the framework relied on LLM agents to "create checkpoint CP-NNN"
# at phase boundaries — and across 50+ features in real projects, MANIFEST.md
# remained 0 bytes because the LLM consistently skipped or narrated the operation
# instead of executing it. This script makes checkpoint creation a single shell
# call that the calling command CANNOT skip.
#
# Usage:
#   checkpoint-create.sh <label> <trigger>
#
# Arguments:
#   label   — short human label (e.g., "post-plan auth-feature", "pre-team api-rewrite")
#   trigger — one of: phase-boundary, pre-agent-team, manual, paused
#
# Behavior:
#   1. Resolves the next CP-NNN by reading MANIFEST.md
#   2. Snapshots specified .context/ files into .context/checkpoints/CP-NNN/
#   3. Writes snapshot-meta.json with timestamp, branch, PRP path, progress, git SHA
#   4. Stages and commits .context/ artifacts (so they survive branching/worktrees)
#   5. Creates a lightweight git tag `checkpoint-NNN`
#   6. Appends an entry to MANIFEST.md
#
# Idempotency: Safe to call multiple times. Each call creates a new checkpoint.
# If MANIFEST.md doesn't exist, it's created from the bundled template header.
#
# Exit codes:
#   0 = checkpoint created successfully
#   1 = creation failed (git error, file error, etc.)
#   2 = bad arguments

set -e

LABEL="$1"
TRIGGER="${2:-manual}"

if [ -z "$LABEL" ]; then
    echo "Usage: $0 <label> <trigger>" >&2
    echo "  trigger ∈ {phase-boundary, pre-agent-team, manual, paused}" >&2
    exit 2
fi

CTX_DIR=".context"
CP_ROOT="$CTX_DIR/checkpoints"
MANIFEST="$CP_ROOT/MANIFEST.md"

if [ ! -d "$CTX_DIR" ]; then
    echo "ERROR: $CTX_DIR not found. Run /init first." >&2
    exit 1
fi

mkdir -p "$CP_ROOT"

# Ensure MANIFEST.md exists with at least a header
if [ ! -f "$MANIFEST" ] || [ ! -s "$MANIFEST" ]; then
    cat > "$MANIFEST" << 'EOF'
# Checkpoints

Hybrid snapshots: git tag (code state) + .context/ copy (context state).
Created automatically at phase boundaries and before Agent Team execution.

EOF
fi

# --- Resolve next checkpoint number ---
LAST_NNN=$(grep -oE 'CP-[0-9]{3,}' "$MANIFEST" 2>/dev/null | sed 's/CP-//' | sort -n | tail -1)
LAST_NNN=${LAST_NNN:-0}
# Strip leading zeros for arithmetic
LAST_NUM=$((10#$LAST_NNN))
NEXT_NUM=$((LAST_NUM + 1))

# Avoid colliding with existing git tags (same logic as /checkpoint create)
while git rev-parse "checkpoint-$(printf '%03d' $NEXT_NUM)" >/dev/null 2>&1; do
    NEXT_NUM=$((NEXT_NUM + 1))
done

NNN=$(printf '%03d' $NEXT_NUM)
TAG="checkpoint-$NNN"
SNAP_DIR="$CP_ROOT/CP-$NNN"
mkdir -p "$SNAP_DIR"

# --- Gather metadata ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "no-git")

# Locate active PRP (IN_PROGRESS or APPROVED)
ACTIVE_PRP=""
PRP_PROGRESS="n/a"
if [ -d "$CTX_DIR/features" ]; then
    ACTIVE_PRP=$(grep -rl "Status: IN_PROGRESS\|Status: APPROVED" "$CTX_DIR/features"/*/PRP*.md 2>/dev/null | head -1)
    if [ -n "$ACTIVE_PRP" ]; then
        TOTAL=$(grep -c '^\s*[0-9]*\.\s*\[' "$ACTIVE_PRP" 2>/dev/null || echo "0")
        DONE=$(grep -c '^\s*[0-9]*\.\s*\[x\]' "$ACTIVE_PRP" 2>/dev/null || echo "0")
        PRP_PROGRESS="${DONE}/${TOTAL}"
    fi
fi

# --- Snapshot files into checkpoint dir ---
SNAPSHOT_LIST=(
    "knowledge/LEARNINGS.md"
    "knowledge/dependencies/PINS.md"
    "errors/INDEX.md"
    "features/FEATURES.md"
    "patterns/CODE_PATTERNS.md"
    "patterns/ANTI_PATTERNS.md"
    "metrics/HEALTH.md"
)

snapshotted=0
for rel in "${SNAPSHOT_LIST[@]}"; do
    src="$CTX_DIR/$rel"
    if [ -f "$src" ]; then
        dst="$SNAP_DIR/$rel"
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        snapshotted=$((snapshotted + 1))
    fi
done

# Snapshot active PRP
if [ -n "$ACTIVE_PRP" ] && [ -f "$ACTIVE_PRP" ]; then
    PRP_REL="${ACTIVE_PRP#$CTX_DIR/}"
    mkdir -p "$SNAP_DIR/$(dirname "$PRP_REL")"
    cp "$ACTIVE_PRP" "$SNAP_DIR/$PRP_REL"
    snapshotted=$((snapshotted + 1))
fi

# Snapshot ADR files (excluding template)
if [ -d "$CTX_DIR/decisions" ]; then
    for adr in "$CTX_DIR/decisions"/ADR-*.md; do
        [ -f "$adr" ] || continue
        bn=$(basename "$adr")
        case "$bn" in
            ADR-000-template.md) continue ;;
        esac
        mkdir -p "$SNAP_DIR/decisions"
        cp "$adr" "$SNAP_DIR/decisions/$bn"
        snapshotted=$((snapshotted + 1))
    done
fi

# Snapshot library/stack knowledge files (excluding TEMPLATE.md)
for kdir in libraries stack; do
    if [ -d "$CTX_DIR/knowledge/$kdir" ]; then
        for kf in "$CTX_DIR/knowledge/$kdir"/*.md; do
            [ -f "$kf" ] || continue
            bn=$(basename "$kf")
            [ "$bn" = "TEMPLATE.md" ] && continue
            mkdir -p "$SNAP_DIR/knowledge/$kdir"
            cp "$kf" "$SNAP_DIR/knowledge/$kdir/$bn"
            snapshotted=$((snapshotted + 1))
        done
    fi
done

# --- Write snapshot metadata ---
cat > "$SNAP_DIR/snapshot-meta.json" << EOF
{
  "checkpoint": "CP-$NNN",
  "label": "$LABEL",
  "trigger": "$TRIGGER",
  "timestamp": "$TIMESTAMP",
  "branch": "$BRANCH",
  "git_sha": "$GIT_SHA",
  "active_prp": "$ACTIVE_PRP",
  "prp_progress": "$PRP_PROGRESS",
  "files_snapshotted": $snapshotted
}
EOF

# --- Commit .context/ artifacts and tag ---
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Stage only .context/ changes
    git add "$CTX_DIR" 2>/dev/null || true

    # Detect non-.context/ uncommitted changes (we'll stash them if any)
    DIRTY_NON_CONTEXT=$(git diff --name-only HEAD 2>/dev/null | grep -v "^$CTX_DIR/" | head -1 || true)
    DIRTY_NOTE=""

    # Commit .context/ artifacts if there's anything staged
    if ! git diff --cached --quiet 2>/dev/null; then
        git -c commit.gpgsign=false commit -m "docs: checkpoint CP-$NNN $LABEL" >/dev/null 2>&1 || true
    fi

    # Tag
    if [ -n "$DIRTY_NON_CONTEXT" ]; then
        # Working tree has non-.context/ changes — stash, tag, pop
        git stash push -u -m "checkpoint-$NNN-tmp" >/dev/null 2>&1 && DIRTY_NOTE=" (working tree was dirty)" || true
        git tag "$TAG" -m "$LABEL" 2>/dev/null || true
        git stash pop >/dev/null 2>&1 || true
    else
        git tag "$TAG" -m "$LABEL" 2>/dev/null || true
    fi
else
    DIRTY_NOTE=" (no git repo)"
fi

# --- Append to MANIFEST.md ---
cat >> "$MANIFEST" << EOF

### CP-$NNN: $LABEL
**Created**: $TIMESTAMP
**Git tag**: $TAG
**Trigger**: $TRIGGER
**Branch**: $BRANCH
**PRP**: ${ACTIVE_PRP:-none}
**PRP progress**: $PRP_PROGRESS
**Files snapshotted**: $snapshotted$DIRTY_NOTE
EOF

echo "Checkpoint CP-$NNN created. Tag: $TAG. $snapshotted files snapshotted."
exit 0
