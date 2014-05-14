require 'puppet/type'

[ 'type', 'provider' ].each do |path|
  begin
    require "puppet/#{path}/mountpoint"
  rescue LoadError => detail
    require 'pathname' # JJM WORK_AROUND #14073 and #7788
    require Pathname.new(__FILE__).dirname + "../../../" + "puppet/#{path}/mountpoint"
  end
end

Puppet::Type.type(:mountpoint).provide(:solaris, :parent => Puppet::Provider::Mountpoint) do
  desc "Provide a mountpoint type for Solaris"

  commands :mount => "mount", :unmount => "umount"

  confine :operatingsystem => :solaris
  defaultfor :operatingsystem => :solaris

  @mountline =  '^(\S*) on (\S*)(?: (\S+))?'
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
     line =~ /#{self.mountline}/
     mounts << new(:name    => File.expand_path($1), 
                   :device  => $2, 
                   :options => $3.split(','))
    end
    mounts
  end

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
    line =~ /#{mountline}/
    {:name => $1, :device => $2, :options => $3}
  end
end
