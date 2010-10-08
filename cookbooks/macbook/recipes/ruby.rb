# Borrowed heavily from http://github.com/atmos/cinderella

username = node[:login_name] || node[:current_user]
user_uid = node[:etc][:passwd][username]["uid"]
##user_gid = node[:etc][:passwd][username]["gid"]
user_gid = "seth"

DEFAULT_RUBY_VERSION = "1.8.7-p302"

rvm_init = 'source "$HOME/.rvm/scripts/rvm"'

Chef::Log.info "username: #{username}"
Chef::Log.info "user_gid: #{user_gid}"

bash "install rvm" do
  user username
  group user_gid
  code <<-EOH
    curl -s -O http://rvm.beginrescueend.com/releases/rvm-install-head && \
    chmod u+x ./rvm-install-head && \
    ./rvm-install-head
    rm -f rvm-install-head
  EOH
 not_if "test -d #{ENV['HOME']}/.rvm"
  cwd ENV['HOME']
end


bash "updating rvm to the latest stable version" do
  user username
  group user_gid
  code "#{rvm_init} && rvm update --head > ~/.rvm-update.log 2>&1"
end

bash "installing ruby" do
  user username
  group user_gid
  code <<-EOH
    #{rvm_init} && rvm install #{DEFAULT_RUBY_VERSION} -C \
      --with-openssl-dir=/usr/local \
      --with-readline-dir=/usr/local && \
    # rvm install exits 0 even if build fails :-(
    rvm list |grep -q #{DEFAULT_RUBY_VERSION}
  EOH
  not_if "#{rvm_init} && rvm list|grep -q '#{DEFAULT_RUBY_VERSION}'"
end

bash "set default rvm ruby" do
  user username
  group user_gid
  code "#{rvm_init} && rvm use #{DEFAULT_RUBY_VERSION} --default"
  not_if "#{rvm_init} && which ruby|grep -q rvm"
end

cookbook_file "#{ENV['HOME']}/.rvm/gemsets/default.gems" do
  source "default.gems"
  owner username
  group user_gid
end

bash "install default gems" do
  user username
  group user_gid
  code " #{rvm_init} && rvm gemset load ~/.rvm/gemsets/default.gems"
end

# template "#{ENV['HOME']}/.gemrc" do
#   source "dot.gemrc.erb"
# end

# template "#{ENV['HOME']}/.rdebugrc" do
#     source "dot.rdebugrc.erb"
# end
