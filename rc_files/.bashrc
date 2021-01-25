# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

#setting the color prompt (I did this)
color_prompt=yes

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=80000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF --group-directories-first'
alias mv='mv -i'


# CUSTOM STUFF ====================================================================
# CUSTOM ALIASES -------------------------------------------------

alias brcr='. ~/.bashrc'
alias op='xdg-open'
alias cdd='cd ..'
alias lah='ls -lah'
alias hist='history'
alias sus='sudo pm-suspend'
alias reb='sudo reboot'
alias powoff='sudo poweroff'
alias soff='xset dpms force off' # screen off
alias son='sudo xset dpms force on' # screen on
alias sfails='sudo lastb -ad -F -w' # view failed ssh attempts
alias slogs='sudo last -ad -F -w'  # view successful ssh logins
alias watch='watch '
alias h='history'
alias gcache='git config --global credential.helper cache' # make git push easier

# SOFTWARE EXECUTABLES ------------------------------------------
alias bb='baobab'


# CUSTOM FUNCTIONS
# listpk: lists packages in order of size
function listpk {
	dpkg-query -W --showformat='${Installed-Size;10}\t${Package}\n' | sort -k1,1n
}

# opall: opens all files with supplied filetype in current dir (e.g. opall doc opens all .doc files)
function opall {
    ls -b *.$1 | xargs -n 1 xdg-open
}

# dropem adds specific IP (arg 1) to the auto-fail ssh list
function dropem {
    sudo iptables -A INPUT -s $1 -j DROP
}

# startup -- for mysql, ssh, and web server startup.
function startup {
	sudo service apache2 start;
	sudo service mysql start;
	sudo service ssh start;
}

# averages values in a single-column file $1
function avrg {
	echo "getting average of "$1
	awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' < $1
	#cat $1 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }';
}

# usage reports RAM/CPU usage at time of request.
function usage {
	echo "";
	echo "Current system usage for RAM, CPU, and HD"

	ps axu | awk '{if (NR!=1) {printf("%5.3f\n",$6*1024/1000/1000)}}' > mem_use.tmp # contains list of all processes and their memory use in MB
	cat mem_use.tmp | awk '{sum+=$1} END {printf("%.2f MB RAM occupied = %3.2f%% used\n",sum,sum/1000/33.5007449088*100)}'
	rm mem_use.tmp                                                                                                
                                                                                                              
	ps axu | awk '{if (NR!=1) {printf("%3.1f\n",$3)}}' > cpu_use.tmp # contains list of all pocesses by cpu use %  
	cat cpu_use.tmp | awk '{sum+=$1} END {printf("%3.2f%% cpu being used\n",sum/8.0)}'                            
	rm cpu_use.tmp

	echo "";
	pydf;
	echo "";
	ps au;
}

function lsprog {
    # use "cpu" or "mem" as $1
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%$1 | head -20
}

function dut {
	# a cooler du which sorts by directory size and limits to --max-depth=1
	echo 'Total dir size (GB)             dir'
	du -d 1 | sort -nk1 | awk {'printf("%15f %50s\n",$1/1024/1024,$2)'}
}

function gl {
        # gl is for "grep line" -- pull specific lines from a file as desired.
        # supply filename as $1 then lines to print as $2 etc.
        #e.g.
        # gl myfile.txt 1 4 30 31 42
        filename=$1;
        str="";
        for var in "$@"
        do
                if [[ $var != $1 ]]; then
                        if [[ $var == $2 ]]; then
                                str=$str"NR == "$var
                        else
                                str=$str" || NR == "$var
                        fi
                fi
        done
#       echo $str
        cat $filename | awk "$str"
}

function dellast {
    # deletes last column in file (arg1)
    awk 'NF{NF-=1};1' <$1 >output
    echo "wrote last-col-deleted file to output."
}

# END CUSTOM STUFF ================================================================

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias gitclean='git fetch; git reset --hard; git clean -xdf'
alias gitundo='git stash save --keep-index --include-untracked'
alias githardreset='git reset --hard $1 && git push --force'
alias gitpullall='for i in $(git branch -r | grep -vE "HEAD|master"); do git branch --track ${i#*/} $i; done; git fetch --all; git pull --all;'
