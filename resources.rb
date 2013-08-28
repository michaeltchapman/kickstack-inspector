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

mappings = {}

res.each { |k, v|
  puts "#############"
  puts k.name
  k.arguments.each { |arg, value|
    puts "==============="
    puts arg
    puts value
    hiera_lkup  = value.arguments[0].to_s.gsub('"', '')
    hiera_default = value.arguments[1].to_s.gsub('"', '')
    puts "compute node: " + hiera.lookup(hiera_lkup, hiera_default, compute_scope).to_s
    puts "control node: " + hiera.lookup(hiera_lkup, hiera_default, control_scope).to_s
    puts "build node: "   + hiera.lookup(hiera_lkup, hiera_default, build_scope).to_s

    if !mappings.has_key?(hiera_lkup) then
      mappings[hiera_lkup] = [k.name]
    else 
      mappings[hiera_lkup].push(k.name)
    end
  }
}

mappings.each { |k, v|
  if v.length != 1 then
    puts "Hiera data: " + k
    v.each { |c|
      puts c
    }
    puts ""
  end
}
