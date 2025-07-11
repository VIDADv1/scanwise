#!/bin/bash
export SONAR_INSTANCE_PORT=${SONAR_INSTANCE_PORT:-"9234"}
export SONAR_PROJECT_NAME="${SONAR_PROJECT_NAME:-$(basename "$(pwd)")}"

function create_pr_issues_report_json() {
  local issues_filename="$1"
  local commit_data_filename="$2"

  # Check if the file exists
  if [[ ! -f "$commit_data_filename" ]]; then
      echo "Error: File '$commit_data_filename' not found!"
      exit 1
  fi

  echo "[" > "$issues_filename"
  while read -r CREATED_AT AUTHOR_EMAIL; do
    # Format the date and URL encode the '+' in one line (only for timezone)
    FORMATTED_CREATED_AT=$(date -d "$CREATED_AT" +"%Y-%m-%dT%H:%M:%S%z")
    ENCODED_CREATED_AT=${FORMATTED_CREATED_AT//+/%2B}

    # URL encode only special characters in the email address (e.g. @, ., +)
    ENCODED_EMAIL=${AUTHOR_EMAIL//+/%2B}

    # Call your function to fetch and append issues
    fetch_and_append_issues "$issues_filename" "&createdAt=$ENCODED_CREATED_AT&author=$ENCODED_EMAIL"
  done < "$commit_data_filename"
  echo "]" >> "$issues_filename"
}

function create_n_days_issues_report_json() {
  local issues_filename="$1"
  local n_days="$2"

  echo "[" > "$issues_filename"
  fetch_and_append_issues "$issues_filename" "&createdInLast=$n_days"
  echo "]" >> "$issues_filename"
}

function create_overall_issues_report_json() {
  local issues_filename="$1"

  echo "[" > "$issues_filename"
  fetch_and_append_issues "$issues_filename"
  echo "]" >> "$issues_filename"
}

function fetch_and_append_issues() {
  local issues_filename="$1"
  local additionnal_scanwise_api_parameters="$2"

  # Initialize page counter
  local PAGE=1
  while :
  do
    # Include the additionnal_scanwise_api_parameters in the URL
    RESPONSE=$(curl -s -u "admin:Son@rless123" \
      "http://localhost:${SONAR_INSTANCE_PORT}/api/issues/search?componentKeys=${SONAR_PROJECT_NAME}&ps=500&p=$PAGE&s=SEVERITY&asc=false$additionnal_scanwise_api_parameters")

    # Loop through each issue in the response
    echo "$RESPONSE" | jq -c '.issues[]?' | while IFS= read -r issue; do
      if grep -m1 '[^[]' "$issues_filename" >/dev/null; then
        echo "," >> "$issues_filename"
      fi
      echo "$issue" >> "$issues_filename"
    done

    # Check if there are more pages to fetch
    total=$(echo "$RESPONSE" | jq -r '.paging.total')
    
    # Make sure we have a valid numeric value
    if [[ ! "$total" =~ ^[0-9]+$ ]]; then
      # If total is not a valid number (null, empty, or non-numeric), exit the loop
      break
    fi
    
    # If we've fetched all pages, exit the loop
    if [ "$total" -le $(("$PAGE" * 500)) ]; then
      break
    fi

    # Increment page counter for the next request
    PAGE=$(("$PAGE" + 1))
  done
}

function create_pr_hotspots_report_json() {
  local input_hotspots_filename="$1"
  local output_report_filename="$2"
  local commit_data_filename="$3"

  echo "[" > "$output_report_filename"
  while read -r CREATED_AT AUTHOR_EMAIL; do
    FORMATTED_CREATED_AT=$(date -d "$CREATED_AT" +"%Y-%m-%dT%H:%M:%S%z")
    matching_entries=$(jq "[.[] | select(.author == \"$AUTHOR_EMAIL\" and .creationDate == \"$FORMATTED_CREATED_AT\")]" "$input_hotspots_filename")
    echo "${matching_entries:-[]}" | jq -r 'if length==0 then empty else map(@json) | join(",") end' >> "$output_report_filename"
  done < "$commit_data_filename"
  echo "]" >> "$output_report_filename"
}

function create_n_days_hotspots_report_json() {
  local input_hotspots_filename="$1"
  local output_report_filename="$2"
  local n_days="$3"
  local n_days_num=${n_days%d}

  cutoff_date=$(date -d "$n_days_num days ago" +"%Y-%m-%dT%H:%M:%S%z")
  echo "Cutoff date: $cutoff_date"
  {
    echo "[";
    matching_entries=$(jq "[.[] | select(.creationDate >= \"$cutoff_date\")]" "$input_hotspots_filename");
    echo "${matching_entries:-[]}" | jq -r 'if length==0 then empty else map(@json) | join(",") end';
    echo "]";
  } > "$output_report_filename"
}

function create_overall_hotspots_report_json() {
  local hotspots_filename="$1"

  echo "[" > "$hotspots_filename"
  fetch_and_append_hotspots "$hotspots_filename"
  echo "]" >> "$hotspots_filename"
}

function fetch_and_append_hotspots() {
  local hotspots_filename="$1"

  # Initialize page counter
  local PAGE=1
  while :
    do
      RESPONSE=$(curl -s -u "admin:Son@rless123" \
        "http://localhost:${SONAR_INSTANCE_PORT}/api/hotspots/search?projectKey=${SONAR_PROJECT_NAME}&ps=500&p=$PAGE")

      # Loop through each hotspot in the response
      echo "$RESPONSE" | jq -c '.hotspots[]?' | while IFS= read -r hotspot; do
        if grep -m1 '[^[]' "$hotspots_filename" >/dev/null; then
          echo "," >> "$hotspots_filename"
        fi
        echo "$hotspot" >> "$hotspots_filename"
      done

      # Check if there are more pages to fetch
      total=$(echo "$RESPONSE" | jq -r '.paging.total')
      
      # Make sure we have a valid numeric value
      if [[ ! "$total" =~ ^[0-9]+$ ]]; then
        # If total is not a valid number (null, empty, or non-numeric), exit the loop
        break
      fi
      
      # If we've fetched all pages, exit the loop
      if [ "$total" -le $(("$PAGE" * 500)) ]; then
        break
      fi
      PAGE=$(("$PAGE" + 1))
  done
}

"$@"
