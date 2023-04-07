# Hardware

## Outdoor

[Plasma Cloud PA1200](https://openwrt.org/toh/hwdata/plasma_cloud/plasma_cloud_pa1200)

## Indoor

[Xiaomi Mi Router 4A Gigabit Edition](https://openwrt.org/inbox/toh/xiaomi/xiaomi_mi_router_4a_gigabit_edition)

Beware when you buy this router: the old edition is possible to flash, but if you update the vendor firmware or you buy the new edition, it is not possible to flash anymore!

# Profiles

## Common to all profiles

A large selection of packages, including wpad-openssl, is used, resulting in large firmware images.

### lime-community configuration
```
config lime system
	option deferable_reboot_uptime_s '654321' # reboot every 7.5 days 
```

The deferable-reboot package is installed, and will reboot every node once per week. There should be no need for that, but just in case. If you don't want it to reboot you router, just set an exhaggeratedly large number here.

```
config lime network
	option main_ipv4_address '10.1.128.0/16/17'
```

The local network is 10.1.0.0/16 (which includes the IPs from 10.1.0.1 to 10.1.255.254), but the LibreMesh nodes will automatically take an IP in a smaller range (/17) of IPs: from 10.1.128.1 to 10.1.255.254.

```
	option anygw_dhcp_start '2562'
```

The IPs dynamically assigned by the DHCP of the nodes to the clients connecting will be in a range starting at 10.1.10.2 ( 10 * 256 + 2 = 2562 ).

```
	option anygw_dhcp_limit '30205'
```

Range that starts at 10.1.10.2, ends at 10.1.127.254 ( (127 - 10) * 256 + (254 - 2) + 1 = 30205 ).

So, the IPv4 network is divided in 3 spaces:
10.1.0.1--10.1.10.1 - available for static IPs, for example servers
10.1.10.2--10.1.127.254 - clients connecting to the network
10.1.128.1--10.1.255.254 - LibreMesh nodes

```
config lime wifi		
	option country 'ES'	
```

For respecting Spanish regulation in terms of usable wifi channels and output powers.

```
	option ap_ssid 'Calafou-to-be-configured'
	option apname_ssid 'Calafou/%H-to-be-configured'
```

Temporary ESSID, read below on "Post flashing".

Setting a new `ap_ssid` in `/etc/config/lime-node` (see below "Post flashing") also changes the VLAN used for Batman-adv layer2 routing protocol, but this should not be a problem.

```
	option ieee80211s_mesh_id 'libremesh'
```

The name of the mesh interface. Two routers will not mesh if this name is different.

### Packages

Packages suggested on the [LibreMesh website](https://libremesh.org/development.html) (except the WAN-related ones):

* lime-docs
* lime-proto-babeld
* lime-proto-batadv
* lime-proto-anygw
* shared-state
* hotplug-initd-services
* shared-state-babeld_hosts
* shared-state-bat_hosts
* shared-state-dnsmasq_hosts
* shared-state-dnsmasq_leases
* shared-state-nodes_and_links
* check-date-http
* lime-app
* lime-hwd-ground-routing
* lime-debug

Additional (maybe) useful packages:

* deferable-reboot 
* safe-reboot
* wpad-openssl
* shared-state-network_nodes
* shared-state-dnsmasq_servers
* prometheus-node-exporter-lua
* prometheus-node-exporter-lua-openwrt
* prometheus-node-exporter-lua-wifi_stations
* prometheus-node-exporter-lua-wifi-stations-extra
* prometheus-node-exporter-lua-wifi-survey
* prometheus-node-exporter-lua-wifi-params
* prometheus-node-exporter-lua-location-latlon

## Gateway

Has the PoE port configured as a WAN, to be connected to the fiber modem.

Wifi ports:

* 2.4 GHz: channel 6, used for AP and mesh
* 5 GHz: channel 64, used only for mesh

### lime-community configuration

As the "Common to all profiles" one but also with:

```
config lime-wifi-band '2ghz' 
	option channel '6'
	list modes 'ap'	
	list modes 'apname'
	list modes 'ieee80211s'
	option distance '300'

config lime-wifi-band '5ghz'
	option channel '64'
	list modes 'ieee80211s'
	option distance '300'
```

### Packages

As the "Common to all profiles" list but also with:

* lime-hwd-openwrt-wan (which pulls also lime-proto-wan as a dependency)
* babeld-auto-gw-mode

## Outdoor

Identical to the gateway profile, but the WAN is not configured as a WAN (it is used as a LAN). This is so because we want to use that port for connecting to other LibreMesh nodes, instead of having to run a second cable from the outdoor router to the indoor one.

### lime-community configuration

Identical to the gateway profile.

### Packages

Identical to the list in "Common to all profiles".

## Indoor

The same as the gateway profile (in this case, to have a port configured as WAN can be useful in case there is some problem with the internet access and someone decides to plug in a cellular data gateway).

Wifi ports:

* 2.4 GHz: channel 1, used for AP and mesh
* 5 GHz: channel 40, used for AP and mesh

### lime-community configuration

As the "Common to all profiles" one but also with:

```
config lime-wifi-band '2ghz' 
	option channel '1'
	list modes 'ap'	
	list modes 'apname'
	list modes 'ieee80211s'
	option distance '100'

config lime-wifi-band '5ghz'
	option channel '40'
	list modes 'ap'	
	list modes 'apname'
	list modes 'ieee80211s'
	option distance '100'
```

### Packages

Identical to the list for the gateway profile.

## Future profiles

These profiles includes many many packages, which makes the resulting firmware image to not fit in routers with only 8 MB of flash memory. For example, one heavy package is wpad-openssl, which allows us to encrypt the mesh connections with a password shared by all the nodes. Also, it would allow us to use Opportunistic Wireless Encryption (OWE), but this is not yet easy using LibreMesh.

So a possible future profile is a lightweight one for fitting in routers with smaller flash memory.

# Compiling

Follow the instructions on https://libremesh.org/development.html for installing the compilation dependencies and downloading the sources of OpenWrt. Make sure you take a modern version of OpenWrt: at least the 22.03 version.

In the `feeds.conf` file, do not specify any branch or tag for the `libremesh` (`lime-packages`) feed, so that the latest code is used.

Stop before launching `make menuconfig`. Instead, copy the needed `DOTconfig` file you find in this repository as `.config` file. This file already contains the minimum (maybe not strictly minimum...) configuration for getting the desired firmware. The same can also be done manually via `make menuconfig`.

After copying the `.config`, run `make defconfig` and then `make`. The first compilation will take a 1-4 hours, require internet connection, and occupy up to 10 GB. The following times you compile the same target, will take less time.

# Flashing

Follow the instructions on the OpenWrt wiki, specific for each router.

Typically, the process is like this:

```
PC$ cd openwrt/bin/TARGET/SUBTARGET
PC$ scp -O openwrt-BLABLA-sysupgrade.bin root@thisnode.info:/tmp
PC$ ssh root@thisnode.info
router# sysupgrade -n /tmp/openwrt-BLABLA-sysupgrade.bin
```

# Post flashing

The routers have by default a "Calafou-to-be-configured" ESSID. This is needed for remembering you to connect, set a root password, add you ssh keys, set any other fancy encryption you want and finally set the ESSID to the correct value.

That temporary ESSID will also appear if the router reset, for any reason. In this case, you also have to connect and set the aforementioned things.

In order:

* set the root password using `passwd`
* create a `/etc/dropbear/authorized_keys` with the public SSH key of the people that should be allowed to access the router
* add these lines at the bottom of `/etc/config/lime-node`:
```
    option ap_ssid 'Calafou'
	option apname_ssid 'Calafou/%H'
```
* apply the new ESSID with the `lime-config` command
* reboot with the `reboot` command

## Optional post-configuration stuff

Add in `/etc/config/lime-node` any encryption you need, see [/docs/lime-example.txt](https://github.com/libremesh/lime-packages/blob/master/packages/lime-docs/files/www/docs/lime-example.txt) about how to set a password for the AP and APname, and how to set a password for the mesh connections.

If you want to connect via SSH from the internet, forward the port on your modem and allow the SSH connections from the WAN port adding these lines in the `/etc/config/firewall`:

```
config rule
	option name 'Allow-SSH'
	option src 'wan'
	option proto 'tcp'
	option dest_port '22'
	option target 'ACCEPT'
```

In this case, you could disallow the password authentication (setting to `off` the `PasswordAuth` option in `/etc/config/dropbear` and rebooting), for making sure that nobody on the internet tries to bruteforce the root password. In this case, if you lose the private SSH key you will have to reset the router, that usually requires pressing a physical button on it.
