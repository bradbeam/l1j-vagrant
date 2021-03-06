l1j_dir = "/vagrant/l1j"
l1j_db_name = "l1jdb"
l1j_lock_dir = "/vagrant/lock"
l1j_db_dir = "#{l1j_dir}/db"

package "ant"

execute "l1j-clone" do
  command "git clone #{node["l1j"]["repository_url"]} #{l1j_dir}"
  creates l1j_dir
end

execute "l1j-create-database" do
  command "mysql --user=root --password=#{node["mysql"]["server_root_password"]} --execute \"CREATE DATABASE IF NOT EXISTS #{l1j_db_name};\""
end

ruby_block "l1j-edit-config-server-properties" do
  block do
    file = Chef::Util::FileEdit.new("#{l1j_dir}/config/server.properties")
    file.search_file_replace(/Password=\r\n/, "Password=#{node["mysql"]["server_root_password"]}\r\n")
    file.write_file
  end
end

directory l1j_lock_dir do
  owner "root"
  group "root"
  mode 00755
end

%w{
  l1jdb_m7.sql
  update_064.sql
  update_065.sql
  update_066.sql
  update_067.sql
  update_068.sql
  update_069.sql
  update_070.sql
  update_071.sql
  update_072.sql
}.each do |file|
  lock_file = "#{l1j_lock_dir}/#{file}.lock"
  execute "l1j-execute-db-file-#{file}" do
    cwd l1j_db_dir
    command "mysql --user=root --password=#{node["mysql"]["server_root_password"]} #{l1j_db_name} < #{file}"
    not_if {
      ::File.exists?(lock_file)
    }
  end
  file lock_file do
    owner "root"
    group "root"
    mode 00644
  end
end

execute "l1j-untar-maps" do
  cwd "#{l1j_dir}/maps"
  command "tar xf maps.tar.bz2"
end
