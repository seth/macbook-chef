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

username = node[:login_name] || node[:current_user]
user_uid = node[:etc][:passwd][username]["uid"]
user_gid = node[:etc][:passwd][username]["gid"]

directory "/usr/local"  do
  owner username
  group user_gid
  mode "0755"
  action :create
  not_if "test -d /usr/local"
end

execute "ensure /usr/local permissions" do
  command "chown -R #{username}:#{user_gid} /usr/local"
  not_if do
    user_owned = Dir["/usr/local/*/"].inject(true) do |acc, d|
      s = File.stat(d)
      acc && s.uid == user_uid && s.gid == user_gid
    end
    user_owned
  end
end

bash "install homebrew" do
  user username
  group user_gid
  code <<-EOH
  curl -Lsf #{node[:macbook][:brew][:url]} | tar -xvz -C/usr/local --strip 1
  EOH
  cwd     "#{ENV['HOME']}"
  not_if  "test -e /usr/local/bin/brew"
end

execute "brew install git" do
  command "/usr/local/bin/brew install git"
  user username
  group user_gid
end

bash "make homebrew a git repo" do
  code <<-EOH
  git clone #{node[:macbook][:brew][:git_url]} /tmp/homebrew
  mv /tmp/homebrew/.git /usr/local/
  rm -rf /tmp/homebrew
  EOH
  not_if "test -d /usr/local/.git"
  user username
  group user_gid
end

execute "update homebrew package repository" do
  command "/usr/local/bin/brew update"
  user username
  group user_gid
end

node[:macbook][:brew][:packages].each do |p|
  execute "install homebrew package #{p}" do
    command "/usr/local/bin/brew install #{p}"
    user username
    group user_gid
  end
end

directory "#{ENV['HOME']}/bin" do
  owner username
  group user_gid
  mode "0755"
end

cookbook_file "#{ENV['HOME']}/bin/jspp" do
  source "jspp"
  owner username
  group user_gid
  mode "0755"
end

