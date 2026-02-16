#!/usr/bin/env bash
set -euo pipefail

JSON_INPUT="$(cat)"

# tool_result からプランファイルのパスを抽出試行
PLAN_PATH="$(printf '%s' "$JSON_INPUT" | jq -r '
  .tool_result // "" |
  if test("\\.(md)") then
    capture("(?<path>/[^ \"]+\\.md)") | .path
  else
    empty
  end
' 2>/dev/null || true)"

# tool_result から取れなかった場合、直近のプランファイルを検索
if [[ -z "$PLAN_PATH" ]]; then
  PLAN_PATH="$(find "$HOME/.claude/plans" -name "*.md" -type f -not -name "CLAUDE.md" -newer /tmp/.atomic-pr-marker 2>/dev/null | head -1 || true)"
fi

# それでも見つからない場合、直近5分以内のファイルを使用
if [[ -z "$PLAN_PATH" ]]; then
  PLAN_PATH="$(find "$HOME/.claude/plans" -name "*.md" -type f -not -name "CLAUDE.md" -mmin -5 2>/dev/null | xargs ls -t 2>/dev/null | head -1 || true)"
fi

[[ -n "$PLAN_PATH" ]] || exit 0
[[ -f "$PLAN_PATH" ]] || exit 0
[[ -s "$PLAN_PATH" ]] || exit 0

printf '{"systemMessage":"PLAN FILE: %s\\n\\nYou MUST now invoke the atomic-pr-reviewer agent to break this plan into atomic PRs. Pass the plan file path to the agent."}' "$PLAN_PATH"
