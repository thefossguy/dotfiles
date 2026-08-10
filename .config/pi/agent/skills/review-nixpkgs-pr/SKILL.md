---
name: review-nixpkgs-pr
description: Use when asked to review a nixpkgs PR or audit a pull request against nixpkgs contribution guidelines. Requires a local nixpkgs checkout and a PR number.
---

# Review nixpkgs PR

This skill+document enumerates every review guideline a maintainer+reviewer must follow before approving a PR to the `github:nixos/nixpkgs` repository. Guidelines are sourced from the following files:

- `CONTRIBUTING.md`
- `pkgs/README.md`
- `nixos/README.md`
- `lib/README.md`
- `doc/README.md`
- `maintainers/README.md`

There obviously are more guidelines for a maintainer to follow (e.g., CI and status checks, merge bot constraints, AI and automation policy compliance, vulnerability triage, etc.), but those are out of the scope of **reviewing the contents of a PR.** Therefore, only be concerned with the guidelines outlined in this skill.

## How to use this skill

This skill **requires** a PR number as its first argument. Treat it as `$PR` throughout.

**Note**: The [`nixpkgs-review`](github.com:Mic92/nixpkgs-review) tool will be used independently from calling this skill. That tools builds all the package(s) that will be rebuilt because of the change(s) made in `$PR`. As a result, it also points out all evaluation error(s) (if any). Therefore, never point out any change(s) that might cause evaluation error(s) nor point out change(s) that might point out build error(s).

### Workflow

1. Use `gh pr view --repo nixos/nixpkgs $PR --json title,body,labels,baseRefName` to gather the necessary metadata for the PR.
2. Use `gh pr view --repo nixos/nixpkgs $PR --json labels --jq '.labels[].name'` to gather all labels assigned to the PR.
3. Use `gh pr diff --repo nixos/nixpkgs $PR` to get the changes introduced by the PR.
4. Determine the PR type (one of the following) and apply the corresponding guideline section(s) from below. If you cannot determine the PR type, inform the user of this and abort immediately.
  - package review
  - NixOS module review
  - lib review
  - documentation review
  - maintainer addition
5. Check that the target branch is appropriate per [Section 1: Branch targeting guidelines](#1-branch-targeting-guidelines).
6. Check commit messages per [Section 2: Commit message review](#2-commit-message-review).
7. Check code conventions per [Section 3: Code conventions review](#3-code-conventions-review).
8. Generate a review report (for **my** eyes only) using the template below.

### Review report template

```markdown
# PR Review: $PR_TITLE ($PR)

## Summary

One or two sentences describing what the PR does and your overall assessment of it.

## Guideline violations

Issues where the PR deviates from the nixpkgs contribution guidelines. Reference the relevant guideline section(s) so that the PR author(s) can look it up. An example with `pkgs/foo/default.nix` is provided as a template.

**`pkgs/foo/default.nix`, line 42**: Uses `${pkgs.ripgrep}/bin/rg` directly.
-> Use `lib.getExe pkgs.ripgrep` (`pkgs.ripgrep.meta.mainProgram` is set). [§3.2 Syntax conventions]

*(Omit section if none found.)*

## Suggestions

Non-blocking improvements like style, clarity, missed best practices, etc. that aren't strictly a violation of the nixpkgs contributor guidelines.

*(Omit section if none found.)*

## Typos

**`pkgs/foo/default`, line 54:** `"A powerfull tool"` -> `"A powerful tool"`

*(Omit section if none found.)*

## Positive notes

*(Omit if nothing worth calling out.)*

## Verdict

One of the following, with a one-line justification.
- **Approve**
- **Request changes**
- **Needs discussions**
```

## Table of contents

1. [Branch targeting guidelines](#1-branch-targeting-guidelines)
2. [Commit message review](#2-commit-message-review)
3. [Code conventions review](#3-code-conventions-review)
4. [Package review](#4-package-review)
5. [NixOS module review](#5-nixos-module-review)
6. [lib review](#6-lib-review)
7. [Documentation review](#7-documentation-review)
8. [Maintainer addition](#8-maintainer-addition)

## 1. Branch targeting guidelines

### 1.1. Choosing the correct target branch

- `master` for most changes.
- `release-YY.MM` for backports from `master`, with acceptable changes, only to supported stable releases.
- `staging` for mass rebuilds (**anything more than 500 rebuilds**).
- `staging-YY.MM` is the equivalent of `staging`, but for supported releases.
- `staging-nixos` for changes rebuilding all NixOS tests or Linux kernel changes.
- `staging-nixos-YY.MM` is the equivalent of `staging-nixos`, but for supported releases.
- `nixos-*` should **never** be targeted. Those are channel branches.

### 1.2. Mass rebuilds -> staging branches

- Per the labels assigned to the PR
  - If rebuilds are **500 or more**, consider targeting `staging` instead of `master`.
  - If rebuilds are **1000 or more**, the PR **must** target `staging`.
  - For PRs to `release-YY.MM` with mass rebuilds, target `staging-YY.MM`.
  - Linux kernel changes are an **exception**: they go to `staging-nixos`.

### 1.3. Changes rebuilding all NixOS tests

- Per the labels assigned to the PR
  - Changes with the `10.rebuild-nixos-tests` label, or changes affecting the Linux kernel, must target a `staging`-branch or `staging-nixos`-branch.

### 1.4. Changes acceptable for stable releases

- Only changes to **supported releases** may be accepted. The oldest supported release can be found via:
  ```bash
  nix-instantiate --eval -A lib.trivial.oldestSupportedRelease
  ```
- Release branches should generally only receive backwards-compatible changes.
- Acceptable for backport:
  - New packages, modules and functions.
  - Security fixes.
  - Patch versions with fixes.
  - Minor versions with new functionality but no breaking changes.
  - Major version updates with breaking changes for:
    - Services that would fail without up-to-date client software (e.g., `spotify`, `steam`, `discord`, etc.).
    - Security-critical applications (e.g., `firefox`, `chromium`, etc.).

### 1.5. Staging workflow

- Hydra builds should **not** be used as a testing platform.
- `staging-next` should only receive changes that fix Hydra builds. For anything else, ask in the [staging room](https://matrix.to/#/#staging:nixos.org).

## 2. Commit message review

### 2.1. General commit conventions

- One commit per logical unit.
  - Multiple unrelated changes should be split into separate commits.
- Squash trivial fixup commits (e.g., `oh, forgot to insert whitespace`).
- No trailing period in the commit message's summary line (first line).
- When adding oneself to `maintainer-list.nix`, make a separate commit with message `maintainers: add <handle>`, placed before commits making changes to the package or module.
- PRs targeting a stable branch must be formatted like so: `[YY.MM] <PR title>`

### 2.2. Package commit message format

```
(pkg-name): (from -> to | init at version | refactor | etc)

(Motivation for change. Link to release notes. Additional information.)
```

Examples:
- `nginx: init at 2.0.1`
- `firefox: 54.0.1 -> 55.0`


### 2.3. NixOS module commit message format

```
nixos/(module): (init module | add setting | refactor | etc)

(Motivation for change. Link to release notes. Additional information.)
```

Examples:
- `nixos/cosmic-greeter: init`
- `nixos/run0: switch to run0-sudo-shim`

### 2.4. lib commit message format

```
lib.(section): (init | add additional argument | refactor | etc)

(Motivation for change. Additional information.)
```

Examples:

- `lib.getExe': check arguments`
- `lib.generators.toGitINI: performance improvements`

### 2.5. Documentation commit message format

```
doc: (documentation summary)

(Motivation for change. Relevant links. Additional information.)
```

Examples:
- `doc: add buildFHSEnvChroot removal to release-notes`
- `doc: add meta.donationPage`

### 2.6. Writing good commit messages

- Include relevant information so others can understand **why** a change was made.
- Simple package version updates must include the following:
  - attribute name
  - old and new versions
  - reference to the release notes or the changelog
- Package upgrades with more extensive changes require more verbose commit messages.

## 3. Code conventions review

### 3.1. File naming and organization

- File and directory names must be lowercase with dashes between words (kebab-case, not camelCase).
  - Correct: `all-packages.nix`
  - Incorrect: `allPackages.nix`, `AllPackages.nix`

### 3.2. Syntax conventions

- Use `lowerCamelCase` for variable names (not `UpperCamelCase`). This rule does not apply to package attribute names.
- Functions should list expected arguments as precisely as possible:
  ```nix
  { stdenv, fetchurl, perl }:
  ```
  Instead of:
  ```nix
  args: with args; <...>
  ```
  or:
  ```nix
  { stdenv, fetchurl, perl, ... }:
  ```
- For truly generic functions with some required arguments, use an `@`-pattern:
  ```nix
  { stdenv, doCoverageAnalysis ? false, ... }@args:
  ```
- Avoid unnecessary string conversions:
  ```nix
  { tag = version; }         # correct
  { tag = "${version}"; }    # incorrect
  ```
- Build lists conditionally with `lib.optionals`
  ```nix
  { buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ iconv ]; }
  ```
  Instead of:
  ```nix
  { buildInputs = if stdenv.hostPlatform.isDarwin then [ iconv ] else null; }
  ```
- Use of `lib.optional` is forbidden:
  ```nix
  { buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ iconv ]; }    # correct
  { buildInputs = lib.optional stdenv.hostPlatform.isDarwin iconv; }         # incorrect
  ```
- Use of `with lib;` _anywhere_ is forbidden:
  ```nix
  { meta = { license = lib.licenses.mit; }; }          # correct
  { meta = with lib; { license = licenses.mit; }; }    # incorrect
  ```
  or:
  ```nix
  inherit (lib) mkForce; { x = mkForce 20; }    # correct
  with lib; { x = mkForce 20; }                 # incorrect
  ```

- Style choices not covered by the documented conventions should be left to the author's discretion and **not** commented in reviews.

### 3.3. Release notes

- If packages are removed or major NixOS changes are made, write about it in the next release notes in `nixos/doc/manual/release-notes`.

### 3.4. Import From Derivation (IFD)

- IFD is **disallowed** in nixpkgs for performance reasons. It can be worked around by committing generated intermediate files to version control.

### 3.5. `overrideAttrs` and `overridePythonAttrs`

- Do **not** introduce new uses of `overrideAttrs` or `overridePythonAttrs` in nixpkgs. Instead:
  - Keep all instances of the same package next to each other.
  - Minimize how many different instances of a package exist.
  - Discuss patches with the maintainer of the dependency.
  - Try modifying the package to work with the version in nixpkgs.
  - Factor out a function that can build multiple versions.
  - Add an explicit flag and use `override` instead.

### 3.6. Sources

- Always fetch source files using [nixpkgs fetchers](./doc/build-helpers/fetchers.chapter.md).
- Source(s) is/are fetched from an official location, a trusted mirror, or a mirror trusted by the author(s).
- Use reproducible sources with high availability.
- Prefer protocols that support proxies.
- Preferred source hash type is `sha256`.
- Prefer `fetchFromGitHub` over `fetchgit` for GitHub sources.
- When fetching from GitHub, always reference revisions by their **full commit hash** (not short hashes).
- Uses `mirror://` URLs when available.
- Any change of upstream is verified:
  - If switching from e.g., PyPI to GitHub, verify that the repository is the official one.
  - If switching to a fork, check with external sources (other package repositories) for community consensus.

### 3.7. Patches

- Patches already merged upstream or published elsewhere **should** be retrieved using `fetchpatch2`.
- Use `fetchpatch` instead of `fetchpatch2` if the patch file contains short commit hashes.
- Vendor the `.patch` files to the nixpkgs repository only when they:
  - Solve problems unique to packaging in nixpkgs.
  - Cannot be fetched easily.
  - Have a high chance of disappearing (unstable/unreliable URLs).
  - Author must specify why the patch wasn't upstreamed.
- Patch names must clearly describe the reason for the patch via either:
  - comment
  - `name` attribute in fetchers
  - filename
    - Security patches should be named by CVE identifier (e.g., `CVE-YYYY-NNNNN.patch`).

## 4. Package review

### 4.1. Package location

- New top-level packages that can be `callPackage`-ed **must** be placed in `pkgs/by-name/` following the name-based directory structure.
  ```
  pkgs/by-name/so/some-package/package.nix
  ```
  where `so` is the lowercase 2-letter prefix of the attribute name.
- The legacy category hierarchy (`pkgs/development/`, `pkgs/tools/`, etc.) is partially deprecated and should be only used when `pkgs/by-name/` cannot be used (e.g., packages using non-`callPackage` builders like `python3Packages.callPackage`).
- Packages in `pkgs/by-name/` cannot reference files outside their own directory.
  - For multiple versions of a package, use a local package set pattern in `all-package.nix` instead.

### 4.2. Security considerations for new packages

- Any _new_ package that immediately needs `meta.knownVulnerabilities` is unlikely to be fit for nixpkgs.
- Any package depending on known-vulnerable library should be considered carefully.
- Packages typically used with untrusted data should have a maintained and responsible upstream:
  - Packages that vendor or fork web engines (Blink, Gecko, Webkit) must keep up with frequent updates.
  - Security-critical fast-moving packages (e.g., Chrome, Firefox, etc.) must have at least one committer among maintainers who actively reviews, merges, and backports updates.
  - Services which typically work on web traffic are working on untrusted input.
  - Data is commonly shared over untrusted channels (e.g., email archives, rich documents, etc.) is untrusted.
- Applications in the UNIX authentication stack (e.g., PAM, D-bus modules, SUID binaries, etc.) should be considered carefully.
- Encryption libraries should have a maintained and responsible upstream.
- Security-critical components in larger packages should be unvendored (use the nixpkgs package as dependency).
- A "responsible upstream" includes:
  - Channels to disclose security concerns.
  - Responsiveness to security concerns, providing fixes and/or workarounds.
  - Transparent public disclosure of security issues.
  - These aspects are sometimes hard to verify, in which case an upstream that is not known to be irresponsible should be considered as responsible.
- Source-available software should be built from source where possible. Binary blobs risk supply chain attacks and vendored outdated libraries.

### 4.3. Package naming guidelines

**`pname` attribute**:
- **Should** be identical to the upstream package name.
- **Must not** contain uppercase letters. Use `"mplayer"` instead of `"MPlayer"`.

**Package attribute name**:
- **Must** be a valid identifier in Nix.
- If `pname` starts with a digit, the attribute **should** be prefixed with an underscore (e.g., `0ad` -> `_0ad`).
- New attribute names **should** be the same as `pname`. Hyphenated name **should not** be converted to snake_case or camelCase.
- If multiple versions exist, this **should** be reflected in attribute names (e.g., `json-c_0_9`, `json-c_0_11`, etc.). If there is an obvious "default" version, make an extra attribute pointing to it.

### 4.4. Versioning guidelines

**`version` attribute**:
- **Must** start with a digit (required for `nix-env` backwards-compatibility).
- Must document why a special version is pinned (so others know if/when it can be unpinned).
- For "unstable versions": `version = "<latest-version>-unstable-YYYY-MM-DD"`.
- If no suitable preceding release exists: use `0` as the preceding version (e.g., `"0-unstable-2022-03-15"`).

### 4.5. Meta attributes guidelines

**`meta` attribute set**:
- Must always be placed **last** in the derivation. Any `passthru` or other meta-like attribute sets should be written before it.

**`meta.description` must**:
- Be short, just one sentence.
- Be capitalized.
- Not start with the definite or an indefinite article.
- Not start with the package name.
  - More generally, it should not refer to the package name.
- Not end with a period (or any punctuation for that matter).
- Provide factual information.
  - Avoid subjective language.

**`meta.license` must**:
- Be set.
- If there is no upstream license, default to `lib.licenses.unfree`.
- If in doubt, try to contact the upstream developer(s) for clarification.
- License matches the upstream license.
  - License can change with version updates. Check that it matches the upstream license.

**`meta.sourceProvenance` must**:
- Be set if the package is not built from source (e.g., repackaging `.deb`, `.rpm`, `.whl`, then use `lib.sourceTypes.binaryNativeCode`).

**`meta.platforms` must**:
- Be set.

**`meta.mainProgram` must**:
- Be set to the name of the executable which facilitates the primary function of the package, if such an executable exists in `$bin/bin/` (or `$out/bin/`, if there is no `"bin"` output).
- Packages with a single executable should set it.
- Packages with no executables should not set it.
- Packages with multiple executables, none of which is the "main" program, should not set it.
- Packages not primarily used for a single executable do not need to set it.
- Always prefer a hardcoded string (not `pname`).

**`meta.maintainers` must**:
- Be set.

### 4.6. Derivation guidelines

- Avoid `let-in` blocks that hinder overlaying the package. Package definitions should be structured so that `.override` and `.overrideAttrs` works correctly.
- Build-time only dependencies are declared in `nativeBuildInputs`.
- The list of `phases` is not overridden.
- When a phase (like `installPhase`) is overridden, it starts with `runHook preInstall` and ends with `runHook postInstall`.
- If any (especially opinionated) patch or `substituteInPlace` is applied, document why.
- If any non-default build flags are set, document why.
- Any special packaging choices are documented.

### 4.7. Package tests

- `passthru.tests` should be set for new packages when feasible.
- If NixOS module test(s) exists for the package, they should be linked via `passthru.tests` (e.g., `passthru.tests.nginx = nixosTests.nginx;`).
- If any checks are partially or fully disabled, document why.

### 4.8. Update scripts

- `passthru.updateScript` should be set when automatic updates are feasible.
- A common pattern is `passthru.updateScript = nix-update-script {};`.
- Update scripts may be an executable file, a list (script + arguments), or an attribute set with `command`, `attrPath`, and `supportedFeatures`.

### 4.9. Removed or deprecated packages

- When removing a package, an alias with a throw message explaining why must be added to `pkgs/top-level/aliases.nix`.
- Removals and major NixOS changes must be documented in release notes under `nixos/doc/manual/release-notes`.

## 5. NixOS module review

- Any new module test(s) is/are added to the package `passthru.tests`.
- Introduced NixOS configuration options are correct:
  - Type is appropriate (`loaOf` and `string` types are deprecated).
  - Description of the option is provided.
  - Example of the value for the option is provided.
  - Default value of the option is provided.
    - Defaults may only be omitted if **both**:
      1. The user is required to set the default in order to properly use the service.
      2. The lack of a default does not break evaluation when the module is not enabled.
- Module `meta` field is present:
  - Maintainers are declared in `meta.maintainers`.
  - Module documentation is declared with `meta.doc`.
- Module respects other modules' functionality (e.g., enabling a module should not open firewall ports by default, etc.).
- No unnecessary package(s) is/are added to `environment.systemPackages`.
- Options changes are backwards compatible.
  - `mkRenamedOptionModuleWith` provides a way to make renamed options backwards compatible.
  - Use `lib.versionAtLeast config.system.stateVersion "24.05"` on backwards incompatible changes which may corrupt, change, or update state stored on existing setups.
- Removed options are declared with `mkRemovedOptionModule`.
- Non-backwards-compatible changes are mentioned in release notes.
- Documentation affected by the change is updated.
- When changing the bootloader installation process, extra care must be taken. GRUB installations cannot be rolled back. Hence, changes may break people's installations forever.

## 6. lib review

- **Motivation must be provided.**
  - Clearly describes why the change is necessary and its use cases.
- **Fairbairn threshold.**
  - The change benefits the user more than the added mental effort of looking it up. If the same can be reasonably done with the existing interface, consider just updating the documentation with more examples and links.
- **One PR per change.**
  - Do not have multiple changes in one PR.
- **Interface named appropriately.**
  - Names are self-explanatory and consistent with the rest of `lib`.
  - If no obvious best name, alternatives considered should be mentioned and included.
- **Documentation written.** Good test coverage, including:
  - Edge cases (empty values or lists).
  - Tricky inputs (string with string context, non-existent path).
  - All code paths (`if-then-else` branches, returned attributes).
  - Custom error messages (`throw` and `abortMsg`) if tests are in `bash`.
- **Code is tidy.**
  - Variables named well.
  - Code is self-explanatory.
  - Generous with comments when appropriate.
- **Code is efficient.**
  - Aware that Nix does not have free abstractions.
  - Seemingly straightforward changes can cause more allocations and decreased performance.

## 7. Documentation review

- New documentation content is written in the [CommonMark](https://commonmark.org/) Markdown dialect.
- **One sentence per line.**
- **Examples first.**
  - Put examples before detailed explanations.
- No inline HTML.
- Function documentation follows the style rule:
  - First sentence in present tense.
  - Active voice.
  - Subject oriented (referring implicitly to the function name).
- `callPackage`-compatible examples.
  - Example code should be destructured arguments, not `pkgs.`-prefixed references.
- REPL inputs/outputs use proper formatting
  - `$` prefix for shell.
  - `nix-repl>` for Nix REPL.
- Nested headings used to separate inputs, outputs and examples.
  - Examples are the last nested heading.
- Function arguments documented with definition lists.
  - Including types and defaults.
- Admonition syntax used for callouts and examples.
- Anchors explicitly defined on headings.
  - Using header attributes syntax.
- [Diátaxis framework](https://diataxis.fr/):
  - `doc/` should only contain reference documentation
  - Tutorials/guides go to `https://nix.dev`.

## 8. Maintainer addition

When reviewing additions to `maintainer-list.nix`:

### 8.1. GPG key verification

- If the user has specified a GPG key, verify that the commit is signed by their key:
  1. Receive the key: `gpg --recv-keys <fingerprint>`
  2. Check the commit: `git log --show-signature`
  3. Validate "Good signature" and that the printed key matches the user's submitted key.
  4. **Do not** rely on GitHub's "Verified" label alone. It does not display the full key fingerprint.
- If the commit is not signed, or signed by a different user, ask them to either recommit using that key or remove their key information.

### 8.2. GitHub identity verification
- Ensure the user has specified a `github` account name and a `githubId`, and verify the two match:
  1. Make sure the listed GitHub handle matches the author of the commit.
  2. Visit `https://api.github.com/user/<githubId>` and validate that the `login` field matches the provided `github` handle.

### 8.3. Maintainer teams
- Teams should be organized around areas of maintenance interest and expertise, not employer or participation in another project.
