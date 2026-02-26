#!/usr/bin/env fish
# ============================================================================
# Fish Shell Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Theme
# ----------------------------------------------------------------------------
set -g theme catppuccin-mocha

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx PAGER bat
set -gx BAT_THEME "Catppuccin Mocha"

# Format man pages with bat
set -gx MANROFFOPT "-c"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# ----------------------------------------------------------------------------
# PATH Configuration
# ----------------------------------------------------------------------------
# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add depot_tools to PATH (if you use Chromium development)
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end

# ----------------------------------------------------------------------------
# Greeting
# ----------------------------------------------------------------------------
function fish_greeting
    fastfetch
end

# ----------------------------------------------------------------------------
# Command Duration Notifications (done plugin)
# ----------------------------------------------------------------------------
# Source done plugin for command completion notifications
if test -f /usr/share/cachyos-fish-config/conf.d/done.fish
    source /usr/share/cachyos-fish-config/conf.d/done.fish
end

# Configure done plugin
set -U __done_min_cmd_duration 10000  # 10 seconds
set -U __done_notification_urgency_level low

# ----------------------------------------------------------------------------
# History
# ----------------------------------------------------------------------------
# Enhanced history command with timestamps
function history
    builtin history --show-time='%F %T '
end

# ----------------------------------------------------------------------------
# Bang Bang (!! and !$) Support
# ----------------------------------------------------------------------------
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

# Key bindings for !! and !$
if test "$fish_key_bindings" = fish_vi_key_bindings
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

# ----------------------------------------------------------------------------
# Utility Functions
# ----------------------------------------------------------------------------
# Backup files
function backup --argument filename
    cp $filename $filename.bak
end

# Enhanced copy function
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (echo $argv[1] | string trim --right --chars=/)
        set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Create directory and cd into it
function mkcd --description "Create directory and enter it"
    mkdir -p $argv[1]; and cd $argv[1]
end

# Universal archive extractor
function extract --description "Extract any archive"
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# ----------------------------------------------------------------------------
# Aliases - File Management
# ----------------------------------------------------------------------------
# eza (modern ls replacement)
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.='eza -a | grep -e "^\."'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Modern tool replacements
alias cat='bat'
alias find='fd'

# ----------------------------------------------------------------------------
# Aliases - System & Package Management
# ----------------------------------------------------------------------------
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias mirror='sudo cachyos-rate-mirrors'
alias grubup='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# Package info
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# System monitoring
alias hw='hwinfo --short'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias jctl='journalctl -p 3 -xb'

# ----------------------------------------------------------------------------
# Aliases - Utilities
# ----------------------------------------------------------------------------
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rg='rg --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# Archive shortcuts
alias tarnow='tar -acf'
alias untar='tar -zxvf'

# Misc
alias wget='wget -c'
alias tb='nc termbin.com 9999'
alias please='sudo'

# ----------------------------------------------------------------------------
# Aliases - Quick Config Access
# ----------------------------------------------------------------------------
alias fishconfig='$EDITOR ~/.config/fish/config.fish'
alias reload='source ~/.config/fish/config.fish'

# ----------------------------------------------------------------------------
# fzf Integration (if installed)
# ----------------------------------------------------------------------------
if type -q fzf
    fzf --fish | source
    
    # fzf configuration
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"
    
    # Use fd for fzf if available
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    end
end

# ----------------------------------------------------------------------------
# Starship Prompt
# ----------------------------------------------------------------------------
if type -q starship
    starship init fish | source
end

# ----------------------------------------------------------------------------
# Zoxide (smart directory jumping)
# ----------------------------------------------------------------------------
if type -q zoxide
    zoxide init fish | source
    alias cd='z'
    alias cdi='zi'
end

# ----------------------------------------------------------------------------
# Source local config
# ----------------------------------------------------------------------------
if test -f ~/.fish_profile
    source ~/.fish_profile
end
