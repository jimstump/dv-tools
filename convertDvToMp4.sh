#!/bin/bash

## Fork from https://gist.github.com/githof
## https://gist.github.com/githof/482dee01b6a9933781d391097483c467

## Which is itself a fork from https://gist.github.com/jhubble
## https://gist.github.com/jhubble/546852d27cf8a22558f9d4178896ee64

# This script can be used to convert .dv files downloaded from a minidv camcorder to .mp4 files convenient for storing/uploading
#
# The files were imported using iMovie HD 6 on an old Snow Leopard Mac Mini
## Successfully used also with import from iMovie 8
## on a Snow Leopard macbook
#
# iMovie can be downloaded at:
# https://www.macintoshrepository.org/24547-imovie-6-hd-6-5-1
#
# Finding the hardware can be the most challenging part. 
# You need, an old computer with firewire, a firewire cable with appropriate adapters, and a mini dv camcorder with firewire output
#
# From iMovie, I create a new project, then connected the camcorder. IT can be finicky, but eventually shows up an "import" 
# button that imports files.
# From there, the .dv files are in "projectname.iMovie Project/Media" folder
# The ffmpeg conversion was based on http://blog.alanporter.com/2017-04-08/minidv-movies/
# (There seemed to be  lot of examples of .dv to mp4 conversion that didn't work. That Alan's was the one "good" one I found.)

# To use, go into a directory with dv files to convert and run the script (./convertDvToMp4.sh)
# The resultant mp4 with have its attributes and create/change date changed to match the "Date Time Original" field in original file
# This makes it accurate for uploading to google photos
#
# Everything is left in the same directory
# *.dv - original dv files
# *.mp4 - converted .mp4 files
# *_original - mp4 files before exiftool changed the date and time
#
##
## Improvement by githof:
## Call from other directory and on selected files,
## by giving list of files and/or of directories as arguments on
## command line
## e.g.:
## gist-convert/convertDvToMp4.sh VIDEOS/K27-mar-2010/ VIDEOS/K30-oct-2010/clip-2010-12-25\ 10\;00\;09.dv
## Behavior unchanged if no argument given
#
# Prereeqs: ffmpeg and exiftool installed. For mac:
# brew install exiftool; brew install ffmpeg
#
# Sometimes dates may be missing from some files. View in time order with:
# ls -latr
# To manually add a timestamp:
# exiftool Clip\ 01.mp4 -datetimeoriginal="2007:10:15 08:15:00"
# To copy that timestamp to other fields:
# exiftool Clip\ 01.mp4 "-mediacreatedate<datetimeoriginal" "-mediamodifydate<datetimeoriginal" "-FileCreateDate<datetimeoriginal" "-createdate<datetimeoriginal" "-modifydate<datetimeoriginal" "-filemodifydate<datetimeoriginal" "-filecreatedate<datetimeoriginal"
#
# Improvement by jimstump:
# If a .srt or .srt0 sidecar subtitle file exists (like dvgrab can generate)
# then embed that file as a subtitle in the generated mp4 file.

#------------------
# Options settings

ffopts=""

# FILTERS
ffopts="$ffopts -vf yadif"   # de-interlacing

# VIDEO ENCODING OPTIONS
ffopts="$ffopts -vcodec libx264"
ffopts="$ffopts -preset medium"  # balance encoding speed vs compression ratio
ffopts="$ffopts -profile:v main -level 3.0 "  # compatibility, see https://trac.ffmpeg.org/wiki/Encode/H.264
ffopts="$ffopts -pix_fmt yuv420p"  # pixel format of MiniDV is yuv411, x264 supports yuv420
ffopts="$ffopts -crf 18"  # The constant quality setting. Higher value = less quality, smaller file. Lower = better quality, bigger file. Sane values are [18 - 24]
ffopts="$ffopts -x264-params ref=4"

# AUDIO ENCODING OPTIONS
ffopts="$ffopts -acodec aac"
ffopts="$ffopts -ac 2 -ar 24000 -ab 80k"  # 2 channels, 24k sample rate, 80k bitrate

# GENERIC OPTIONS
ffopts="$ffopts -movflags faststart"  # Run a second pass moving the index (moov atom) to the beginning of the file.

#
# End of options settings
#________________________

Old_IFS="$IFS"

convert_file ()
{
        file="$1"
        out=${file%.*}.mp4
        srt_file=${file%.*}.srt

        if [ ! -f "$srt_file" ]; then
            srt_file=${file%.*}.srt0

            if [ ! -f "$srt_file" ]; then
                srt_file=""
            fi
        fi

        echo "$file -- $out"

        if [ -n "$srt_file" ]; then
            srt_opts="-c:s mov_text"

            # we are going to embed the srt into the mp4
            echo ffmpeg -i "$file" -i "$srt_file" $ffopts $srt_opts "$out"
            ffmpeg -i "$file" -i "$srt_file" $ffopts $srt_opts "$out"
        else
            echo ffmpeg -i "$file" $ffopts "$out"
            ffmpeg -i "$file" $ffopts "$out"
        fi

        exiftool -tagsfromfile "$file" "-xmp:datetimeoriginal<datetimeoriginal" "$out"
        exiftool "$out" "-mediacreatedate<datetimeoriginal" "-mediamodifydate<datetimeoriginal"
        exiftool "$out" "-FileModifyDate<datetimeoriginal" "-FileCreateDate<datetimeoriginal" "-CreateDate<datetimeoriginal"
}

convert_all_in_dir ()
{
        dir="$1"
        cd "$dir"
        # IFS trick to deal with space in file names
        IFS=$'\n'
        for file in $(ls *.dv) ; do
        IFS="$Old_IFS"
                convert_file "$file"
        IFS=$'\n'
        done
        IFS="$Old_IFS"
        cd -
}

run_on_file_or_dir ()
{
        f="$1"
        if test -d "$f"
        then
                convert_all_in_dir "$f"
        elif [ "`echo $f | grep '\.dv$'`" != "" ]
        then
                convert_file "$f"
        fi
}

#__ if no args __

if [ $# -eq 0 ]
then
        convert_all_in_dir .
        exit 0
fi

#__ otherwise __
# args: list of dv files and/or folders containing dv files

IFS=$'\n'
for f in $*
do
IFS=$Old_IFS
    run_on_file_or_dir "$f"
IFS=$'\n'
done
IFS=$Old_IFS
