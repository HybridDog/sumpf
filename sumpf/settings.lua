local default_settings = {
	enable_mapgen = true,
	always_generate = false,
	smooth = true,
	mapgen_rarity = 4,
	mapgen_size = 100,
	smooth_trans_size = 4,
	enable_plants = true,
	swampwater = true,
	wet_beaches = true,	--swampwater
	hut_chance = 50,
	spawn_plants = true,
	info = true,
	inform_all = false,	--minetest.is_singleplayer()
	max_spam = 2,
}

for name,dv in pairs(default_settings) do
	local setting
	local setting_name = "sumpf."..name
	if type(dv) == "boolean" then
		setting = minetest.setting_getbool(setting_name)
	elseif type(dv) == "number" then
		setting = tonumber(minetest.setting_get(setting_name))
	else
		error"[sumpf] only boolean and number settings are available"
	end
	sumpf[name] = setting == nil and dv or setting
end
