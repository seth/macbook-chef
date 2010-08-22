default[:login_name] = "seth"

default[:macbook][:brew][:tarball] = "http://github.com/mxcl/homebrew/tarball/master"
default[:macbook][:brew][:git_url] = "http://github.com/mxcl/homebrew.git"

default[:macbook][:brew][:packages] = %w{
  ack
  aspell
  coreutils
  ctags
  dos2unix
  gist
  gnupg
  htop
  mg
  nginx
  ngrep
  resty
  tmux
  tree
  wget
  zsh
}

default[:macbook][:perl_modules] = ['JSON']
