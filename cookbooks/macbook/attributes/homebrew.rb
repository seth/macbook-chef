# use this user if set, otherwise use the node's current_user attribute
default[:login_name] = nil

default[:macbook][:brew][:tarball] = "http://github.com/mxcl/homebrew/tarball/master"
default[:macbook][:brew][:git_url] = "http://github.com/mxcl/homebrew.git"

# Note, git will be installed by the macbook cookbook first,
# but is listed here so that updates will be installed when
# available.
default[:macbook][:brew][:packages] = %w{
  ack
  aspell
  coreutils
  ctags
  dos2unix
  gist
  git
  gnupg
  htop
  jsawk
  mg
  nginx
  ngrep
  resty
  tmux
  tree
  wget
  zsh
}

