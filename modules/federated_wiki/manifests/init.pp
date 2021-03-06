class federated_wiki {
	include rubygems
	include rubygems::common_dependencies

	$git_repository = 'git://github.com/WardCunningham/Smallest-Federated-Wiki.git'
	$install_dir = '/var/www/federated-wiki'

	$build_dependencies = [
		'libxml2-devel', 'libxslt-devel'
	]

	package { [$build_dependencies]:
		ensure => installed,
	}

	package { 'bundler':
		ensure => installed,
		provider => gem,
		require => [Class['rubygems::common_dependencies'], Package[$build_dependencies]],
	}

	exec { 'bundle-install':
		unless => 'bundle check',
		command => 'bundle install',
		cwd => "${install_dir}",
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => [Package['bundler'], Exec['git-clone']],
	}

	package { 'git':
		ensure => latest,
	}

	exec { 'git-clone':
		command => "git clone \"${git_repository}\" \"${install_dir}\"",
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		creates => "${install_dir}",
		require => Package['git'],
	}

	federated_wiki::apache { 'federated_wiki':
		install_dir => "${install_dir}",
		require => Exec['bundle-install'],
	}
}
