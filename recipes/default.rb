# Install required packages
node[:l1j][:required_packages].each do | req_package |
  package req_package do
    action :install
  end
end

# Clone the repository as the
# specified tag
git node[:l1j][:install_dir] do
  repository node[:l1j][:repository_url]
  revision node[:l1j][:tag]
  action :sync
  notifies :run, "execute[Extract maps]"
end

# Create the database
bash "Create database" do
  code "mysql --user=root --password=#{node[:mysql][:server_root_password]} --execute \"CREATE DATABASE IF NOT EXISTS #{node[:l1j][:dbname]};\""
end

# Drop down config file templates
template "#{node[:l1j][:install_dir]}/config/server.properties" do
  source 'server.properties.erb'
  action :create
end

[ node[:l1j][:db_dir], node[:l1j][:lock_dir] ].each do |dir|
  directory dir do
    owner node[:l1j][:owner]
    mode 00755
    action :create
  end
end

# Create an array of all the sql files to
# execute them the same way
# and ensure the sql_base is executed first
sql_files = [ node[:l1j][:sql_base] ] + node[:l1j][:sql_updates]

sql_files.each do |sql_file|
  lock_file = "#{node[:l1j][:install_dir]}/#{node[:l1j][:lock_dir]}/#{sql_file}.lock"

  bash "Executing sqlfile: #{sql_file}" do
    cwd "#{node[:l1j][:install_dir]}/#{node[:l1j][:db_dir]}"
    code "mysql --user=root --password=#{node[:mysql][:server_root_password]} #{node[:l1j][:dbname]} < #{sql_file}"
    not_if { ::File.exists?(lock_file) }
    notifies :create, "file[#{lock_file}]", :immediately
  end

  file lock_file do
    owner node[:l1j][:owner]
    mode 00644
    action :nothing
  end
end

execute "Extract maps" do
  cwd "#{node[:l1j][:install_dir]}/maps"
  command "tar xf maps.tar.bz2"
  action :nothing
end
