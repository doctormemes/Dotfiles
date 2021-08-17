# $ZDOTDIR/.zshrc

# P10K instant prompt. Keep close to top of .zshrc. Code that may require console input
# password prompts, etc. must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-~/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
   source "${XDG_CACHE_HOME:-~/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# this is so ZDOTDIR can be used for any ZSH
# file path validation (even if ZDOTDIR is not set)
ZDOTDIR=${ZDOTDIR:-$HOME}

# use best command line text editor available
if
(( $+commands[nvim] )); then EDITOR_NO_DM='nvim'; elif (( $+commands[vim] )); then EDITOR_NO_DM='vim';
fi

# use best graphical text editor available
if
(( $+commands[subl] )); then EDITOR_DM='subl'
elif (( $+commands[gedit] )); then EDITOR_DM='gedit'
else EDITOR_DM='mousepad'
fi

export ZSH=$ZDOTDIR/.oh-my-zsh

# Preferred editor for session (depends on if the session has a display manager running)
# Feel free to change these if you'd like, I just set them using variables so they would have
# multiple text editors covered, to make sure EDITOR gets set based on the linux environment in use
if
[[ -n $DESKTOP_SESSION ]]; then EDITOR=$EDITOR_DM;
elif [[ -n $SSH_CONNECTION ]] || [[ -z $SESSION_MANAGER ]]; then EDITOR=$EDITOR_NO_DM;
else printf "Error With Editor variable being set..?\n" && EDITOR='nano';
fi

# Set the variable below to anything you'd like to override the
# default EDITOR assignment behavior. Example: export EDITOR='kate'
export EDITOR
# Hyphen-insensitive completion
HYPHEN_INSENSITIVE="true"
# Case-insensitive completion
CASE_SENSITIVE="false"
# Set command history file location and name with below variable.
HISTFILE=$ZDOTDIR/.zsh_history
# You can set one of the optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"
# disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"
# display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="false"
ENABLE_CORRECTION="true"
# change this to false to turn off the help message and neofetch on terminal startup
STARTUP_CONTENT="false"

# Oh-my-zsh enabled plugins
plugins=(
add-to-omz alias-finder
colored-man-pages colorize
common-aliases conda-zsh-completion
cp docker extract fzf
git git-escape-magic
gitignore jump man nordvpn p10k-promptconfig
pip postgres python
sudo thefuck vscode
zsh-autosuggestions
zsh-syntax-highlighting
zsh_reload)

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# P10K is only theme
ZSH_THEME="powerlevel10k/powerlevel10k"
# To customize prompt, run `p10k configure`, edit $ZDOTDIR/.p10k.zsh or set P10K_PROMPT below to a prompt file name in P10K-themes directory.
# For example, below I've set my prompt as "docstheme". The actual file name is .docstheme.zsh. Ensure you follow the same format.
P10K_PROMPT="docstheme"

source $ZSH/oh-my-zsh.sh

[[ -f $ZDOTDIR/.conda_init.zsh ]] && source $ZDOTDIR/.conda_init.zsh

# custom aliases
[[ -f $ZDOTDIR/aliases ]] && . $ZDOTDIR/aliases

# custom functions
[[ -f $ZDOTDIR/functions ]] && . $ZDOTDIR/functions

# Deduplicates path & fpath
[[ -f $ZDOTDIR/.zshenv ]] && {
   dedup_pathvar PATH
   dedup_pathvar FPATH
}

# Terminal startup output (won't run unless $STARTUP_CONTENT is true)
[[ -o interactive && -f $ZDOTDIR/functions ]] && {
   [[ "$STARTUP_CONTENT" = "true" ]] && sinfo || neofetch
}

