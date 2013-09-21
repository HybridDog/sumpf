minetest.register_alias("sumpf:pilz", "riesenpilz:brown")

--[[local function swampore(pos, env)
	if env:get_node(pos).name == "default:stone_with_coal" then
		return "kohle"
	end
	if env:get_node(pos).name == "default:stone_with_iron" then
		return "eisen"
	end
	return "junglestone"
end]]

local function avoid_nearby_node(pos, node)
	for i = -1,1,2 do
		for j = -1,1,2 do
			if minetest.env:get_node({x=pos.x+i, y=pos.y, z=pos.z+j}).name == node then
				return false
			end
		end
	end
	return true
end

local function find_grond(a,list)
	for _,nam in ipairs(list) do			
		if a == nam then
			return true
		end
	end
	return false
end

--[[local function find_ground(pos, nodes)
	for _, evground in ipairs(nodes) do
		if minetest.env:get_node(pos).name == evground then
			return true
		end
	end
	return false
end--]]


local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_gr = minetest.get_content_id("default:dirt_with_grass")
local c_dirt = minetest.get_content_id("default:dirt")
local c_sand = minetest.get_content_id("default:sand")
local c_desert_sand = minetest.get_content_id("default:desert_sand")
local c_water = minetest.get_content_id("default:water_source")
local c_dirtywater = minetest.get_content_id("sumpf:dirtywater_source")
local c_coal = minetest.get_content_id("default:stone_with_coal")
local c_iron = minetest.get_content_id("default:stone_with_iron")

local c_tree = minetest.get_content_id("default:tree")
local c_leaves = minetest.get_content_id("default:leaves")
local c_apple = minetest.get_content_id("default:apple")
local c_dry_shrub = minetest.get_content_id("default:dry_shrub")
local c_cactus = minetest.get_content_id("default:cactus")
local c_papyrus = minetest.get_content_id("default:papyrus")

local c_sumpfg = minetest.get_content_id("sumpf:sumpf")
local c_sumpf2 = minetest.get_content_id("sumpf:sumpf2")
local c_sumpfstone = minetest.get_content_id("sumpf:junglestone")
local c_sumpfcoal = minetest.get_content_id("sumpf:kohle")
local c_sumpfiron = minetest.get_content_id("sumpf:eisen")
local c_peat = minetest.get_content_id("sumpf:peat")

local c_brown_shroom = minetest.get_content_id("riesenpilz:brown")
local c_red_shroom = minetest.get_content_id("riesenpilz:red")
local c_fly_agaric = minetest.get_content_id("riesenpilz:fly_agaric")
local c_sumpfgrass = minetest.get_content_id("sumpf:gras")
local c_junglegrass = minetest.get_content_id("default:junglegrass")

local c_stonebrick = minetest.get_content_id("default:stonebrick")
local c_cloud = minetest.get_content_id("default:cloud")


local env = minetest.env	--Should make things a bit faster.
local smooth = sumpf.smooth
local swampwater = sumpf.swampwater
local plants_enabled = sumpf.enable_plants

local sumpf_rarity = sumpf.mapgen_rarity
local sumpf_size = sumpf.mapgen_size

local nosmooth_rarity = -(sumpf_rarity/50)+1
local perlin_scale = sumpf_size*100/sumpf_rarity
local smooth_rarity_full = nosmooth_rarity+perlin_scale/(20*sumpf_size)
local smooth_rarity_ran = nosmooth_rarity-perlin_scale/(40*sumpf_size)
local smooth_rarity_dif = (smooth_rarity_full-smooth_rarity_ran)*100-1

local EVSUMPFGROUND =	{"default:dirt_with_grass","default:dirt","default:sand","default:water_source","default:desert_sand"}
local GROUND =	{c_gr, c_sand, c_dirt, c_desert_sand, c_water}
--USUAL_STUFF =	{"default:leaves","default:apple","default:tree","default:dry_shrub","default:cactus","default:papyrus"}
local USUAL_STUFF =	{c_dry_shrub, c_cactus, c_papyrus}
minetest.register_on_generated(function(minp, maxp, seed)

	--avoid calculating perlin noises for unneeded places
	if maxp.y <= -2
	or minp.y >= 150 then
		return
	end

	local x0,z0,x1,z1 = minp.x,minp.z,maxp.x,maxp.z	-- Assume X and Z lengths are equal
	local perlin1 = env:get_perlin(1123,3, 0.5, perlin_scale)	--Get map specific perlin

	--[[if not (perlin1:get2d({x=x0, y=z0}) > 0.53) and not (perlin1:get2d({x=x1, y=z1}) > 0.53)
	and not (perlin1:get2d({x=x0, y=z1}) > 0.53) and not (perlin1:get2d({x=x1, y=z0}) > 0.53)
	and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) then]]

	if not sumpf.always_generate
	and not ( perlin1:get2d( {x=x0, y=z0} ) > nosmooth_rarity ) 					--top left
	and not ( perlin1:get2d( { x = x0 + ( (x1-x0)/2), y=z0 } ) > nosmooth_rarity )--top middle
	and not (perlin1:get2d({x=x1, y=z1}) > nosmooth_rarity) 						--bottom right
	and not (perlin1:get2d({x=x1, y=z0+((z1-z0)/2)}) > nosmooth_rarity) 			--right middle
	and not (perlin1:get2d({x=x0, y=z1}) > nosmooth_rarity)  						--bottom left
	and not (perlin1:get2d({x=x1, y=z0}) > nosmooth_rarity)						--top right
	and not (perlin1:get2d({x=x0+((x1-x0)/2), y=z1}) > nosmooth_rarity) 			--left middle
	and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > nosmooth_rarity) 			--middle
	and not (perlin1:get2d({x=x0, y=z1+((z1-z0)/2)}) > nosmooth_rarity) then		--bottom middle
		return
	end

	local divs = (maxp.x-minp.x);
	local pr = PseudoRandom(seed+68)

		--Information:
	if sumpf.info then
		t1 = os.clock()
		local geninfo = "[sumpf] tries to generate a swamp at: x=["..minp.x.."; "..maxp.x.."]; y=["..minp.y.."; "..maxp.y.."]; z=["..minp.z.."; "..maxp.z.."]"
		print(geninfo)
		minetest.chat_send_all(geninfo)
	end

	--[[local trees = env:find_nodes_in_area(minp, maxp, USUAL_STUFF)
	for i,v in pairs(trees) do
		env:remove_node(v)
	end]]
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for p_pos in area:iterp(minp, maxp) do	--remove tree stuff
		local d_p_pos = data[p_pos]
		for _,nam in ipairs({c_tree, c_leaves, c_apple}) do			
			if d_p_pos == nam then
				data[p_pos] = c_air
				break
			end
		end
	end

	local num = 1
	local tab = {}

	for j=0,divs do
		for i=0,divs do
			local x,z = x0+i,z0+j

			--Check if we are in a "Swamp biome"
			local in_biome = false
			local test = perlin1:get2d({x=x, y=z})
			--smooth mapgen
			if sumpf.always_generate then
				in_biome = true
			elseif smooth and (test > smooth_rarity_full or (test > smooth_rarity_ran and pr:next(0,smooth_rarity_dif) > (smooth_rarity_full - test) * 100 )) then
				in_biome = true
			elseif (not smooth) and test > nosmooth_rarity then
				in_biome = true
			end

			if in_biome then

				for b = minp.y,maxp.y,1 do	--remove usual stuff
					local p_pos = area:index(x, b, z)
					local d_p_pos = data[p_pos]
					for _,nam in ipairs(USUAL_STUFF) do			
						if d_p_pos == nam then
							data[p_pos] = c_air
							break
						end
					end
				end

				local ground_y = nil --Definition des Bodens:
--				for y=maxp.y,0,-1 do
				for y=maxp.y,-5,-1 do	--because of the caves
					if find_grond(data[area:index(x, y, z)], GROUND) then
						ground_y = y
						break
					end
				end
				if ground_y then
					local p_ground = area:index(x, ground_y, z)
					local p_boden = area:index(x, ground_y+1, z)
					local p_uground = area:index(x, ground_y-1, z)
					local d_p_ground = data[p_ground]
					local d_p_boden = data[p_boden]
					local d_p_uground = data[p_uground]
					local ground =	{x=x,y=ground_y,	z=z}
					local boden =	{x=x,y=ground_y+1,	z=z}

					if d_p_ground == c_water then	--Dreckseen:
						if smooth then
							h = pr:next(1,2)
						else
							h = 2 --untested
						end
						if env:find_node_near(ground, 3+h, "group:crumbly") then
						--if data[area:index(x, ground_y-(3+pr:next(1,2)), z)] ~= c_water then
							for y=0,-pr:next(26,30),-1 do
								local p_pos = area:index(x, ground_y+y, z)
								local d_p_pos = data[p_pos]
								local pos = {x=x,y=ground_y+y,z=z}
								if d_p_pos == c_water then
									data[p_pos] = c_dirtywater
								else
									data[p_pos] = c_peat
								end
							end
						end
					else
						if swampwater	--Sumpfwasser: doesn't work like cave detection
						and pr:next(1,2) == 2
						and data[area:index(x+1, ground_y, z)] ~= c_air
						and data[area:index(x-1, ground_y, z)] ~= c_air
						and data[area:index(x, ground_y, z)+1] ~= c_air
						and data[area:index(x, ground_y, z)-1] ~= c_air
						and d_p_boden == c_air then
							for s=0,-10-pr:next(1,9),-1 do
								local p_pos = area:index(x, ground_y+s, z)
								local d_p_pos = data[p_pos]
								if d_p_pos ~= c_air then
									data[p_pos] = c_dirtywater
								else
									break
								end
							end

						else --Sumpfboden:
							data[p_ground] = c_sumpfg
							data[p_uground] = c_sumpfg
							data[area:index(x, ground_y-2, z)] = c_sumpf2
							for i=-3,-30,-1 do
								local p_pos = area:index(x, ground_y+i, z)
								local d_p_pos = data[p_pos]
								if d_p_pos ~= c_air then
									if d_p_pos == c_coal then
										data[p_pos] = c_sumpfcoal
									elseif d_p_pos == c_iron then
										data[p_pos] = c_sumpfiron
									else
										data[p_pos] = c_sumpfstone
									end
								else
									break
								end
							end
						end

						if plants_enabled then	--Pflanzen (und Pilz):

							if pr:next(1,80) == 1 then
--								mache_birke(boden)	this didn't work, so...
								tab[num] = {1, boden}
								num = num+1
							elseif pr:next(1,20) == 1 then
								tab[num] = {2, boden}
								num = num+1
--								sumpf_make_jungletree(boden)
							elseif pr:next(1,50) == 1 then
								data[p_boden] = c_brown_shroom
							elseif pr:next(1,100) == 1 then
								data[p_boden] = c_red_shroom
							elseif pr:next(1,200) == 1 then
								data[p_boden] = c_fly_agaric
							elseif pr:next(1,4) == 1 then
								data[p_boden] = c_sumpfgrass
							elseif pr:next(1,6) == 1 then
								data[p_boden] = c_junglegrass
							end
						end
					end
				end
			end
		end
	end
	vm:set_data(data)
	--vm:set_lighting({day=0, night=0})
	vm:calc_lighting(
		{x=minp.x-16, y=minp.y, z=minp.z-16},
		{x=maxp.x+16, y=maxp.y, z=maxp.z+16}
	)
	vm:update_liquids()
	vm:write_to_map()

	if plants_enabled then	--Trees:
		for _,v in ipairs(tab) do
			local p = v[2]
			if v[1] == 1 then
				mache_birke(p)
			else
				sumpf_make_jungletree(p)
			end
		end
	end

	if sumpf.info then
		local geninfo = string.format("[sumpf] done in: %.2fs", os.clock() - t1)
		print(geninfo)
		minetest.chat_send_all(geninfo)
	end
end)
