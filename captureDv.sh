#!/bin/bash

# This script can be used to capture Mini DV tapes over Firewire
# using dvgrab
#
# To install this on a Ubuntu system, I simply ran:
# sudo apt install dvgrab
#
# To better understand the options that are being passed as well as other
# options, refer to the dvgrab man page:
# https://manpages.ubuntu.com/manpages/jammy/man1/dvgrab.1.html
# man dvgrab
#
#
# USAGE:
# captureDv.sh [base]
#
# base
# The base argument is passed to dvgrab and is used to construct the filename
# to store video data: base-num.ext. num is a running number starting from 001,
# and ext is the file name extension specifying the file format used.
# The default value for base is "dvgrab-".


### Configure dvgrab path
dvgrab="dvgrab"


### Configure dvgrab Options

dvgrabopts=""

# autosplit
# Try to detect whenever a new recording starts, and store it into a separate
# file. dvgrab determines when to split using a flag in the stream or a
# discontinuity in the time‐code, where timecode discontinuity is anything 
# backwards or greater than one second.
dvgrabopts="$dvgrabopts --autosplit"

# format: raw
# Specifies the format of the output file(s).
# "raw" stores the data unmodified and have the .dv extension. These files are
# read by a number of GNU/Linux tools as well as Apple Quicktime.
dvgrabopts="$dvgrabopts --format raw"

# rewind
# Rewind the tape completely to the beginning prior to starting capture.
dvgrabopts="$dvgrabopts --rewind"

# size: 0
# This option tells dvgrab to store at most num megabytes (actually, mebibytes) per file, where num = 0 means unlimited file size for large files.
dvgrabopts="$dvgrabopts --size 0"

# srt
# Generate subtitle files containing the recording date and time in SRT format.
# For each video file that is created two additional files with the extension
# .srt0 and .srt1 are  created. They contain the recording date and time as
# subtitles in the SRT format. The .srt0 file contains the subtitles with
# timing based on the running time from the start of the current file. Use this
# file if you transcode to a format like AVI. The .srt1 file contains the
# subtitles with timing based on the time code as delivered by the camera. The
# mplayer program understands this type of subtitles. 
dvgrabopts="$dvgrabopts --srt"

# timestamp
# Put information on date and time of recording into file name.
dvgrabopts="$dvgrabopts --timestamp"


### Configure dvgrab Arguments

# base
# The base argument is used to construct the filename to store video data:
# base-num.ext. num is a running number starting from 001, and ext is the file
# name extension specifying the file format used. The default value for base is
# "dvgrab-".
#
# base can also be the first argument to this script
dvgrabargs_base="${1-dvgrab-}"



### Run dvgrab
echo "$dvgrab" $dvgrabopts "$dvgrabargs_base"
"$dvgrab" $dvgrabopts "$dvgrabargs_base"

