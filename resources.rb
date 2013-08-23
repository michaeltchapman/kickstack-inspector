require 'puppet'
require 'puppet/face'
require 'yaml'
require 'hiera'
require 'find'

Puppet.settings.initialize_global_settings(['--confdir', '/etc/puppet'])
resource = Puppet::Face[:resource_type, :current]

res = resource.search('kickstack')

# Scope will set facts for that hiera run. 
# We probably don't care about much other than the role
compute_scope = {"role" => "openstack", "openstack_role" => "compute"}
control_scope = {"role" => "openstack", "openstack_role" => "controller"}
build_scope = {"role" => "openstack"}

hiera = Hiera.new(:config => "/etc/puppet/hiera.yaml")

res.each { |k, v|
  puts "#############"
  puts k.name
  k.arguments.each { |arg, value|
    puts "==============="
    puts arg
    puts value
    puts value.arguments[0].to_s
    puts value.arguments[1]
    puts "compute node: " + hiera.lookup(value.arguments[0].to_s.gsub('"', ''), value.arguments[1].to_s.gsub('"', ''), compute_scope).to_s
    puts "control node: " + hiera.lookup(value.arguments[0].to_s.gsub('"', ''), value.arguments[1].to_s.gsub('"', ''), control_scope).to_s
    puts "build node: "   + hiera.lookup(value.arguments[0].to_s.gsub('"', ''), value.arguments[1].to_s.gsub('"', ''), build_scope).to_s
  }
}
