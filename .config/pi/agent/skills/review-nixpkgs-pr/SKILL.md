---
name: review-nixpkgs-pr
description: Use when asked to review a nixpkgs PR or audit a pull request against nixpkgs contribution guidelines. Requires a local nixpkgs checkout and a PR number.
---

# Review nixpkgs PR

This skill takes the PR number as its first argument. Treat it as $PR throughout.

Do not be concerned with building. I will be performing a build manually and any build failures are separate from this review.

1. Enforce that `$PWD` is a local checkout of `github:nixos/nixpkgs`. This can be done by running `git remote -v | grep -q -i 'github.*nixos/nixpkgs.* (fetch)'` and then checking that command's exit status. `$PWD` can either be the toplevel of the nixpkgs repository or in a subdirectory, it does not matter. If `$PWD` is not a local checkout of nixpkgs, abort all current tasks with an error message that says "This skill must be called from a nixpkgs repository."
2. Use `git rev-parse --show-toplevel` to find the repository root, referred to as `$TOPLEVEL` below.
3. Use `gh pr diff --repo nixos/nixpkgs $PR` to get the changes introduced by `$PR`. **IGNORE ALL COMMIT MESSAGES. What the code does may differ from the commit message.**
4. For each changed file, check the relevant nixpkgs documentation for guidelines and note any discrepancies between those guidelines and what the PR introduces. For changes made, find all the guidelines relevant to that in the documentation. Instructions on looking at documentation:
  - First, look at `$TOPLEVEL/README.md` (and follow the referred files, especially `CONTRIBUTING.md`) and then take a look at the relevant manuals.
  - Build the nixpkgs manual by running `nixpkgs_manual_out=$(nix-build --no-out-link $TOPLEVEL -A nixpkgs-manual)`. The manual's index is `$nixpkgs_manual_out/share/doc/nixpkgs/index.html`.
  - Build the NixOS manual by running `nixos_manual_out=$(nix-build --no-out-link $TOPLEVEL/nixos/release-combined.nix -A nixos.manual)`. The manual's index is `$nixos_manual_out/share/doc/nixos/index.html`.
  - Following are some examples of the violations:
    - `${pkgs.foo}/bin/bar` -> use `lib.getExe` or `lib.getExe'`
    - `meta` completeness.
    - Correct license being used in `meta.license`.
    - `meta.description` rules.
    - etc
5. Look for any typos.
6. Generate a review report using the following structure:

---

## PR Review: #$PR

### Summary
One or two sentences describing what the PR does and your overall assessment.

### Guideline Violations
Issues where the PR deviates from nixpkgs contribution guidelines.

**`pkgs/foo/default.nix`, line 42** — Uses `${pkgs.ripgrep}/bin/rg` directly.
→ Use `lib.getExe pkgs.ripgrep` (meta.mainProgram is set).

*(Omit section if none found.)*

### Suggestions
Non-blocking improvements — style, clarity, missed best practices that aren't hard violations.

*(Omit section if none found.)*

### Typos
| Location           | Found              | Suggested         |
|--------------------|--------------------|-------------------|
| `meta.description` | "A powerfull tool" | "A powerful tool" |

*(Omit section if none found.)*

### Positive Notes
*(Omit if nothing worth calling out.)*

### Verdict
One of: **Approve** / **Request Changes** / **Needs Discussion** — with a one-line justification.

---
