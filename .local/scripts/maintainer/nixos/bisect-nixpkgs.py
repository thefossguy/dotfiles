#!/usr/bin/env python3

import argparse
import logging
import os
import subprocess
import sys

def nixpkgs_check():
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
    if git_cat_file_cmd.returncode != 0:
        logging.error(
            "{} is not a nixpkgs repository".format(
                current_working_directory
            )
        )
        sys.exit(1)

def parse_ze_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--good-commit", required=True, type=str, help="The known-good commit to build <derivation>",)
    parser.add_argument("--bad-commit", required=True, type=str, help="The known-bad commit to build <derivation>",)
    parser.add_argument("--derivation", required=True, type=str, help="The nixpkgs derivation to build",)
    args = parser.parse_args()
    return args

def run():
    logging.basicConfig(level=logging.INFO)
    nixpkgs_check()

    args = parse_ze_args()
    logging.info("Starting a git-bisect in {}".format(os.getcwd()))
    logging.info("  Known bad commit: {}".format(args.bad_commit))
    logging.info(" Known good commit: {}".format(args.good_commit))
    logging.info("Nixpkgs derivation: {}".format(args.derivation))

    git_bisect_start_command = [
        "git",
        "bisect",
        "start",
        args.bad_commit,
        args.good_commit,
    ]
    logging.info("Running: {}".format(git_bisect_start_command))
    git_bisect_start_cmd = subprocess.run(git_bisect_start_command, check=True, stdout=sys.stdout, stderr=sys.stderr,)

    git_bisect_run_command = [
        "git",
        "bisect",
        "run",
        "bash",
        "-c",
        "if ! nix-build --keep-going --max-jobs 1 -A {}; then exit 1; fi".format(args.derivation),
    ]
    logging.info("Running: {}".format(git_bisect_run_command))
    git_bisect_run_cmd = subprocess.run(git_bisect_run_command, check=True, stdout=sys.stdout, stderr=sys.stderr,)

    git_bisect_reset_cmd = subprocess.run(["git", "bisect", "reset",], check=True, stdout=sys.stdout, stderr=sys.stderr,)

    return

if __name__ == "__main__":
    run()
