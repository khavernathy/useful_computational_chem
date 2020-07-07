#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2016 Felipe Silveira de Souza Schneider
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#? xyzsplit 0.3
#?
#? Usage: xyzsplit pattern file.xyz [file.xyz...]
#?
#?   -h  show this message
#?   -v  show version
#?
#? Warning: xyzsplit assumes you are dealing with UNIX-style text files (lines
#?   end with LF). If it is not the case, a tool such as dos2unix can handle
#?   the conversion for you.

while getopts ":hv" opt "$@"
  do
    case $opt in
      h)  # help
        grep "^#?" "$0" | cut -c 4-
        exit 0
        ;;
      v)  # version
        grep "^#? xyzsplit" "$0" | cut -c 4-
        exit 0
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
  done

# recover $@
shift $((OPTIND-1))

# recover pattern and give me back my other arguments
pattern=$1
shift

# pattern is a comma-separated list of numbers, we should make it
# space-separated first
pattern=${pattern//,/ }

# we modify the variable pattern in what follows, but we need eventually the
# original back, so we make a backup here
original_pattern=$pattern

for xyzfile in "$@"
  do
    if [ -r "$xyzfile" ]
      then  # xyzfile exists and is readable
        # make sure it conforms to Unix standards
        dos2unix "$xyzfile"

        # parse the xyz comment
        comment=$(head -n2 "$xyzfile" | tail -n1)

        # we ignore any charge and multiplicity definitions in comment
        comment=$(echo "$comment" | sed -e 's/q=[0-9][0-9]*//g' -e 's/S=[0-9][0-9]*//g')

        # we check first the number of atoms in the file
        natoms=$(head -n1 "$xyzfile")
        natoms_in_frags=$(echo "$pattern" | sed -e 's/ /+/g' | bc)

        if (( natoms < natoms_in_frags ))
	  then  # we check if a fragmentation of this size is possible
	    echo "  $xyzfile has $natoms but you are asking for a fragmentation with $natoms_in_frags atoms!"
            continue
          else
            if (( natoms > natoms_in_frags ))
              then  # if there is room for one more fragment, we do it
                natoms_left=$(( natoms - natoms_in_frags ))
                pattern="$pattern $natoms_left"
              fi
          fi

        # now we need to know how many fragments we have been asked for
        nfrags=$(echo "$pattern" | wc -w)

        # we must keep track of fragments and their lines in what follows
        frag=0
        i=0
        nlines=$(echo "$pattern" | cut -d " " -f 1)

        # get a name for the first fragment
        fragxyzfile=${xyzfile/.xyz}_f1.xyz

        # wipe out the file of the first fragment, give number of atoms and comment
        echo "$nlines" > "$fragxyzfile"
        echo "$comment" >> "$fragxyzfile"

        # read the file line by line, skipping the first two lines
        tail -n+3 "$xyzfile" | while read line
          do
            # write line to the right file
            echo "$line" >> "$fragxyzfile"

            # keep track of line number
            i=$(( i + 1))

            if (( i >= nlines ))
              then  # maximum number of lines reached
                # report to the user
                echo "  $fragxyzfile created"

                frag=$(( frag + 1 ))
                i=0
                nlines=$(echo "$pattern" | cut -d " " -f $(( frag + 1)))

                # get a name for the fragment
                fragxyzfile=${xyzfile/.xyz}_f$(( frag + 1 )).xyz

                if (( frag < nfrags ))
                  then
                    # wipe out the file of the fragment, give number of atoms and comment
                    echo "$nlines" > "$fragxyzfile"
                    echo "$comment" >> "$fragxyzfile"
                  fi
              fi
          done

        # we regenerate the original pattern here because it may have changed
        # and the next xyz files need it back
        pattern=$original_pattern
      else  # xyzfile does not exist or is not readable
        echo "  $xyzfile does not exist or is not readable."
        exit 1
      fi
  done
