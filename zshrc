# Init and options
autoload -U compinit promptinit
autoload -U colors && colors
compinit
promptinit
zstyle ':completion:*' menu select
setopt completealiases
setopt extendedglob
setopt AUTO_PUSHD
unsetopt nomatch
prompt spaceship
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

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
alias :q="exit"
alias aria2c="aria2c --file-allocation=none"
alias btrfs-df="btrfs filesystem df /"
alias btrfs-du="btrfs fi du -s --human-readable"
alias btrfs-list="sudo btrfs subvolume list / -t"
alias cp="cp -av --reflink=auto"
alias df="df -h"
alias du="du -sh"
alias fex="nautilus ."
alias ffmpeg="ffmpeg -hide_banner"
alias ffplay="ffplay -hide_banner"
alias ffprobe="ffprobe -hide_banner"
alias less="less -r"
alias mkdir="mkdir -p"
alias more="less -r"
alias mount="sudo mount"
alias mv="mv -v"
alias neofetch="clear; neofetch"
alias poweroff="sudo poweroff"
alias reboot="sudo reboot"
alias rm="rm -rfv"
alias rsync="rsync -Pva"
alias sl=ls
alias sudo="sudo "
alias umount="sudo umount"
alias xclip="xclip -selection clipboard"
alias zshrc-reload="reload-zshrc"

alias -g sd="~/ScratchArea"
alias -g dl="~/Downloads"
alias -g "..."="../.."
alias -g "...."="../../.."
alias -g "....."="../../../.."

alias disable-bluetooth='sudo systemctl disable bluetooth.service' # alias bluetooth diasble
alias enable-bluetooth='sudo systemctl enable bluetooth.service' # alias bluetooth enable
alias jflap="GTK_THEME=Default jflap"
# Conditional Aliases
if type exa >/dev/null; then
    alias ls="exa -lhgbHm --git "
    alias lst="exa -lhgbHmT --git"
    alias lsa="exa -lhgbHma --git"
else
    alias ls="ls -lh --color"
fi

if type nvim >/dev/null; then
    alias vi="nvim"
    alias vim="nvim"
    export EDITOR=nvim
    export VISUAL=nvim
elif type vim >/dev/null; then
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
if type nvimpager >/dev/null; then
    alias less="nvimpager"
    export PAGER=nvimpager
fi
if type bat >/dev/null; then
    alias cat="PAGER=less bat --color=always"
fi

# Functions
source ~/.zsh/functions.zsh

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
syncboostnote(){
    python ~/boostread.py -p -r -q -d /"$1"
}
runkali(){
    cd ~/VMs && ./start.sh -cdrom kali.iso
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

if [ -d "$HOME/.bin" ]; then
    PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "/ubin" ]; then
    PATH="/ubin:$PATH"
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Environment Variables
export HISTFILE="~/zfile"
export ARCHFLAGS="-arch x86_64"

eval $(ssh-agent) >/dev/null

# Wal
if [ -d ~/.cache/wal/ ]; then
    \cat ~/.cache/wal/sequences 2>/dev/null 
fi

# Plugins
if type thefuck >/dev/null; then
    eval $(thefuck --alias)
fi

if grep -Fxq "arch" /etc/os-release; then
    if [ -f ~/.zsh/plugins/git.plugin.zsh ]; then
        source ~/.zsh/plugins/git.plugin.zsh
    else
        echo "archlinux plugin not loaded"
    fi
fi

if [ -f ~/.zsh/plugins/globalias.plugin.zsh ]; then
    source ~/.zsh/plugins/globalias.plugin.zsh
else
    echo "globalias plugin not loaded"
fi

if [ -f ~/.zsh/plugins/git.plugin.zsh ]; then
    source ~/.zsh/plugins/git.plugin.zsh
else
    echo "git plugin not loaded"
fi

if [ -f ~/.zsh/plugins/you-should-use.plugin.zsh ]; then
    source ~/.zsh/plugins/you-should-use.plugin.zsh
else
    echo "you-should-use plugin not loaded"
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    echo "zsh-syntax-highlighting plugin not loaded"
fi

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    echo "zsh-autosuggestions plugin not loaded"
fi

if [ -f ~/.resh/shellrc ]; then
    source ~/.resh/shellrc
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
