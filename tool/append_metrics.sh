#!/usr/bin/env bash
# append_metrics.sh — append one CSV row per CI run to history.csv on the
# orphan `ci-metrics` branch and regenerate DASHBOARD.md there.
#
# Reads gate_report.json (if present) + git-derived diff stats, appends a
# row to history.csv, regenerates DASHBOARD.md, and pushes both to the
# `ci-metrics` branch using GH_TOKEN. Never touches the calling checkout.
#
# Env:
#   GH_TOKEN        - token with push access (required in CI)
#   GATE_OUTCOME    - steps.gate.outcome from the workflow ("success"/"failure"), optional
#   GITHUB_ACTIONS  - "true" when running on a runner; otherwise this script no-ops
#   DRY_RUN         - "1" to print the row + dashboard to stdout and exit before
#                     any branch/network operation (useful for local validation)
#
# CSV schema (exact header):
#   schema,ts,sha,branch,run_id,pass,integrity_pass,tests_total,tests_failed,
#   suite_load_errors,coverage_pct,analyzer_errors,analyzer_warnings,
#   analyzer_infos,size_violations,baseline_count,largest_file,p90_file,
#   struct_violations,wall_secs,files_changed,insertions,deletions

set -u

CSV_HEADER="schema,ts,sha,branch,run_id,pass,integrity_pass,tests_total,tests_failed,suite_load_errors,coverage_pct,analyzer_errors,analyzer_warnings,analyzer_infos,size_violations,baseline_count,largest_file,p90_file,struct_violations,wall_secs,files_changed,insertions,deletions"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATE_REPORT="${REPO_ROOT}/gate_report.json"

# ---------------------------------------------------------------------------
# Local no-op guard
# ---------------------------------------------------------------------------
if [ "${DRY_RUN:-0}" != "1" ] && [ "${GITHUB_ACTIONS:-}" != "true" ]; then
  echo "local run: metrics append skipped"
  exit 0
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
jq_or_default() {
  # jq_or_default <filter> <default>
  local filter="$1"
  local default="$2"
  local val
  val="$(jq -r "${filter} // empty" "${GATE_REPORT}" 2>/dev/null)"
  if [ -z "${val}" ] || [ "${val}" = "null" ]; then
    echo "${default}"
  else
    echo "${val}"
  fi
}

# ---------------------------------------------------------------------------
# Gather identity fields
# ---------------------------------------------------------------------------
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
SHA="$(cd "${REPO_ROOT}" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
BRANCH="${GITHUB_REF_NAME:-$(cd "${REPO_ROOT}" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")}"
RUN_ID="${GITHUB_RUN_ID:-local}"

# ---------------------------------------------------------------------------
# Gather metrics from gate_report.json (tolerate absence / missing fields)
# ---------------------------------------------------------------------------
if [ -f "${GATE_REPORT}" ]; then
  PASS="$(jq_or_default '.pass' 'false')"
  WALL_SECS="$(jq_or_default '.wall_secs' '0')"
  TESTS_TOTAL="$(jq_or_default '.tests.total' '0')"
  TESTS_FAILED="$(jq_or_default '.tests.failed' '0')"
  SUITE_LOAD_ERRORS="$(jq_or_default '.tests.suite_load_errors' '0')"
  ANALYZER_ERRORS="$(jq_or_default '.analyzer.errors' '0')"
  ANALYZER_WARNINGS="$(jq_or_default '.analyzer.warnings' '0')"
  ANALYZER_INFOS="$(jq_or_default '.analyzer.infos' '0')"
  SIZE_VIOLATIONS="$(jq -r '(.size.violations // []) | length' "${GATE_REPORT}" 2>/dev/null)"
  [ -z "${SIZE_VIOLATIONS}" ] && SIZE_VIOLATIONS=0
  BASELINE_COUNT="$(jq_or_default '.size.baseline_count' '0')"
  LARGEST_FILE="$(jq_or_default '.size.largest' '0')"
  P90_FILE="$(jq_or_default '.size.p90' '0')"
  STRUCT_VIOLATIONS="$(jq -r '
    ((.struct.widget_helpers // []) | length) +
    ((.struct.barrel_files // []) | length) +
    ((.struct.forbidden_imports // []) | length)
  ' "${GATE_REPORT}" 2>/dev/null)"
  [ -z "${STRUCT_VIOLATIONS}" ] && STRUCT_VIOLATIONS=0
  COVERAGE_PCT="$(jq_or_default '.coverage_pct' '0')"
  INTEGRITY_PASS="$(jq_or_default '.integrity.pass' 'true')"
else
  # gate crashed before it could write a report: still append a row.
  PASS="false"
  WALL_SECS=""
  TESTS_TOTAL=""
  TESTS_FAILED=""
  SUITE_LOAD_ERRORS=""
  ANALYZER_ERRORS=""
  ANALYZER_WARNINGS=""
  ANALYZER_INFOS=""
  SIZE_VIOLATIONS=""
  BASELINE_COUNT=""
  LARGEST_FILE=""
  P90_FILE=""
  STRUCT_VIOLATIONS=""
  COVERAGE_PCT=""
  INTEGRITY_PASS="false"
fi

# If the workflow reports the gate step as a hard failure (e.g. non-zero exit
# not reflected in the JSON pass field, or JSON missing), trust GATE_OUTCOME
# as an override for `pass` only when the report itself is missing.
if [ ! -f "${GATE_REPORT}" ] && [ "${GATE_OUTCOME:-}" = "failure" ]; then
  PASS="false"
fi

# ---------------------------------------------------------------------------
# Git-derived diff stats (files_changed, insertions, deletions)
# ---------------------------------------------------------------------------
FILES_CHANGED=0
INSERTIONS=0
DELETIONS=0
if (cd "${REPO_ROOT}" && git rev-parse --verify -q HEAD~1 >/dev/null 2>&1); then
  SHORTSTAT="$(cd "${REPO_ROOT}" && git diff --shortstat HEAD~1..HEAD 2>/dev/null || true)"
  if [ -n "${SHORTSTAT}" ]; then
    FILES_CHANGED="$(echo "${SHORTSTAT}" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo 0)"
    INSERTIONS="$(echo "${SHORTSTAT}" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)"
    DELETIONS="$(echo "${SHORTSTAT}" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)"
  fi
fi
[ -z "${FILES_CHANGED}" ] && FILES_CHANGED=0
[ -z "${INSERTIONS}" ] && INSERTIONS=0
[ -z "${DELETIONS}" ] && DELETIONS=0

ROW="1,${TS},${SHA},${BRANCH},${RUN_ID},${PASS},${INTEGRITY_PASS},${TESTS_TOTAL},${TESTS_FAILED},${SUITE_LOAD_ERRORS},${COVERAGE_PCT},${ANALYZER_ERRORS},${ANALYZER_WARNINGS},${ANALYZER_INFOS},${SIZE_VIOLATIONS},${BASELINE_COUNT},${LARGEST_FILE},${P90_FILE},${STRUCT_VIOLATIONS},${WALL_SECS},${FILES_CHANGED},${INSERTIONS},${DELETIONS}"

# ---------------------------------------------------------------------------
# Dashboard generation (shared by dry-run and real run)
# ---------------------------------------------------------------------------
csv_field() {
  # csv_field <line> <1-based-index>
  echo "$1" | cut -d',' -f"$2"
}

render_current_run_table() {
  local row="$1"
  cat <<EOF
## Current run

| field | value |
| :-- | :-- |
| sha | $(csv_field "$row" 3) |
| branch | $(csv_field "$row" 4) |
| run_id | $(csv_field "$row" 5) |
| pass | $(csv_field "$row" 6) |
| integrity_pass | $(csv_field "$row" 7) |
| tests_total | $(csv_field "$row" 8) |
| tests_failed | $(csv_field "$row" 9) |
| suite_load_errors | $(csv_field "$row" 10) |
| coverage_pct | $(csv_field "$row" 11) |
| analyzer_errors | $(csv_field "$row" 12) |
| analyzer_warnings | $(csv_field "$row" 13) |
| analyzer_infos | $(csv_field "$row" 14) |
| size_violations | $(csv_field "$row" 15) |
| baseline_count | $(csv_field "$row" 16) |
| largest_file | $(csv_field "$row" 17) |
| p90_file | $(csv_field "$row" 18) |
| struct_violations | $(csv_field "$row" 19) |
| wall_secs | $(csv_field "$row" 20) |
| files_changed | $(csv_field "$row" 21) |
| insertions | $(csv_field "$row" 22) |
| deletions | $(csv_field "$row" 23) |
EOF
}

render_last_30_table() {
  local csv_file="$1"
  echo "## Last 30 runs"
  echo
  echo "| ts | sha | pass | tests_total | tests_failed | coverage_pct | largest_file | p90_file | wall_secs |"
  echo "| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |"
  tail -n +2 "${csv_file}" | tail -n 30 | tac | while IFS=',' read -r schema ts sha branch run_id pass integrity_pass tests_total tests_failed suite_load_errors coverage_pct analyzer_errors analyzer_warnings analyzer_infos size_violations baseline_count largest_file p90_file struct_violations wall_secs files_changed insertions deletions; do
    echo "| ${ts} | ${sha} | ${pass} | ${tests_total} | ${tests_failed} | ${coverage_pct} | ${largest_file} | ${p90_file} | ${wall_secs} |"
  done
}

median() {
  # median <numbers...> -> prints median (numeric). Blank/empty args are
  # dropped first, so this is safe to call with an empty or blank-padded array.
  local input=("$@")
  local vals=()
  local v
  for v in "${input[@]:-}"; do
    [ -n "${v}" ] && vals+=("${v}")
  done
  local n="${#vals[@]}"
  if [ "$n" -eq 0 ]; then
    echo ""
    return
  fi
  local sorted=()
  while IFS= read -r line; do
    sorted+=("${line}")
  done < <(printf '%s\n' "${vals[@]}" | sort -n)
  local mid=$((n / 2))
  if [ $((n % 2)) -eq 1 ]; then
    echo "${sorted[$mid]}"
  else
    awk -v a="${sorted[$((mid - 1))]}" -v b="${sorted[$mid]}" 'BEGIN { printf "%.1f", (a + b) / 2 }'
  fi
}

render_weekly_table() {
  local csv_file="$1"
  echo "## Per-week aggregates (full history)"
  echo
  echo "| week | runs | red_run_ratio | median tests_total | median coverage_pct | median p90_file | median wall_secs |"
  echo "| :-- | :-- | :-- | :-- | :-- | :-- | :-- |"

  # Collect distinct ISO weeks (ts -> YYYY-Www), sorted ascending.
  local weeks
  weeks="$(tail -n +2 "${csv_file}" | awk -F',' '{print $2}' | while read -r ts; do
    [ -z "${ts}" ] && continue
    date -u -d "${ts}" +%G-W%V 2>/dev/null
  done | sort -u)"

  while read -r wk; do
    [ -z "${wk}" ] && continue
    local runs=0
    local reds=0
    local tests_vals=()
    local cov_vals=()
    local p90_vals=()
    local wall_vals=()

    while IFS=',' read -r schema ts sha branch run_id pass integrity_pass tests_total tests_failed suite_load_errors coverage_pct analyzer_errors analyzer_warnings analyzer_infos size_violations baseline_count largest_file p90_file struct_violations wall_secs files_changed insertions deletions; do
      [ -z "${ts}" ] && continue
      local row_wk
      row_wk="$(date -u -d "${ts}" +%G-W%V 2>/dev/null)"
      [ "${row_wk}" != "${wk}" ] && continue
      runs=$((runs + 1))
      if [ "${pass}" != "true" ]; then
        reds=$((reds + 1))
      fi
      [[ "${tests_total}" =~ ^[0-9]+$ ]] && tests_vals+=("${tests_total}")
      [[ "${coverage_pct}" =~ ^[0-9.]+$ ]] && cov_vals+=("${coverage_pct}")
      [[ "${p90_file}" =~ ^[0-9]+$ ]] && p90_vals+=("${p90_file}")
      [[ "${wall_secs}" =~ ^[0-9]+$ ]] && wall_vals+=("${wall_secs}")
    done < <(tail -n +2 "${csv_file}")

    local ratio="0.00"
    if [ "${runs}" -gt 0 ]; then
      ratio="$(awk -v r="${reds}" -v n="${runs}" 'BEGIN { printf "%.2f", r / n }')"
    fi

    echo "| ${wk} | ${runs} | ${ratio} | $(median "${tests_vals[@]:-}") | $(median "${cov_vals[@]:-}") | $(median "${p90_vals[@]:-}") | $(median "${wall_vals[@]:-}") |"
  done <<< "${weeks}"
}

generate_dashboard() {
  local csv_file="$1"
  {
    echo "# CI Metrics Dashboard"
    echo
    echo "_Regenerated automatically by tool/append_metrics.sh — do not edit by hand._"
    echo
    render_current_run_table "${ROW}"
    echo
    render_last_30_table "${csv_file}"
    echo
    render_weekly_table "${csv_file}"
  }
}

# ---------------------------------------------------------------------------
# Dry run: print row + dashboard, exit before any branch/network operation.
# ---------------------------------------------------------------------------
if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "=== CSV header ==="
  echo "${CSV_HEADER}"
  echo "=== CSV row (would be appended) ==="
  echo "${ROW}"
  echo "=== DASHBOARD.md (would be regenerated, using only this row as history) ==="
  TMP_CSV="$(mktemp)"
  {
    echo "${CSV_HEADER}"
    echo "${ROW}"
  } > "${TMP_CSV}"
  generate_dashboard "${TMP_CSV}"
  rm -f "${TMP_CSV}"
  exit 0
fi

# ---------------------------------------------------------------------------
# Real run: work in a temp dir, never disturb the main checkout.
# ---------------------------------------------------------------------------
ORIGIN_URL="$(cd "${REPO_ROOT}" && git config --get remote.origin.url)"
OWNER_REPO="$(echo "${ORIGIN_URL}" | sed -E 's#^(git@github.com:|https://github.com/)##; s#\.git$##')"
if [ -z "${OWNER_REPO}" ]; then
  echo "append_metrics: could not derive OWNER/REPO from remote.origin.url=${ORIGIN_URL}" >&2
  exit 1
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "append_metrics: GH_TOKEN is required in CI" >&2
  exit 1
fi

AUTH_URL="https://x-access-token:${GH_TOKEN}@github.com/${OWNER_REPO}.git"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

METRICS_DIR="${WORKDIR}/ci-metrics"

if (cd "${REPO_ROOT}" && git ls-remote --exit-code --heads "${AUTH_URL}" ci-metrics >/dev/null 2>&1); then
  git clone --quiet --branch ci-metrics --single-branch "${AUTH_URL}" "${METRICS_DIR}"
else
  git clone --quiet "${AUTH_URL}" "${METRICS_DIR}"
  (
    cd "${METRICS_DIR}"
    git checkout --orphan ci-metrics
    git rm -rf . >/dev/null 2>&1 || true
    echo "${CSV_HEADER}" > history.csv
    git add history.csv
    git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
      commit -m "metrics: initialize history.csv" >/dev/null
  )
fi

cd "${METRICS_DIR}"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

if [ ! -f history.csv ]; then
  echo "${CSV_HEADER}" > history.csv
  git add history.csv
fi

# Integrity check: last existing line must have same comma count as header.
HEADER_COMMAS="$(grep -o ',' <<< "${CSV_HEADER}" | wc -l)"
LAST_LINE="$(tail -n 1 history.csv)"
if [ -n "${LAST_LINE}" ] && [ "${LAST_LINE}" != "${CSV_HEADER}" ]; then
  LAST_COMMAS="$(grep -o ',' <<< "${LAST_LINE}" | wc -l)"
  if [ "${LAST_COMMAS}" != "${HEADER_COMMAS}" ]; then
    echo "append_metrics: INTEGRITY FAILURE — last line of history.csv has ${LAST_COMMAS} commas, expected ${HEADER_COMMAS}" >&2
    echo "offending line: ${LAST_LINE}" >&2
    exit 1
  fi
fi

echo "${ROW}" >> history.csv
generate_dashboard history.csv > DASHBOARD.md

git add history.csv DASHBOARD.md

COMMIT_PASS_WORD="fail"
if [ "${PASS}" = "true" ]; then
  COMMIT_PASS_WORD="pass"
fi

git commit -m "metrics: ${SHA} ${COMMIT_PASS_WORD}" >/dev/null

push_once() {
  git push "${AUTH_URL}" HEAD:ci-metrics
}

if push_once; then
  echo "append_metrics: pushed row for ${SHA} (${COMMIT_PASS_WORD})"
  exit 0
fi

echo "append_metrics: push rejected, retrying once with pull --rebase" >&2
if git pull --rebase "${AUTH_URL}" ci-metrics && push_once; then
  echo "append_metrics: pushed row for ${SHA} (${COMMIT_PASS_WORD}) after rebase"
  exit 0
fi

echo "append_metrics: push failed after retry — giving up loudly" >&2
exit 1
