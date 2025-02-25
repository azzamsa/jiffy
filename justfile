#!/usr/bin/env -S just --justfile

alias d := dev
alias f := fmt
alias l := lint
alias t := test
alias c := comply
alias k := check

[doc('List available commands')]
_default:
    just --list --unsorted

[confirm('⚠️ This command will alter your system. Run recipe `setup`?')]
[doc('Setup the repository')]
setup:
    cargo binstall 'cargo-edit cargo-nextest cargo-outdated dprint git-cliff bacon typos-cli'

[doc('Tasks to make the code-base comply with the rules. Mostly used in git hooks')]
comply: doc-check fmt lint test

[doc('Check if the repository comply with the rules and ready to be pushed')]
check: doc-check fmt-check lint test

[doc('Develop the app')]
dev:
    bacon

[doc('Format the codebase.')]
fmt:
    cargo fmt --all
    dprint fmt

[doc('Check is the codebase properly formatted')]
fmt-check:
    cargo fmt --all -- --check
    dprint check

[doc('Lint the codebase')]
lint:
    cargo clippy --all-targets --all-features
    typos

[doc('Test the codebase')]
test:
    cargo nextest run --all-targets --all-features

[doc('Create a new release. Example `cargo-release release minor --tag-name v0.2.0`')]
release level:
    cargo-release release {{ level }} --execute

[doc('Make sure the repo is ready for release')]
release-check level: check
    just up
    cargo-release release {{ level }}

[doc('Check the documentation')]
doc-check:
    cargo doc --all-features --no-deps
    cargo test --doc

[doc('Prepare release hooks')]
_release-prepare version:
    git-cliff --config .cliff.toml --output CHANGELOG.md --tag {{ version }}
    just fmt

[doc('Check dependencies health. Pass `--write` to upgrade dependencies')]
[unix]
up arg="":
    #!/usr/bin/env bash
    if [ "{{ arg }}" = "--write" ]; then
        cargo upgrade
        cargo update
    else
        cargo outdated --root-deps-only
    fi;
