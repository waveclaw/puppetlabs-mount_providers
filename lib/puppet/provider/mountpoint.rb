class Puppet::Provider::Mountpoint < Puppet::Provider
  def exists?
    ! entry[:name].nil?
  end

  def create
    mount_with_options(resource[:device], resource[:name])
    @property_hash[:ensure] = :present
  end

  def destroy
    unmount(resource[:name])
    @property_hash.clear
  end

  def device
    entry[:device]
  end

  def device=(value)
    unmount(resource[:name])
    mount_with_options(resource[:device], resource[:name])
  end

  def type
    entry[:type]
  end

  def type=(value)
    unmount(resource[:name])
    mount_with_options(resource[:device], resource[:name])
    @property_hash[:type] = value
  end

  def options
    entry[:options]
  end

  def options=(value)
    unmount(resource[:name])
    mount_with_options(resource[:device], resource[:name])
    @property_hash[:options] = value
  end

  def handle_notification
    remount if resource[:ensure] == :present and exists?
  end

  def self.instances
    raise Puppet::DevError, "Mountpoint instances method must be overridden by the provider"
  end

  def self.prefetch(resources)
    require 'ruby-debug'; debugger
    mounts = instances
    resources.keys.each do |name|
      if provider = mounts.find { |mount| mount[:name] == name }
        resources[name].provider = provider
      end
    end
  end

  private

  def mount_with_options(*args)
    options = []
    if resource[:options] && resource[:options] != :absent
      options << '-o'
      options << (resource[:options].is_a?(Array) ?  resource[:options].join(',') : resource[:options])
    end

    mount(*(options + args.compact))
  end

  def entry
    raise Puppet::DevError, "Mountpoint entry method must be overridden by the provider"
  end

  def remount
    if resource[:remounts] == :true
      mount_with_options "-o", "remount", resource[:name]
    else
      unmount(resource[:name])
      mount_with_options(resource[:device], resource[:name])
    end
  end
end
