#!/usr/bin/env python3
from __future__ import print_function

import sys
from os.path import isdir, join
from glob import glob
from os import getcwd, system, chdir, popen, environ
import subprocess
import argparse
from clint.textui import colored


def get_project_name():
    return getcwd().rsplit('/')[-1]


class RepoInfo:
    local_name = ''
    uri = ''
    version = ''


def git_pull():
    result = subprocess.call(['git', 'pull'])


def write_rosinstall(repo_list):

    r_file = '.rosinstall'

    f = open(r_file, 'w')
    f.write("# IT IS UNLIKELY YOU WANT TO EDIT THIS FILE BY HAND,\n")
    f.write("# UNLESS FOR REMOVING ENTRIES.\n")
    f.write("# IF YOU WANT TO CHANGE THE ROS ENVIRONMENT VARIABLES\n")
    f.write("# USE THE rosinstall TOOL INSTEAD.\n")
    f.write("# IF YOU CHANGE IT, USE rosinstall FOR THE CHANGES TO TAKE EFFECT\n")
    distro = environ['ROS_DISTRO']
    f.write("- setup-file: {local-name: /opt/ros/" + distro + "/setup.sh}\n")

    for idx in range(len(repo_list)):
        f.write("- git: {local-name: src/" + repo_list[idx].local_name + ", uri: \'" + repo_list[idx].uri + "\', version: " + repo_list[idx].version + "}\n")

    f.close()


def read_version_file(tag):

    repo_list = []

    v_file = 'VERSION_INFO.txt'
    f = open(v_file, 'r')

    v = 0

    print("  looking for ", tag)
    while True:
        v_line = f.readline()
        if not v_line:
            break
        if v_line[0] == "#":
            continue
        l = v_line.split(" ")
        if l[0] == "---":
            t = l[1][0:len(l[1]) - 2]
            if tag == t:
                print("  matched ", tag)
                while True:
                    x = f.readline()
                    if not x:
                        break
                    if x[0] == "#":
                        continue
                    if x == "\n":
                        break
                    l = x.split(" ")
                    print("      " + l[0])

                    rl = RepoInfo()
                    rl.local_name = l[0]
                    rl.uri = l[1]
                    rl.version = l[2][0:len(l[2]) - 1]
                    repo_list.append(rl)

    f.close()
    return repo_list


def run_rosinstall():
    return subprocess.call(['wstool', 'up', '--delete-changed-uris'])


if __name__ == "__main__":

    pname = get_project_name()

    print(colored.cyan("========================="))
    print(colored.cyan(pname.upper() + " INSTALL SCRIPT"))
    print(colored.cyan("========================="))

    # set up the argument parser
    parser = argparse.ArgumentParser(description=str('Install ' + pname.upper() + ' Packages'))
    parser.add_argument("-r", "--build-rosinstall-only", help='build .rosinstall only, but do not install code', action="store_true")
    parser.add_argument("-v", "--version", nargs=1, help='which version to install', default=["LATEST"])

    args = parser.parse_args()

    tag = args.version[0]
    print("installing TAG: " + colored.yellow("\'" + tag + "\'"))

    git_pull()

    print("reading VERSION_INFO.txt")
    repo_list = read_version_file(tag)
    print("num repositories: ", len(repo_list))

    print("writing .rosinstall...")
    write_rosinstall(repo_list)

    distro = environ['ROS_DISTRO']
#    system("catkin config -DCMAKE_BUILD_TYPE=Release --extend /opt/ros/" + distro + " > /dev/null")

    if not args.build_rosinstall_only:
        print("installing repositories...")
        try:
            print("updating code...")
            if run_rosinstall() > 0:
                print(colored.red("problem running install script..."))
                sys.exit(0)
        except:
            print(colored.red("problem running install script..."))
            sys.exit(0)

    else:
        print(colored.yellow("not installing repositories..."))

    rc = 1
    try:
        rc = system("rosdep install --from-path src --ignore-src -y")
        if not rc == 0:
            rc = 1
            rc = system("rosdep update")
            if not rc == 0:
                raise Exception
            rc = 1
            rc = system("rosdep install --from-path src --ignore-src -y")
            if not rc == 0:
                raise Exception
    except:
        print(colored.red("\nFailed to update depends \n"))
        tag = "UNKNOWN"
        sys.exit(0)
        
    print(colored.green("successfully finished INSTALL script"))
