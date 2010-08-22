#
# Cookbook Name:: macbook
# Recipe:: default
#
# Copyright 2010, Opscode
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

username = node[:login_name]
usergroup = username

directory "/usr/local"  do
  owner username
  group usergroup
  mode "0755"
  action :create
  not_if "test -d /usr/local"
end

execute "ensure /usr/local permissions" do
  command "chown -R #{username}:#{usergroup} /usr/local"
  not_if do
    uname, p, uid, gid = %x(id -P #{username}).chomp.split(":")
    uid = uid.to_i
    gid = gid.to_i
    user_owned = Dir["/usr/local/*/"].inject(true) do |acc, d|
      s = File.stat(d)
      acc && s.uid == uid && s.gid == gid
    end
    user_owned
  end
end

bash "install homebrew" do
  user username
  group usergroup
  code <<-EOH
  curl -Lsf #{node[:macbook][:brew][:url]} | tar -xvz -C/usr/local --strip 1
  EOH
  cwd     "#{ENV['HOME']}"
  not_if  "test -e /usr/local/bin/brew"
end

execute "brew install git" do
  command "/usr/local/bin/brew install git"
  user username
  group usergroup
end

bash "make homebrew a git repo" do
  code <<-EOH
  git clone #{node[:macbook][:brew][:git_url]} /tmp/homebrew
  mv /tmp/homebrew/.git /usr/local/
  rm -rf /tmp/homebrew
  EOH
  not_if "test -d /usr/local/.git"
  user username
  group usergroup
end

node[:macbook][:brew][:packages].each do |p|
  execute "install homebrew package #{p}" do
    command "/usr/local/bin/brew install #{p}"
    user username
    group usergroup
  end
end

bash "install CPAN easier alternative" do
  code <<-EOH
  wget http://github.com/miyagawa/cpanminus/raw/master/cpanm
  chmod +x cpanm
  EOH
  cwd "/usr/local/bin"
  user username
  group usergroup
  not_if "test -e /usr/local/bin/cpanm"
end

node[:macbook][:perl_modules].each do |pm|
  execute "install Perl module '#{pm}'" do
    command "/usr/local/bin/cpanm #{pm}"
    cwd "#{ENV['HOME']}"
    user username
    group usergroup
  end
end
