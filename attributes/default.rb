default[:l1j][:repository_url] = 'https://github.com/l1j/en'
default[:l1j][:tag] = 'master'

default[:l1j][:owner] = 'vagrant'

default[:l1j][:install_dir] = '/home/vagrant/l1j-en'
# Path relative to install_dir
default[:l1j][:db_dir] = 'db'
# Path relative to install_dir
default[:l1j][:lock_dir] = 'db'

default[:l1j][:dbname] = 'l1jdb'
default[:l1j][:sql_base] = 'l1jdb_m7.sql'
default[:l1j][:sql_updates] = [
          'update_064.sql', 'update_065.sql', 'update_066.sql',
          'update_067.sql', 'update_068.sql', 'update_069.sql',
          'update_070.sql', 'update_071.sql', 'update_072.sql',
          'update_073.sql', 'update_074.sql', 'update_075.sql',
          'update_076.sql' ]

default[:l1j][:required_packages] = [ 'ant', 'git' ]
