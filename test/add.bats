#!/usr/bin/env bats

readonly gsapp="$BATS_TEST_DIRNAME/../gsapp"
readonly GSAPP_PATH="$BATS_TMPDIR/applications"

setup() {
  export GSAPP_PATH
  mkdir -p -- "$GSAPP_PATH"
}

teardown() {
  rm -rf -- "$GSAPP_PATH"
}

@test "gsapp add: exit non-zero if arguments is not enough" {
  local name='test0'
  run "$gsapp" add "$name"
  [[ $status != 0 ]]
  [[ ! -e "$GSAPP_PATH/$name.desktop" ]]
}

@test "gsapp add: exit non-zero if \$GSAPP_PATH doesn't exist" {
  local name='test0'
  rm -rf -- "$GSAPP_PATH"
  run "$gsapp" add "$name"
  [[ $status != 0 ]]
  [[ ! -e "$GSAPP_PATH/$name.desktop" ]]
}

@test "gsapp add: exit non-zero if .desktop file has already exist" {
  local name='test0'
  local execute='echo'
  touch "$GSAPP_PATH/$name.desktop"
  run "$gsapp" add "$name" "$execute"
  [[ $status != 0 ]]
  [[ -e "$GSAPP_PATH/$name.desktop" ]]
  [[ -z "$(cat "$GSAPP_PATH/$name.desktop")" ]]
}

@test "gsapp add: add .desktop file" {
  local name='test000'
  local execute='echo Hello'
  run "$gsapp" add "$name" "$execute"
  [[ $status == 0 ]]
  [[ -e "$GSAPP_PATH/$name.desktop" ]]
}

@test "gsapp add: add .desktop file which name is empty" {
  local name=''
  local execute='echo'
  run "$gsapp" add "$name" "$execute"
  [[ $status == 0 ]]
  [[ -e "$GSAPP_PATH/.desktop" ]]
}

@test "gsapp add: Use \$1 as Name, and use \${*:2} as Exec" {
  local name='test0'
  local execute='echo'
  local args=('foo' 'bar  baz')
  run "$gsapp" add "$name" "$execute" "${args[@]}"
  [[ $status == 0 ]]
  [[ -e "$GSAPP_PATH/$name.desktop" ]]

  run cat "$GSAPP_PATH/$name.desktop"
  [[ $status == 0 ]]
  [[ ${lines[0]} == '[Desktop Entry]' ]]
  [[ ${lines[1]} == "Name=$name" ]]
  [[ ${lines[2]} == "Exec=$execute ${args[*]}" ]]
  [[ ${lines[3]} == 'Type=Application' ]]
}
