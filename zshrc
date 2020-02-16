# Init
autoload -U compinit promptinit
autoload -U colors && colors
compinit
promptinit

# Keybinds
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete



# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

# Aliases
alias rm="rm -rfv"
alias cp="cp -av --reflink=auto"
alias mv="mv -v"
alias du="du -sh"
alias mkdir="mkdir -p"
alias less="less -r"
alias more="less -r"
alias reboot="sudo reboot"
alias poweroff="sudo poweroff"
alias btrfs-du="btrfs fi du -s --human-readable"
alias btrfs-list="sudo btrfs subvolume list / -t"
alias btrfs-df="btrfs filesystem df /"
alias sudo="sudo "
alias rsync="rsync -Pva"
alias mount="sudo mount"
alias umount="sudo umount"
alias feh-svg="feh --magick-timeout 1"
alias neofetch="clear; neofetch"
alias aria2c="aria2c --file-allocation=none"
alias zshrc-reload="reload-zshrc"
alias xclip="xclip -selection clipboard"
alias df="df -h"
alias fex="nautilus ."
alias ffprobe="ffprobe -hide_banner"
alias ffmpeg="ffmpeg -hide_banner"
alias ffplay="ffplay -hide_banner"

alias -g sd="~/ScratchArea"
alias -g dl="~/Downloads"
alias -g "..."="../.."

alias disable-bluetooth='sudo systemctl disable bluetooth.service' # alias bluetooth diasble
alias enable-bluetooth='sudo systemctl enable bluetooth.service' # alias bluetooth enable

alias jflap="GTK_THEME=Default jflap"

eval $(thefuck --alias)

alias sl=ls

# Conditional Aliases
if type exa > /dev/null
then
    alias ls="exa -lhgbHm --git "
    alias lst="exa -lhgbHmT --git"
    alias lsa="exa -lhgbHma --git"
else
    alias ls="ls -lh --color"
fi

if type nvim > /dev/null
then
    alias vi="nvim"
    alias vim="nvim"
    export EDITOR=nvim
    export VISUAL=nvim
elif type vim > /dev/null
then
    alias vi="vim"
    alias nvim="vim"
    export EDITOR=vim
    export VISUAL=vim
else
    alias vim="vi"
    alias nvim="vi"
    export EDITOR=vi
    export VISUAL=vi
fi
if type nvimpager > /dev/null
then
    alias less="nvimpager"
    export PAGER=nvimpager
fi
if type bat > /dev/null
then
    alias cat="PAGER=less bat --color=always"
fi


# ZSH Style and Options
zstyle ':completion:*' menu select
setopt completealiases
setopt extendedglob
unsetopt nomatch
prompt spaceship
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Functions
mkcdir() {
    mkdir -p -- "$1" &&
        cd -P -- "$1"
    }

reload-zshrc() {
source ~/.zshrc
}

lls() {
    clear
    ls
}

borderless() {
    xprop -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"
}

borderless-undo() {
xprop -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x1, 0x0, 0x0"
}

magnet-info() {
wd=`pwd`
cd /tmp
hash=$(echo "$1" | grep -oP "(?<=btih:).*?(?=&)")
echo "Magnet hash: $hash"
aria2c --bt-metadata-only=true --bt-save-metadata=true "$1"
aria2c "$hash.torrent" -S
cd $wd
}

ffcompare() {
    ffplay $1 & ffplay $2
}

vmaf() {
    ffmpeg -hwaccel auto -i $1 -hwaccel auto -i $2 -lavfi libvmaf="model_path=/usr/share/model/vmaf_v0.6.1.pkl" -an -f null -
}

ex() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.tar.xz)    tar xf $1    ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

syncboostnote(){
    python ~/boostread.py -p -r -q -d /"$1"
}

runkali(){
    cd ~/VMs && ./start.sh -cdrom kali.iso
}

# esc-esc sudo
sudo-command-line() {
[[ -z $BUFFER ]] && zle up-history
if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
elif [[ $BUFFER == $EDITOR\ * ]]; then
    LBUFFER="${LBUFFER#$EDITOR }"
    LBUFFER="sudoedit $LBUFFER"
elif [[ $BUFFER == vim\ * ]]; then
    LBUFFER="${LBUFFER#vim }"
    LBUFFER="sudoedit $LBUFFER"
elif [[ $BUFFER == sudoedit\ * ]]; then
    LBUFFER="${LBUFFER#sudoedit }"
    LBUFFER="$EDITOR $LBUFFER"
else
    LBUFFER="sudo $LBUFFER"
fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line




# PATH
if [ -d /etc/zsh/zshrc.d ]; then
    for file in /etc/zsh/zshrc.d/*; do
        source $file
    done
fi

if [ -d "$HOME/.bin" ] ; then
    PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "/ubin" ] ; then
    PATH="/ubin:$PATH"
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Environment Variables
export HISTFILE="~/zfile"
export ARCHFLAGS="-arch x86_64"

eval $(ssh-agent) > /dev/null

(\cat ~/.cache/wal/sequences 2>/dev/null &)

# Sourcing Plugins

#if [ -f ~/.zsh/vi-mode.plugin.zsh ]; then
#    source ~/.zsh/vi-mode.plugin.zsh
#else
#    echo "vi-mode plugin not loaded"
#fi

if grep -Fxq "arch" /etc/os-release; then
    if [ -f ~/.zsh/git.plugin.zsh ]; then
        source ~/.zsh/git.plugin.zsh
    else
        echo "archlinux plugin not loaded"
    fi
fi

if [ -f ~/.zsh/globalias.plugin.zsh ]; then
    source ~/.zsh/globalias.plugin.zsh
else
    echo "globalias plugin not loaded"
fi

if [ -f ~/.zsh/git.plugin.zsh ]; then
    source ~/.zsh/git.plugin.zsh
else
    echo "git plugin not loaded"
fi

if [ -f ~/.zsh/you-should-use.plugin.zsh ]; then
    source ~/.zsh/you-should-use.plugin.zsh
else
    echo "you-should-use plugin not loaded"
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    echo "zsh-syntax-highlighting plugin not loaded"
fi

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    echo "zsh-autosuggestions plugin not loaded"
fi

if grep -Fxq "arch" /etc/os-release; then
    if [ -f /usr/share/doc/pkgfile/command-not-found.zsh ]; then
        source /usr/share/doc/pkgfile/command-not-found.zsh
    else
        echo "pkgfile plugin not loaded"
    fi
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000
setopt SHARE_HISTORY


fpath=($fpath "/home/joe/.zfunctions")
