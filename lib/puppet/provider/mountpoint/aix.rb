require 'puppet/type'

[ 'type', 'provider' ].each do |path|
  begin
    require "puppet/#{path}/mountpoint"
  rescue LoadError => detail
    require 'pathname' # JJM WORK_AROUND #14073 and #7788
    require Pathname.new(__FILE__).dirname + "../../../" + "puppet/#{path}/mountpoint"
  end
end


Puppet::Type.type(:mountpoint).provide(:aix, :parent => Puppet::Provider::Mountpoint) do
  desc "Provide a mountpoint type for the AIX OS"

  commands :mount => "mount", :unmount => "umount"

  confine :kernel => :aix
  defaultfor :kernel => :aix

  @mountline =  /^(\S*)\s+(\S+)\s+(\S+)\s+(\S+)\s+[[:alpha:]]{3} \d+ \d\d:\d\d (.+)$/
  def self.mountline
    @mountline
  end
  def mountline
    self.class.mountline
  end

  def self.instances
    mounts = []
    mount.split("\n").each do |line|
      if self.mountline.match(line)
        mounts << new(:ensure  => :present,
                      :node    => $1,
                      :device  => $2,
                      :name    => $3,
                      :fstype  => $4,
                      :options => $5.gsub(" ", "").split(","))
      end
    end
    mounts
  end

  mk_resource_methods

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
      if mountline.match(line) 
        $3 == resource[:name]
      end
    end
    if mountline.match(line)
      { :ensure => :present, :node => $1, :device  => $2, 
        :name => $3, :fstype  => $4, :options => $5.gsub(" ", "").split(",") }
    else
      { :name => nil }
    end
  end

  def mount_with_options(*args)
    options = []
    if resource[:fstype]
      options << fsflag
      options << resource[:fstype]
    end
    if (! resource[:node].nil?) and resource[:fstype] == 'nfs'
      options << "-n"
      options << resource[:node]
    end
    if resource[:options] && resource[:options] != :absent
      options << "-o"
      options << (resource[:options].is_a?(Array) ?  resource[:options].join(",") : resource[:options])
    end

    mount(*(options + args.compact))
  end

end
