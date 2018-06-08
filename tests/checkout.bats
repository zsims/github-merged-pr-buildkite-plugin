#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

git() {
  [[ "$1" == "fetch" ]] && echo "GIT_FETCHED"
  [[ "$1" == "checkout" && "$2" == "FETCH_HEAD" ]] && echo "GIT_CHECKED_OUT_FETCH_HEAD"
  [[ "$1" == "checkout" && "$2" != "FETCH_HEAD" ]] && echo "GIT_CHECKED_OUT_OTHER"
  return 0
}

checkout_hook="$PWD/hooks/checkout"

@test "Fetches PR merge ref if PR number set" {
  export -f git
  export BUILDKITE_PULL_REQUEST=123

  run "$checkout_hook"

  assert_success
  assert_output --partial "GIT_FETCHED"
  assert_output --partial "GIT_CHECKED_OUT_FETCH_HEAD"
  assert_output --partial "Checking out merge ref"
}

@test "Checks out branch if no PR number set" {
  export -f git
  export BUILDKITE_PULL_REQUEST=""
  export BUILDKITE_BRANCH="my-branch"

  run "$checkout_hook"

  assert_success
  refute_output --partial "GIT_FETCHED"
  refute_output --partial "GIT_CHECKED_OUT_FETCH_HEAD"
  assert_output --partial "GIT_CHECKED_OUT_OTHER"
  assert_output --partial "No BUILDKITE_PULL_REQUEST variable set"
}

@test "Checks out branch if PR variable is false" {
  export -f git
  export BUILDKITE_PULL_REQUEST="false"
  export BUILDKITE_BRANCH="my-branch"

  run "$checkout_hook"

  assert_success
  refute_output --partial "GIT_FETCHED"
  refute_output --partial "GIT_CHECKED_OUT_FETCH_HEAD"
  assert_output --partial "GIT_CHECKED_OUT_OTHER"
  assert_output --partial "No BUILDKITE_PULL_REQUEST variable set"
}