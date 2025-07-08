#!/bin/bash
export SONAR_PROJECT_NAME="${SONAR_PROJECT_NAME:-$(basename "$(pwd)")}"
export SONAR_GITROOT=${SONAR_GITROOT:-"$(pwd)"}
export SONAR_METRICS_PATH=${SONAR_METRICS_PATH:-"./sonar-metrics.json"}

function generate_issues_report_md() {
  local input_json_path="$1"
  local output_md_path="$2"

  {
    echo "### 🌟 **Sonarless overall Issues Details for $SONAR_PROJECT_NAME** 🌟"
    echo "| Type | Severity | File | Line | Effort | Author | Rule | Message |"
    echo "|------|----------|------|------|--------|--------|------|---------|"
    jq -r '
      .[] |
      "| \(.type) | \(.severity) | \(.component | split(":")[1] | gsub("_"; "\\_")) | \(.line // "-") | " +
      "\(.effort) | \(.author | gsub("_"; "\\_")) | \(.rule) | " +
      (.message
        | gsub("\\|"; "\\|")
        | gsub("\\*"; "\\*")
        | gsub("_"; "\\_")
        | gsub("`"; "\\`")
        | gsub("\\["; "\\[")
        | gsub("\\]"; "\\]")
        | gsub("<"; "\\<")
        | gsub(">"; "\\>")
      ) + " |"
    ' "${input_json_path}"
  } > "${output_md_path}"
}

function generate_hotspots_report_md() {
  local input_json_path="$1"
  local output_md_path="$2"
  
  {
    echo "### 🌟 **Sonarless overall security hotspots to review for $SONAR_PROJECT_NAME** 🌟";
    echo "| Category | Vuln. Probability | File | Line | Author | Rule | Message |";
    echo "|----------|-------------------|------|------|--------|------|---------|";
    jq -r '
      .[] |
      "| \(.securityCategory) | \(.vulnerabilityProbability) | \(.component | split(":")[1] | gsub("_"; "\\_")) | \(.line // "-") | \(.author | gsub("_"; "\\_")) | \(.ruleKey) | " +
      (.message
        | gsub("\\|"; "\\|")
        | gsub("\\*"; "\\*")
        | gsub("_"; "\\_")
        | gsub("`"; "\\`")
        | gsub("\\["; "\\[")
        | gsub("\\]"; "\\]")
        | gsub("<"; "\\<")
        | gsub(">"; "\\>")
      ) + " |"
    ' "${input_json_path}";
  } > "${output_md_path}"
}

function generate_sonar_analysis_summary_md() {
  local mode="$1"
  local new_issues_reports_link="$2"
  local overall_issues_reports_link="$3"

  if [ "$mode" == "PR" ]; then
    # Extract metrics for PR
    local pr_code_smells=$(jq '[.[] | select(.type == "CODE_SMELL")] | length' reports/pr/issues-report.json)
    local pr_bugs=$(jq '[.[] | select(.type == "BUG")] | length' reports/pr/issues-report.json)
    local pr_vulnerabilities=$(jq '[.[] | select(.type == "VULNERABILITY")] | length' reports/pr/issues-report.json)
    local pr_security_hotspots=$(jq 'length' reports/pr/hotspots-report.json)
  fi

  # Load Sonarless JSON Metrics Report
  local json_content=$(cat "${SONAR_GITROOT}/${SONAR_METRICS_PATH}")

  # Extract Metrics for Overall Code
  local name=$(echo "$json_content" | jq -r '.component.name')
  local ncloc=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "ncloc") | .value')
  local code_smells=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "code_smells") | .value')
  local bugs=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "bugs") | .value')
  local vulnerabilities=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "vulnerabilities") | .value')
  local security_hotspots=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "security_hotspots") | .value')
  local sqale_rating=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "sqale_rating") | .value')
  local reliability_rating=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "reliability_rating") | .value')
  local security_rating=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "security_rating") | .value')
  local coverage=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "coverage") | .value')
  local coverage_percentage=$(awk "BEGIN { c = $coverage + 0; printf \"%.2f\", c * 100 }")
  local duplicated_lines_density=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "duplicated_lines_density") | .value')
  local quality_gate_status=$(echo "$json_content" | jq -r '.component.measures[] | select(.metric == "quality_gate_details") | .value | fromjson | .level')

  # Helper function to generate stars
  generate_stars() {
    local rating=$1
    # Round rating to nearest integer if it's a float
    local rounded_rating=$(printf "%.0f" "$rating")

    # Build full stars (★) and empty stars (☆)
    local full_stars=$(printf '★%.0s' $(seq 1 $((6 - rounded_rating))))
    local empty_stars=$(printf '☆%.0s' $(seq 1  $((rounded_rating - 1))))

    if [[ $((6 - rounded_rating)) -eq 5 ]]; then
      echo "$full_stars"
    else
      echo "$full_stars$empty_stars"
    fi
  }

  # Generate Ratings
  local sqale_stars=$(generate_stars "$sqale_rating")
  local reliability_stars=$(generate_stars "$reliability_rating")
  local security_stars=$(generate_stars "$security_rating")

  # Build the summary
  local summary="# 🌟 **Sonarless Analysis Summary for $name** 🌟\n\n"

  if [ "$mode" == "PR" ]; then
    summary="$summary## 🆕 **New code statistics (PR)** 🆕\n\n"

    summary="$summary### Key values\n"
    summary="$summary- **💡 Code Smells:** $pr_code_smells\n"
    summary="$summary- **🐞 Bugs:** $pr_bugs\n"
    summary="$summary- **🔒 Vulnerabilities:** $pr_vulnerabilities\n"
    summary="$summary- **🔥 Security Hotspots:** $pr_security_hotspots\n\n"

    if [ "$new_issues_reports_link" != "" ]; then
      summary="$summary### Issues and Security Hotspots Reports\n"
      summary="${summary}[Click here to download the reports](${new_issues_reports_link})\n\n"
    fi
  fi

  summary="$summary## 🔁 Overall statistics 🔁\n\n"
  summary="$summary### Key values\n"
  summary="$summary- **📊 Lines of Code (LoC):** $ncloc\n"
  summary="$summary- **💡 Code Smells:** $code_smells\n"
  summary="$summary- **🐞 Bugs:** $bugs\n"
  summary="$summary- **🔒 Vulnerabilities:** $vulnerabilities\n"
  summary="$summary- **🔥 Security Hotspots:** $security_hotspots\n\n"

  summary="$summary### Ratings\n"
  summary="$summary- **💎 Maintainability:** $sqale_stars\n"
  summary="$summary- **⚙️ Reliability:** $reliability_stars\n"
  summary="$summary- **🔐 Security:** $security_stars\n"
  summary="$summary- **🛡 Test Coverage:** **$coverage_percentage %**\n"
  summary="$summary- **🌀 Duplicated Lines Density:** $duplicated_lines_density%\n\n"

  summary="$summary### Quality Gate\n"
  summary="$summary- **Status:** $(if [ "$quality_gate_status" = "OK" ]; then echo "✅ **PASSED**"; else echo "❌ **FAILED**"; fi)\n\n"

  if [ "$overall_issues_reports_link" == "" ]; then
    summary="$summary### Issues and Security Hotspots Reports\n"
    summary="${summary}[Click here to download the reports](${overall_issues_reports_link})"
  fi

  printf "%b" "$summary"
}

"$@"
