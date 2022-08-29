#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

export BUILDKITE_REPO="test-org/test-repo"
export BUILDKITE_COMMIT="12345"

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "builds an image with basic parameters set" {
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker 'build --tag foo/bar:baz -f Dockerfile . : echo basic parameters set'

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with multiple tags set" {
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz1"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_1="foo/bar:baz2"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_2="foo/bar:baz3"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0 --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_1 --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_2 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with a label set" {
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz1"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_0="label1=value1"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0 --label $BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_0 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with multiple labels set" {
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz1"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_0="label1=value1"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_1="label2=value2"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_2="label3=value3"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0 --label $BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_0 --label $BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_1 --label $BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_2 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with a custom Dockerfile" {
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_DOCKERFILE="foo/Dockerfile"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0 -f $BUILDKITE_PLUGIN_DOCKER_BUILD_DOCKERFILE . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with a context path" {
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_CONTEXT="my/custom/path"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0 -f Dockerfile $BUILDKITE_PLUGIN_DOCKER_BUILD_DOCKERFILE : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with one tag set from docker-metadata file" {
  export DOCKER_METADATA_DIR="$(mktemp -d)"
  touch "$DOCKER_METADATA_DIR/tags"
  _TAGS_0="foo/bar:baz"
  echo "$_TAGS_0" >> "$DOCKER_METADATA_DIR/tags"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $_TAGS_0 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker

  rm -rf "$DOCKER_METADATA_DIR"
}

@test "builds an image with multiple tags set from docker-metadata file" {
  export DOCKER_METADATA_DIR="$(mktemp -d)"
  touch "$DOCKER_METADATA_DIR/tags"
  _TAGS_0="foo/bar:baz1"
  echo "$_TAGS_0" >> "$DOCKER_METADATA_DIR/tags"
  _TAGS_1="foo/bar:baz2"
  echo "$_TAGS_1" >> "$DOCKER_METADATA_DIR/tags"
  _TAGS_2="foo/bar:baz3"
  echo "$_TAGS_2" >> "$DOCKER_METADATA_DIR/tags"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $_TAGS_0 --tag $_TAGS_1 --tag $_TAGS_2 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker

  rm -rf "$DOCKER_METADATA_DIR"
}

@test "builds an image with a label set from docker-metadata file" {
  export DOCKER_METADATA_DIR="$(mktemp -d)"
  touch "$DOCKER_METADATA_DIR/tags"
  _TAGS_0="foo/bar:baz1"
  echo "$_TAGS_0" >> "$DOCKER_METADATA_DIR/tags"

  touch "$DOCKER_METADATA_DIR/labels"
  _LABELS_0="label1=value1"
  echo "$_LABELS_0" >> "$DOCKER_METADATA_DIR/labels"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $_TAGS_0 --label $_LABELS_0 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with multiple labels set from docker-metadata file" {
  export DOCKER_METADATA_DIR="$(mktemp -d)"
  touch "$DOCKER_METADATA_DIR/tags"
  _TAGS_0="foo/bar:baz1"
  echo "$_TAGS_0" >> "$DOCKER_METADATA_DIR/tags"

  touch "$DOCKER_METADATA_DIR/labels"
  _LABELS_0="label1=value1"
  echo "$_LABELS_0" >> "$DOCKER_METADATA_DIR/labels"
  _LABELS_1="label2=value2"
  echo "$_LABELS_1" >> "$DOCKER_METADATA_DIR/labels"
  _LABELS_2="label3=value3"
  echo "$_LABELS_2" >> "$DOCKER_METADATA_DIR/labels"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $_TAGS_0 --label $_LABELS_0 --label $_LABELS_1 --label $_LABELS_2 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "builds an image with tags and labels set from environment and docker-metadata file" {
  export DOCKER_METADATA_DIR="$(mktemp -d)"
  touch "$DOCKER_METADATA_DIR/tags"
  _TAGS_0="foo/bar:baz1"
  echo "$_TAGS_0" >> "$DOCKER_METADATA_DIR/tags"
  _TAGS_1="foo/bar:baz2"
  echo "$_TAGS_1" >> "$DOCKER_METADATA_DIR/tags"
  _TAGS_2="foo/bar:baz3"
  echo "$_TAGS_2" >> "$DOCKER_METADATA_DIR/tags"

  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0="foo/bar:baz4"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_1="foo/bar:baz4"

  touch "$DOCKER_METADATA_DIR/labels"
  _LABELS_0="label1=value1"
  echo "$_LABELS_0" >> "$DOCKER_METADATA_DIR/labels"
  _LABELS_1="label2=value2"
  echo "$_LABELS_1" >> "$DOCKER_METADATA_DIR/labels"
  _LABELS_2="label3=value3"
  echo "$_LABELS_2" >> "$DOCKER_METADATA_DIR/labels"

  export BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_0="label4=value4"
  export BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_1="label5=value5"

  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style success "Docker build succeeded<br />" --context publish --append : echo pushed buildkite agent message'
  stub docker "build --tag $_TAGS_0 --tag $_TAGS_1 --tag $_TAGS_2 --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_0 --tag $BUILDKITE_PLUGIN_DOCKER_BUILD_TAGS_1 --label $_LABELS_0 --label $_LABELS_1 --label $_LABELS_2 --label $BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_0 --label $BUILDKITE_PLUGIN_DOCKER_BUILD_LABELS_1 -f Dockerfile . : echo basic parameters set"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "basic parameters set"
  assert_output --partial "Docker build succeeded"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
  unstub docker
}

@test "no docker in environment" {
  stub which 'docker : return 1'
  stub buildkite-agent 'annotate --style error "Docker is not installed. Please install it first.<br />" --context publish --append : echo pushed buildkite agent message'

  run "$PWD/hooks/post-command"

  assert_failure
  assert_output --partial "Docker is not installed"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
}

@test "no tags were found" {
  stub which 'docker : echo /usr/bin/docker'
  stub buildkite-agent 'annotate --style error "No tags were given either as a parameter or via the docker-metadata-buildkite-plugin<br />" --context publish --append : echo pushed buildkite agent message'

  run "$PWD/hooks/post-command"

  assert_failure
  assert_output --partial "No tags were given either as a parameter or via the docker-metadata-buildkite-plugin"
  assert_output --partial "pushed buildkite agent message"

  unstub which
  unstub buildkite-agent
}