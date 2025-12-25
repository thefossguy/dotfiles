#!/usr/bin/env python3

import argparse
import errno
import grp
import json
import os
import pwd
import shutil
import socket
import stat
import subprocess
import sys

global_varz = {}

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cdrom", "--iso", "--iso-image",)
    parser.add_argument("--hda", "--disk", "--drive",)
    parser.add_argument("--hdb",)
    parser.add_argument("--vcpus", "--cpus", "--vcpu", "--cpu",)
    parser.add_argument("--memory", "--mem", "--ram",)
    parser.add_argument("--no-graphics", "--nographic", "--nographics", "--no-graphic", action="store_true", default=None)
    parser.add_argument("--host-port", type=int,)
    parser.add_argument("--without-hw-accel", action="store_true",)
    parser.add_argument("--extra-qemu-args",)
    args = parser.parse_args()

    files_to_check = [args.cdrom, args.hda, args.hdb]
    if not any(files_to_check):
        print("ERROR: <[[--cdrom|--iso|--iso-image] | [--hda|--disk|--drive] | [--hdb]]>")
        sys.exit(1)

    if args.vcpus == None:
        args.vcpus = 2

    if args.memory == None:
        args.memory = 4096

    if args.no_graphics == None:
        if os.uname().sysname == "Darwin":
            # Even Darwin servers (Xserve) have a fucking GUI
            # environment by default. Additionally, this can be easily
            # overridden by simply using the flag.
            args.no_graphics = False
        elif os.getenv("DISPLAY") or os.getenv("WAYLAND_DISPLAY"):
            args.no_graphics = False
        else:
            args.no_graphics = True

    missing_files = []
    for f in files_to_check:
        if f != None:
            if not os.path.exists(f):
                missing_files.append(f)
    if missing_files:
        print(f"ERROR: These files were specified but do not exist: {missing_files}")
        sys.exit(1)

    if args.host_port == None:
        args.host_port = 2222
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.bind(('127.0.0.1', args.host_port))
    except socket.error as e:
        if e.errno == errno.EADDRINUSE:
            print(f"ERROR: Host port '{args.host_port}' is in use, please use a different port.")
            sys.exit(1)
    else:
        sock.close()

    global_varz["cli_args"] = args
    return

def check_kvm_char_dev():
    if global_varz["cli_args"].without_hw_accel or os.uname().sysname != "Linux":
        return

    dev_kvm = "/dev/kvm"

    if not os.path.exists(dev_kvm):
        print(f"ERROR: '{dev_kvm}' does not exist.")
        sys.exit(1)

    if not stat.S_ISCHR(os.stat(dev_kvm).st_mode):
        print(f"ERROR: '{dev_kvm}' is not a character device. Did you do something cursed?")
        sys.exit(1)

    if grp.getgrgid(os.stat(dev_kvm).st_gid).gr_name != "kvm":
        print(f"ERROR: The group ownership of '{dev_kvm}' is not `kvm`.")
        sys.exit(1)

    current_user = pwd.getpwuid(os.getuid()).pw_name
    user_groups = [group.gr_name for group in grp.getgrall() if current_user in group.gr_mem]
    if "kvm" not in user_groups:
        print(f"ERROR: You are not in the `kvm` group. Please run `sudo usermod -aG kvm ${current_user}`.")
        sys.exit(1)

    return

def qemu_bin_setup():
    qemu_bins = [ "qemu-kvm", f"qemu-system-{global_varz["qemu_properties"]["m_arch_64"]}" ]
    for bin in qemu_bins:
        if shutil.which(bin) == None:
            if os.path.exists(f"/usr/libexec/{bin}"):
                global_varz["qemu_properties"]["qemu_bin"] = f"/usr/lib64/{bin}"
                break
        else:
            global_varz["qemu_properties"]["qemu_bin"] = bin
            break
    if global_varz["qemu_properties"]["qemu_bin"] == None:
        print(f"ERROR: Neither `qemu-kvm` nor `{non_generic_bin}` could be located in your system")
        sys.exit(1)
    return

def qemu_bios_setup():
    m_arch_64 = os.uname().machine;
    m_arch_32 = None;
    global_varz["qemu_properties"]["machine_type"] = "virt"
    global_varz["qemu_properties"]["virtio_gpu_device"] = "virtio-gpu-gl"
    global_varz["qemu_properties"]["display_backend"] = "sdl"
    match m_arch_64:
        case "arm64":
            # running aarch64-linux VMs on aarch64-darwin
            global_varz["qemu_properties"]["virtio_gpu_device"] = "virtio-gpu"
            global_varz["qemu_properties"]["display_backend"] = "cocoa"
            m_arch_64 = "aarch64"
            m_arch_32 = "arm"
        case "riscv64":
            m_arch_64 = "riscv"
            m_arch_32 = "riscv"
        case "aarch64":
            m_arch_32 = "arm"
        case "x86_64":
            global_varz["qemu_properties"]["machine_type"] = "pc"
            global_varz["qemu_properties"]["virtio_gpu_device"] = "virtio-vga-gl"
            m_arch_32 = "i386"
        case _:
            print(f"ERROR: Your machine type '{m_arch_64}' is unsupported")
            sys.exit(1)

    if os.path.exists("/run/booted-system"):
        edk2_path = "/run/libvirt/nix-ovmf/"
        global_varz["qemu_properties"]["edk2_code"] = edk2_path + f"edk2-{m_arch_64}-code.fd"
        #global_varz["qemu_properties"]["edk2_vars"] = edk2_path + f"edk2-{m_arch_32}-vars.fd"

    elif os.uname().sysname == "Darwin":
        qemu_cmd = shutil.which(f"qemu-system-{m_arch_64}")
        if qemu_cmd != None:
            qemu_cmd = os.path.realpath(qemu_cmd)
            qemu_cmd = qemu_cmd.split("bin/")[0]
            if not qemu_cmd.startswith("/nix/store"):
                print("ERROR: Cannot determine how to find the EDK2 firmware BIOS to use with QEMU.")
                sys.exit(1)
            else:
                global_varz["qemu_properties"]["edk2_code"] = qemu_cmd + f"share/qemu/edk2-{m_arch_64}-code.fd"
                #global_varz["qemu_properties"]["edk2_vars"] = qemu_cmd + f"share/qemu/edk2-{m_arch_32}-code.fd"

    else:
        edk2_firmware_lookup_dir = "/usr/share/qemu/firmware"
        if not os.path.exists(edk2_firmware_lookup_dir):
            print("ERROR: Cannot lookup existing EDK2 firmware to use as BIOS with QEMU.")
            print("NOTICE: Please run either of the following commands based on your architecture and distribution before proceeding.")
            print("$ sudo apt install ovmf # x86_64")
            print("$ sudo apt install qemu-efi-arm # aarch64")
            print("$ sudo dnf install edk2-ovmf # x86_64")
            print("$ sudo dnf install edk2-aarch64 # aarch64")
            sys.exit(1)

        # All this bullshit because Fedora has insane names for their
        # firmware files like `QEMU_EFI-silent-pflash.qcow2` that I
        # could never in a million years pick up such a deranged name.
        json_firmwarez = os.listdir(edk2_firmware_lookup_dir)
        json_firmwarez = [ f"{edk2_firmware_lookup_dir}/{file}" for file in json_firmwarez]
        json_firmwarez.sort(reverse=True)
        firmware_data = None
        for firmware_json in json_firmwarez:
            if firmware_json.endswith(".json"):
                with open(firmware_json, "r") as file:
                    contents = file.read()
                    json_obj = json.loads(contents)
                    if json_obj["targets"][0]["architecture"] == m_arch_64:
                        if "secure-boot" not in json_obj["features"] and "nvram-template" in contents:
                            firmware_data = json_obj
                            break
        if firmware_data == None:
            print(f"ERROR: Could not find any valid files in '{edk2_firmware_lookup_dir}' to determine which EDK2 firmware to use.")
            sys.exit(1)

        global_varz["qemu_properties"]["edk2_code"] = json_obj["mapping"]["executable"]["filename"]
        #global_varz["qemu_properties"]["edk2_vars"] = json_obj["mapping"]["nvram-template"]["filename"]
    global_varz["qemu_properties"]["m_arch_64"] = m_arch_64
    return

def pre_start_checks():
    parse_arguments()
    check_kvm_char_dev()
    return

def generate_qemu_args():
    global_varz["qemu_properties"] = {}
    global_varz["qemu_properties"]["qemu_bin"] = None
    qemu_bios_setup()
    qemu_bin_setup()

    global_varz["qemu_properties"]["qemu_args"] = [
        global_varz["qemu_properties"]["qemu_bin"],
        # kvm: linux
        # xen: linux (seems more enterprise friendly than kvm; upstream)
        # hvf: darwin
        # nvmm: netbsd
        # mshv: linux on top of HyperV
        "-machine", f"type={global_varz["qemu_properties"]["machine_type"]},accel=kvm:xen:hvf:nvmm:mshv:tcg",
        "-cpu", "max",
        "-smp", f"{global_varz["cli_args"].vcpus}",
        "-m", f"{global_varz["cli_args"].memory}",

        f"-drive", f"file={global_varz["qemu_properties"]["edk2_code"]},if=pflash,format=raw,unit=0,readonly=on",
        #f"-drive", f"file={global_varz["qemu_properties"]["edk2_vars"]},if=pflash,format=raw,unit=1",

        "-netdev", f"user,id=mynet0,hostfwd=tcp::{global_varz["cli_args"].host_port}-:22",
        "-device", "virtio-net-pci,netdev=mynet0",
    ]

    with open(shutil.which(global_varz["qemu_properties"]["qemu_bin"]), 'rb') as file:
        content = str(file.read())
        if "OpenGL support was not enabled in this build of QEMU" not in content:
            global_varz["qemu_properties"]["display_backend"] = global_varz["qemu_properties"]["display_backend"] + ",gl=on"

    if os.uname().sysname != "Darwin":
        global_varz["qemu_properties"]["qemu_args"].extend(["-sandbox", "on",])
    elif os.uname().sysname == "Darwin":
        global_varz["qemu_properties"]["qemu_args"].extend(["-device", "qemu-xhci", "-device", "usb-kbd", "-device", "usb-mouse"])

    if global_varz["cli_args"].no_graphics:
        global_varz["qemu_properties"]["qemu_args"].extend(["-nographic"])
    else:
        global_varz["qemu_properties"]["qemu_args"].extend(["-device", f"{global_varz["qemu_properties"]["virtio_gpu_device"]}"])
        global_varz["qemu_properties"]["qemu_args"].extend(["-display", f"{global_varz["qemu_properties"]["display_backend"]}"])

    if global_varz["cli_args"].cdrom:
        global_varz["qemu_properties"]["qemu_args"].extend(["-cdrom", global_varz["cli_args"].cdrom])
    if global_varz["cli_args"].hda:
        global_varz["qemu_properties"]["qemu_args"].extend(["-hda", global_varz["cli_args"].hda])
    if global_varz["cli_args"].hdb:
        global_varz["qemu_properties"]["qemu_args"].extend(["-hdb", global_varz["cli_args"].hdb])
    if global_varz["cli_args"].extra_qemu_args != None:
        global_varz["qemu_properties"]["qemu_args"].extend(global_varz["cli_args"].extra_qemu_args.split(" "))
    return

def main():
    pre_start_checks()
    generate_qemu_args()
    print(f"+ {" ".join(global_varz["qemu_properties"]["qemu_args"])}")
    process = subprocess.run(global_varz["qemu_properties"]["qemu_args"], stdout=sys.stdout, stderr=sys.stderr,)
    return process.returncode

if __name__ == "__main__":
    returncode = main()
    sys.exit(returncode)
