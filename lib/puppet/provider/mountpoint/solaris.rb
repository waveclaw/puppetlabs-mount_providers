require 'puppet/type'

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet','provider','genericmountpoint'))

Puppet::Type.type(:mountpoint).provide(:solaris, :parent => Puppet::Provider::Genericmountpoint) do
  desc "Provide a mountpoint type for Solaris"

  commands :mount => "mount", :unmount => "umount"

  confine :operatingsystem => :solaris
  defaultfor :operatingsystem => :solaris

  @mountline =  /^(\S*) on (\S*)(?: (\S+))?/
  def self.mountline
    @mountline
  end
  def mountline
    self.class.mountline
  end


  def self.instances
    mounts = []
    lines = mount.split("\n")
    lines.each do |line|
     if self.mountline.match(line)
       mounts << new(:name    => File.expand_path($1), 
                     :device  => $2, 
                     :options => $3.split(','))
     end
    end
    mounts
  end

  #mk_resource_methods

  private

  @fsflag =  '-F'
  def self.fsflag
    @fsflag
  end
  def fsflag
    self.class.fsflag
  end

  def entry
    line = mount.split("\n").find do |line|
      File.expand_path(line.split.first) == File.expand_path(resource[:name])
    end
    if mountline.match(line)
     {:name => $1, :device => $2, :options => $3}
    else
      {:name => nil }
    end
  end
end
