((
  artii $(hostname | sed "s/\.local//")
  fortune | cowsay -f dragon
  ) | lolcat)
