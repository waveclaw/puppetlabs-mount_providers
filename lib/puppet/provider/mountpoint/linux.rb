require 'puppet/type'

[ 'type', 'provider' ].each do |path|
  begin
    require "puppet/#{path}/mountpoint"
  rescue LoadError => detail
    require 'pathname' # JJM WORK_AROUND #14073 and #7788
    require Pathname.new(__FILE__).dirname + "../../../" + "puppet/#{path}/mountpoint"
  end
end


Puppet::Type.type(:mountpoint).provide(:linux, :parent => Puppet::Provider::Mountpoint) do
  desc "Provide a mountpoint type for Linux Operating Systems."

  commands :mount => "mount", :unmount => "umount"

  confine :kernel => :linux
  defaultfor :kernel => :linux

  @mountline =  /^(\S*) on (\S*) type (\S+)\s+\((.+)\)\s*$/
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
        mounts << new(:ensure  => :present,
                      :device  => $1,
                      :name    => File.expand_path($2),
                      :fstype  => $3,
                      :options => $4.split(","))
      end
    end
    mounts
  end

  #mk_resource_methods

  private

  @fsflag = '-t'
  def self.fsflag
    @fsflag
  end
  def fsflag
    self.class.fsflag
  end

  def entry
    line = mount.split("\n").find do |line|
      File.expand_path(line.split[2]) == File.expand_path(resource[:name])
    end
    if (! line.nil?) and mountline.match(line)
      { :device => $1, :name => $2, :fstype => $3, :options => $4.split(",") }
    else
      { :name => nil }
    end
  end
end
