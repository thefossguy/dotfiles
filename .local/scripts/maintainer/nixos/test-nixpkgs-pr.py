#!/usr/bin/env python3

import argparse
import json
import logging
import os
import platform
import shutil
import subprocess
import sys


class PreRunCheck:
    def cli_tools_check(self) -> bool:
        result = True
        binaries_to_check = [
            "git",
            "nix",
            "nixpkgs-review",
        ]
        for bin_to_check in binaries_to_check:
            if not shutil.which(bin_to_check):
                result = False
                logging.error(
                    "Binary '{}' missing from $PATH".format(
                        bin_to_check
                    )
                )
        return result

    def nixpkgs_check(self) -> bool:
        current_working_directory = os.getcwd()
        git_cat_file_cmd = subprocess.run(
            [
                "git",
                "cat-file",
                "-e",
                "HEAD:nixos/release.nix",
            ],
            capture_output=True,
            check=False,
        )
        result = git_cat_file_cmd.returncode == 0
        if not result:
            logging.error(
                "{} is not a nixpkgs repository".format(
                    current_working_directory
                )
            )
        return result

    def __init__(self):
        cli_tools_check_result = self.cli_tools_check()
        nixpkgs_check_result = self.nixpkgs_check()
        results = [
            cli_tools_check_result,
            nixpkgs_check_result,
        ]
        if False in results:
            sys.exit(1)
        else:
            return


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pr", required=True, type=int, help="The nixpkgs PR number"
    )
    parser.add_argument(
        "--extra-packages", action='append', help="Extra packages to build with nixpkgs-review"
    )
    parser.add_argument(
        "--no-clear-cache", action="store_true", help="Do not clear `$XDG_CACHE_HOME/nixpkgs-review` before calling `nixpkgs-review`"
    )
    parser.add_argument(
        "--with-cosmic",
        action="store_true",
        help="Build additional attributes relevant to COSMIC",
    )
    args = parser.parse_args()
    return args


def normalized_arch() -> str:
    machine = platform.machine().lower()

    mapping = {
        "arm64": "aarch64",
        "aarch64": "aarch64",
        "x86_64": "x86_64",
        "amd64": "x86_64",
    }

    return mapping.get(machine, machine)


def get_cosmic_tests() -> list[str]:
    cosmic_tests = []

    nix_instantiate_cmd = subprocess.run(
        [
            "nix-instantiate",
            "--eval",
            "--json",
            "--expr",
            """
              let
                lib = import ./lib;
                pkgs = import ./. {
                  system = builtins.currentSystem;
                  allowUnfree = true;
                  allowBroken = true;
                };
                cosmicMembers = lib.teams.cosmic.members;
              in

              builtins.filter (
                name:
                let
                  nixosTestMaintainerList = pkgs.nixosTests.${name}.meta.maintainers or [ ];
                in
                lib.all (x: lib.elem x nixosTestMaintainerList) cosmicMembers
              ) (builtins.attrNames pkgs.nixosTests)
            """,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if nix_instantiate_cmd.stdout == "":
        logging.warning(
            "The list containing the NixOS tests for COSMIC is empty"
        )
        return cosmic_tests

    cosmic_tests = json.loads(nix_instantiate_cmd.stdout)
    return cosmic_tests


def with_cosmic(args: argparse.Namespace) -> list[str]:
    cosmic_args = []
    if not args.with_cosmic:
        return cosmic_args

    git_ls_remote_cmd_args = [
        "git",
        "ls-remote",
        "https://github.com/nixos/nixpkgs.git",
        "refs/pull/{}/head".format(args.pr),
    ]
    git_ls_remote_cmd = subprocess.run(
        git_ls_remote_cmd_args,
        capture_output=True,
        text=True,
        check=False,
    )
    short_commit_rev_of_pr = git_ls_remote_cmd.stdout[:12]
    if short_commit_rev_of_pr == "":
        logging.error(
            "Could not determine what '{}' resolves to".format(
                " ".join(git_ls_remote_cmd_args)
            )
        )
        sys.exit(1)
    nixpkgs_pr_branch_name = "nixpkgs-pr-{}-{}".format(
        args.pr,
        short_commit_rev_of_pr,
    )

    git_branch_cmd = subprocess.run(
        [
            "git",
            "branch",
            "--show-current",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if git_branch_cmd.returncode != 0:
        logging.error("Could not determine the current branch")

    current_branch = git_branch_cmd.stdout
    if current_branch != nixpkgs_pr_branch_name:
        git_fetch_cmd = subprocess.run(
            [
                "git",
                "fetch",
                "https://github.com/NixOS/nixpkgs.git",
                "+pull/{}/head:{}".format(
                    args.pr, nixpkgs_pr_branch_name
                ),
            ],
            capture_output=True,
            check=False,
        )
        if git_fetch_cmd.returncode != 0:
            logging.error(
                "Could not fetch the refs from PR {}".format(args.pr)
            )
            sys.exit(1)

        git_switch_cmd = subprocess.run(
            [
                "git",
                "switch",
                nixpkgs_pr_branch_name,
            ],
            capture_output=True,
            check=False,
        )
        if git_switch_cmd.returncode != 0:
            logging.error(
                "Could not switch to the '{}' branch".format(
                    nixpkgs_pr_branch_name
                )
            )
            sys.exit(1)

    nix_arch = normalized_arch()
    cosmic_tests = get_cosmic_tests()
    for indv_cosmic_test in cosmic_tests:
        cosmic_args.extend(
            [
                "--additional-package",
                "nixosTests.{}".format(indv_cosmic_test),
            ]
        )

    nix_build_cmd_args = [
        "nix-build",
        "--keep-going",
        "--no-out-link"
        "./nixos/release.nix",
    ]
    for indv_cosmic_test in cosmic_tests:
        nix_build_cmd_args.extend(
            [
                "-A",
                "tests.{}.{}-linux".format(indv_cosmic_test, nix_arch),
            ]
        )

    git_cat_file_cmd = subprocess.run(
        [
            "git",
            "cat-file",
            "-e",
            "HEAD:nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-cosmic.nix",
        ],
        capture_output=True,
        check=False,
    )
    if git_cat_file_cmd.returncode == 0:
        nix_build_cmd_args.extend(
            ["-A", "iso_cosmic.{}-linux".format(nix_arch)]
        )

    logging.info("Running: {}".format(nix_build_cmd_args))
    nix_build_cmd = subprocess.run(
        nix_build_cmd_args,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=False,
    )

    git_switch_cmd = subprocess.run(
        ["git", "switch", "-"],
        capture_output=True,
        check=False,
    )

    return cosmic_args


def run():
    _ = PreRunCheck()
    args = parse_arguments()
    nixpkgs_review_args = [
        "nixpkgs-review",
        "pr",
        "--print-result",
        "--eval",
        "local",
        "--build-graph",
        "nix",
        "--extra-nixpkgs-config",
        "{ allowBroken = false; }",
    ]
    for extra_pkg in args.extra_packages:
        nixpkgs_review_args.extend(["--additional-package", extra_pkg, ])
    nixpkgs_review_args.extend(with_cosmic(args))
    nixpkgs_review_args.append(str(args.pr))

    if not args.no_clear_cache:
        xdg_cache_home = os.getenv("XDG_CACHE_HOME")
        match xdg_cache_home:
            case "" | None:
                logging.info("$XDG_CACHE_HOME is either unset or empty")
                match os.getenv("HOME"):
                    case "" | None:
                        logging.error("$HOME is either unset or empty")
                        sys.exit(1)
                    case _:
                        xdg_cache_home = "{}/.cache".format(os.getenv("HOME"))
            case _:
                pass
        nixpkgs_review_cache_dir = "{}/nixpkgs-review".format(xdg_cache_home)
        shutil.rmtree(nixpkgs_review_cache_dir, ignore_errors=True)

    logging.info("Running: {}".format(nixpkgs_review_args))
    nixpkgs_review_cmd = subprocess.run(
        nixpkgs_review_args,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=False,
    )
    return


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    run()
