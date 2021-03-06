--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: servicectl.lua 9558 2012-12-18 13:58:22Z jow $
]]--

module("luci.controller.todaair.todaair", package.seeall)

function index()
        local root = node()
	root.target = alias("admin")
	root.index = true

        local page   = node("admin")
	page.target  = alias("admin","main")
	page.title   = _("Administration")
	page.order   = 10
	page.sysauth = "root"
	page.sysauth_authenticator = "htmlauth"
	page.ucidata = true
	page.index = true
        
        entry({"admin","main"},template("todaair/index"),nil)
        entry({"admin","list"},template("todaair/list"),nil)

        entry({"admin","network"},template("todaair/list"),_("Network"))

        entry({"admin","services","list"},template("todaair/list"),nil)
        entry({"admin","diag_tracetoute6","list"},template("todaair/list"),_("diag_tracetoute6 list"),1)
        entry({"admin","status"},template("todaair/list"),_("Status"))

        entry({"admin","system"},template("todaair/list"),_("System"))

        entry({"admin","uci","list"},template("todaair/list"),_("uci list"),1)
        entry({"admin","filebrowser","list"},template("todaair/list"),_("filebrowser list"),1)
        
        entry({"admin","guide"},call("action_guide"),nil)
	entry({"admin","changepassword"},cbi("todaair/changepassword"),nil)
	entry({"admin","system_reboot"},call("system_reboot"),nil)
	entry({"admin","wireless"},cbi("todaair/wireless",{hidesavebtn=true}),nil)
	entry({"admin","online_status"},template("todaair/online_status"),nil)

	entry({"admin","fastmode"},template("todaair/list"),_("Fast mode"))
end

function system_reboot()
luci.sys.reboot()
end

function action_guide()

 uci = require "luci.model.uci".cursor()
require("luci.model.uci")

  -- Determine state
	local keep_avail   = true
	local step         = tonumber(luci.http.formvalue("step") or 0)

	-- Step 0: route mode select
if step == 0 then

	luci.template.render("todaair/guide", {
			step=0,
		} )

	-- Step 1:  wan setting  uci set route mode
	elseif step == 1 then
--if  is6358 >= 1 then
      if luci.http.formvalue("cbid.route.model") then
       local route_model = tonumber(luci.http.formvalue("cbid.route.model"))
         if route_model == 1 then
          --uci:set("network", "wan", "ifname", "eth0")
        luci.util.exec("uci set network.wan.ifname=eth0")
        uci:save("network")
        uci:commit("network")
        end
         if route_model == 2 then
         -- uci:set("network", "wan", "ifname", "eth1.1")
        luci.util.exec("uci set network.wan.ifname=\"eth1.1\"")
        uci:save("network")
        uci:commit("network")
        end

    end
--end

		luci.template.render("todaair/guide", {
			step=1,

		} )

	-- Step 2: web lan setting ,uci set wan 
	elseif step == 2 then
		 uci = luci.model.uci.cursor()

if luci.http.formvalue("cbid.network.wan.proto") then
       network_wan_proto = luci.http.formvalue("cbid.network.wan.proto") 
    uci:set("network", "wan", "proto", network_wan_proto)
end

if luci.http.formvalue("cbid.network.wan.ipaddr") then
       network_wan_ipaddr = luci.http.formvalue("cbid.network.wan.ipaddr") 
      uci:set("network", "wan", "ipaddr", network_wan_ipaddr) 
end

if luci.http.formvalue("cbid.network.wan.netmask") then
       network_wan_netmask = luci.http.formvalue("cbid.network.wan.netmask") 
     uci:set("network", "wan", "netmask", network_wan_netmask)
end

if luci.http.formvalue("cbid.network.wan.gateway") then
       network_wan_gateway = luci.http.formvalue("cbid.network.wan.gateway") 
      uci:set("network", "wan", "gateway", network_wan_gateway) 
end

if luci.http.formvalue("cbid.network.wan.username") then
       network_wan_username = luci.http.formvalue("cbid.network.wan.username") 
      uci:set("network", "wan", "username", network_wan_username) 
 luci.util.exec("echo usrtname >>/tmp/use")
end

if luci.http.formvalue("cbid.network.wan.password") then
       network_wan_password = luci.http.formvalue("cbid.network.wan.password") 
      uci:set("network", "wan", "password", network_wan_password) 
end

if luci.http.formvalue("cbid.network.wan.dns") then
       network_wan_dns = luci.http.formvalue("cbid.network.wan.dns") 
      uci:set("network", "wan", "dns", network_wan_dns) 
end

if luci.http.formvalue("cbid.network.wan.macaddr") then
       network_wan_macaddr = luci.http.formvalue("cbid.network.wan.macaddr") 
      uci:set("network", "wan", "macaddr", network_wan_macaddr) 
end

uci:save("network")
		luci.template.render("todaair/guide", {
			step=2,

		} )


	-- Step 3: uci set lan and save all data--
	elseif step == 3 then
		 uci = luci.model.uci.cursor()
if luci.http.formvalue("cbid.network.lan.ipaddr") then
       network_wan_ipaddr = luci.http.formvalue("cbid.network.lan.ipaddr") 
      uci:set("network", "lan", "ipaddr", network_wan_ipaddr) 
end
if luci.http.formvalue("cbid.network.lan.netmask") then
       network_wan_netmask = luci.http.formvalue("cbid.network.lan.netmask") 
      uci:set("network", "lan", "netmask", network_wan_netmask)

end

if luci.http.formvalue("cbid.network.lan.macaddr") then
       network_wan_macaddr = luci.http.formvalue("cbid.network.lan.macaddr") 
      uci:set("network", "lan", "macaddr", network_wan_macaddr) 
 
end
	uci:save("network")
		luci.template.render("todaair/guide", {
			step=3,
		} )
elseif step == 4 then
 	uci = luci.model.uci.cursor()
	uci:foreach("wireless","wifi-iface",
		function(section)
			if section[".name"] then
				mysection=section[".name"]
			end
		end)
	if luci.http.formvalue("cbid.quickwifi.ssid") then
       		quickwifi_ssid = luci.http.formvalue("cbid.quickwifi.ssid") 
     		uci:set("wireless", mysection,"ssid",quickwifi_ssid) 
	end
	encryption = luci.http.formvalue("cbid.quickwifi.encryption")
	if encryption == "psk-mixed" then
		uci:set("wireless",mysection,"encryption",encryption)
		if luci.http.formvalue("cbid.quickwifi.key") then
       			quickwifi_key = luci.http.formvalue("cbid.quickwifi.key") 
     			uci:set("wireless",mysection,"key",quickwifi_key) 
		end
	elseif encryption == "psk" then
		uci:set("wireless",mysection,"encryption",encryption)
		if luci.http.formvalue("cbid.quickwifi.key") then
       			quickwifi_key = luci.http.formvalue("cbid.quickwifi.key") 
		end
	elseif encryption == "none" then
		uci:set("wireless",mysection,"encryption" ,encryption)
		uci:delete("wireless",mysection,"key")
	end
	--[[
	Dafault value
	Add 2014-3-15
	@Todaair
	]]--
	uci:set("wireless",mysection,"mode","ap")
	uci:delete("wireless",mysection,"wds")

	uci:save("wireless")
	luci.template.render("todaair/guide", {
		step=4,
	} )

elseif step == 5 then
 	uci = luci.model.uci.cursor()
	local uci = luci.model.uci.cursor()
	uci:load("network")
	uci:commit("network")
	uci:load("wireless")
	uci:commit("wireless")
    	luci.util.exec("ifup wan")
	luci.template.render("todaair/guide", {
		step=5,
	} )
	luci.sys.reboot()
end
end

