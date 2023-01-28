alias la="ls -lA --color"
alias gcl="git clone"
alias open="xdg-open"
alias v="vim"
alias doas="doas "
function save(){
  curl $1 > $2
}

function pywal()
{
  cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/current-theme.conf 
  wpg
  wal -R
  wal-discord -t -b haishoku -o /home/nolife/.config/BetterDiscord/themes/pywal.theme.css
}
