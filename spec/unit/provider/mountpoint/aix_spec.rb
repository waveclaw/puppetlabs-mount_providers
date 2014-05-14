#!/usr/bin/env ruby
#
# All examples based on 
# http://publib.boulder.ibm.com/infocenter/aix/v6r1/index.jsp?topic=%2Fcom.ibm.aix.cmds%2Fdoc%2Faixcmds3%2Fmount.htm
#  Retrieved 2014-May-12
#

require 'spec_helper'
require 'puppet/provider/mountpoint/aix'

describe Puppet::Type.type(:mountpoint).provider(:aix) do
  let(:resource) do
    Puppet::Type.type(:mountpoint).new(
      :ensure   => :present,
      :name     => "/mountdir",
      :device   => "/dev/device",
      :provider => :aix
    )
  end

  let(:provider) do
    described_class.new(resource)
  end

  before :each do
    described_class.expects(:execute).never
    described_class.stubs(:suitable?).returns(true)
  end

  describe "#handle_notification" do
    it "handles refresh events sent to the type" do
      resource.provider.expects(:handle_notification).once
      resource.refresh
    end
  end

  describe "#exists?" do
    it "should be present if it is included in mount output" do
      provider.stubs(:mount).returns <<-MOUNT_OUTPUT
node   mounted          mounted over  vfs    date              options
----   -------          ------------ ---  ------------   -------------------
        /dev/hd0         /            jfs   Mar 17 08:04   rw, log  =/dev/hd9
        /dev/hd1         /tmp         jfs   Dec 17 08:04   rw, log  =/dev/hd9
        /dev/home        /home        jfs   Jun 17 08:06   rw, log  =/dev/hd9
        /dev/device      /mountdir    jfs   Dec 17 08:06   rw, log  =/dev/hd9
barney /home/local/src  /usr/code    nfs   Apr 17 23:11   ro, log  =/dev/hd9
MOUNT_OUTPUT

      provider.should be_exists
    end

    it "should be absent if it is missing from mount output" do
      provider.stubs(:mount).returns <<-MOUNT_OUTPUT
node   mounted          mounted over  vfs    date              options
----   -------          ------------ ---  ------------   -------------------
       /dev/hd0         /            jfs   Dec 17 08:04   rw, log  =/dev/hd8
       /dev/hd3         /tmp         jfs   Dec 17 08:04   rw, log  =/dev/hd8
       /dev/hd1         /home        jfs   Dec 17 08:06   rw, log  =/dev/hd8
june   /home/local/src  /usr/code    nfs   Dec 17 08:06   ro, log  =/dev/hd8
MOUNT_OUTPUT

      provider.should_not be_exists
    end

    it "should be present if it is included in mount output with an incorrect device" do
      provider.stubs(:mount).returns <<-MOUNT_OUTPUT
node   mounted          mounted over  vfs    date              options
----   -------          ------------ ---  ------------   -------------------
       /dev/hd0         /            jfs   Dec 17 08:04   rw, log  =/dev/hd8
       /dev/hd3         /tmp         jfs   Dec 17 08:04   rw, log  =/dev/hd8
       /dev/hd1         /home        jfs   Dec 17 08:06   rw, log  =/dev/hd8
       /dev/hd2         /usr         jfs   Dec 17 08:06   rw, log  =/dev/hd8
sue    wrongdevice      /mountdir    nfs   Dec 17 08:06   ro, log  =/dev/hd8
MOUNT_OUTPUT

      provider.should be_exists
    end
  end

  describe "when fstypes are specificed" do
    it "should pass the specified filesystem type to the mount command when mounting" do
      resource[:fstype] = "jfs"
      provider.expects(:mount).with("-t", "jfs", resource[:device], resource[:name])
      provider.create
    end
  end

  describe "when nfs mounted" do
     it "should pass a node name to the mount command" do
       resource[:node] = "mars"
       resource[:fstype] = "nfs"
       provider.expects(:mount).with("-t", "nfs", "-n", "mars", resource[:device], resource[:name])
       provider.create
     end
  end

end
