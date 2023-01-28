(cat $HOME/.config/wpg/sequences &)
alias ls="ls --color"
autoload -U colors && colors
#PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
PS1="%B%{$fg[red]%}[%{$fg[magenta]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[yellow]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

 ## Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.


export HISTFILE=~/.histfile
export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

# The meaning of these options can be found in man page of `zshoptions`.
setopt HIST_IGNORE_ALL_DUPS  # do not put duplicated command into history list
setopt HIST_SAVE_NO_DUPS  # do not save duplicated command
setopt HIST_REDUCE_BLANKS  # remove unnecessary blanks
setopt INC_APPEND_HISTORY_TIME  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time


### KEY_BINDINGS ###
# vim: ts=4 sw=4
# INS, DEL, etc.
function _delete-char-or-region() {
	[[ $REGION_ACTIVE -eq 1 ]] && zle kill-region || zle delete-char
}
zle -N _delete-char-or-region
bindkey ${terminfo[kich1]}	quoted-insert
bindkey ${terminfo[kdch1]}	_delete-char-or-region
bindkey ${terminfo[khome]}	beginning-of-line
bindkey ${terminfo[kend]}	end-of-line
bindkey ${terminfo[kpp]}	up-line-or-search
bindkey ${terminfo[knp]}	down-line-or-search
bindkey '\e[1~'				beginning-of-line		# HOME in putty
bindkey '\e[4~'				end-of-line				# END in putty
bindkey "\e[H"				beginning-of-line
bindkey "\e[F"				end-of-line
bindkey -e
#Easy access to previous args
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "\em" copy-earlier-word

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Completion
zmodload zsh/complist
bindkey -M menuselect ${terminfo[kcbt]}	reverse-menu-complete	# shift-tab
bindkey -M menuselect ${terminfo[kpp]}	backward-word
bindkey -M menuselect ${terminfo[knp]}	forward-word
bindkey -M menuselect '\eo'				accept-and-infer-next-history
bindkey -M isearch '\e'		accept-search
bindkey '\ee'				end-of-list
bindkey '\eq'				push-line-or-edit

# Misc
bindkey '^[p'				copy-prev-shell-word
bindkey -s ${terminfo[kf5]}	'\C-U unset _custom_zsh_config_loaded; source ~/.zshrc\n'

# Quickly jump right after the first word (e.g. to insert switches)
function _after-first-word() {
	zle beginning-of-line
	zle forward-word
}
zle -N _after-first-word
bindkey '\C-X1' _after-first-word

# Extended word movements/actions
autoload -Uz select-word-style
function _zle-with-style() {
	setopt localoptions
	unsetopt warn_create_global
	local style
	[[ -n "$3" ]] && WORDCHARS=${WORDCHARS/$3}
	[[ $BUFFER =~ '^\s+$' ]] && style=shell || style=$2
	select-word-style $style
	zle $1
	[[ -n "$3" ]] && WORDCHARS="${WORDCHARS}${3}"
	select-word-style normal
}

function _backward-word()		{ _zle-with-style backward-word			bash }
function _forward-word()		{ _zle-with-style forward-word			bash }
function _backward-arg()		{ _zle-with-style backward-word			shell }
function _forward-arg()			{ _zle-with-style forward-word			shell }
function _backward-kill-arg()	{ _zle-with-style backward-kill-word 	shell }
function _forward-kill-arg()	{ _zle-with-style kill-word 			shell }
function _backward-kill-word()	{ _zle-with-style backward-kill-word 	normal }
function _backward-kill-path()	{ _zle-with-style backward-kill-word 	normal	'/' }

zle -N _backward-word
zle -N _forward-word
zle -N _backward-arg
zle -N _forward-arg
zle -N _backward-kill-arg
zle -N _forward-kill-arg
zle -N _backward-kill-word
zle -N _backward-kill-path

# optionally support putty-style cursor keys (application mode when ctrl is pressed).
# this is kind of broken in normal linux terminals that often use application mode by
# default, so we have to make it opt-in. if you use putty, you may want to patch it to
# send proper escape sequences for ctrl/alt/shift+cursor key combinations.
if [[ _custom_zsh_putty_cursor_keys == 1 ]]; then
	bindkey '\C-[OD'	_backward-word	# ctrl-left
	bindkey '\C-[OC'	_forward-word	# ctrl-right
fi

bindkey "\e[1;5D"	_backward-word		# ctrl-left
bindkey "\e[1;5C"	_forward-word		# ctrl-right
bindkey '\e\e[D'	_backward-arg		# alt-left
bindkey '\e[1;3D'	_backward-arg		# alt-left
bindkey '\e[1;3C'	_forward-arg		# alt-right
bindkey '\e\e[C'	_forward-arg		# alt-right
bindkey '\e\C-?'	_backward-kill-arg	# alt-backspace
bindkey '\e\e[3~'	_forward-kill-arg	# alt-del
bindkey '\e[3;3~'	_forward-kill-arg	# alt-del
bindkey '\C-w'		_backward-kill-word
bindkey '\C-f'		_backward-kill-path

# Allow more powerful history-i-search (multiple uses in the same line)
autoload -Uz narrow-to-region
function _history-incremental-preserving-pattern-search-backward() {
	local state tmp
	MARK=CURSOR  # magick, else multiple ^R don't work
	narrow-to-region -p "$LBUFFER${BUFFER:+>>}" -P "${BUFFER:+<<}$RBUFFER" -S state
	zle end-of-history
	zle history-incremental-pattern-search-backward
	narrow-to-region -R state
}
zle -N _history-incremental-preserving-pattern-search-backward
bindkey '^r' _history-incremental-preserving-pattern-search-backward
bindkey -M isearch '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
  if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
  else
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
  fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

#zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

if [[ ${COMPLETION_WAITING_DOTS:-false} != false ]]; then
  expand-or-complete-with-dots() {
    # use $COMPLETION_WAITING_DOTS either as toggle or as the sequence to show
    [[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{yellow}…%f"
    # turn off line wrapping and print prompt-expanded "dot" sequence
    printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  # Set the function as the default tab completion widget
  bindkey -M emacs "^I" expand-or-complete-with-dots
  bindkey -M viins "^I" expand-or-complete-with-dots
  bindkey -M vicmd "^I" expand-or-complete-with-dots
fi

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

### PLUGINS ###
fpath=(/home/nolife/.zsh_plugs/zsh-completions/src $fpath)
source /home/nolife/.zsh_plugs/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 
source /home/nolife/.zsh_plugs/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh
source /home/nolife/.zsh_plugs/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/nolife/.zsh_plugs/funcs.zsh 
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7aa2f7"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

