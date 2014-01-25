minetest.register_alias("sumpf:pilz", "riesenpilz:brown")

--[[local function swampore(pos, env)
	if minetest.get_node(pos).name == "default:stone_with_coal" then
		return "kohle"
	end
	if minetest.get_node(pos).name == "default:stone_with_iron" then
		return "eisen"
	end
	return "junglestone"
end]]

local function avoid_nearby_node(pos, node)
	for i = -1,1,2 do
		for j = -1,1,2 do
			if minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z+j}).name == node then
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

local function water_allowed(data, area, x, y, z, nds)
	for _,s in ipairs(nds) do
		if data[area:index(x+1, y, z)] ~= s
		and data[area:index(x-1, y, z)] ~= s
		and data[area:index(x, y, z)+1] ~= s
		and data[area:index(x, y, z)-1] ~= s then
			return true
		end
	end
	return false
end

local function fix_light(minp, maxp)
	local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(minp, maxp)
	area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	nodes = manip:get_data()

	manip:set_data(nodes)
	manip:write_to_map()
	manip:update_map()
end

--[[local function find_ground(pos, nodes)
	for _, evground in ipairs(nodes) do
		if minetest.get_node(pos).name == evground then
			return true
		end
	end
	return false
end--]]


local c = {
	air = minetest.get_content_id("air"),
	stone = minetest.get_content_id("default:stone"),
	gr = minetest.get_content_id("default:dirt_with_grass"),
	dirt = minetest.get_content_id("default:dirt"),
	sand = minetest.get_content_id("default:sand"),
	desert_sand = minetest.get_content_id("default:desert_sand"),
	water = minetest.get_content_id("default:water_source"),
	dirtywater = minetest.get_content_id("sumpf:dirtywater_source"),
	coal = minetest.get_content_id("default:stone_with_coal"),
	iron = minetest.get_content_id("default:stone_with_iron"),

	tree = minetest.get_content_id("default:tree"),
	leaves = minetest.get_content_id("default:leaves"),
	apple = minetest.get_content_id("default:apple"),
	dry_shrub = minetest.get_content_id("default:dry_shrub"),
	cactus = minetest.get_content_id("default:cactus"),
	papyrus = minetest.get_content_id("default:papyrus"),

	sumpfg = minetest.get_content_id("sumpf:sumpf"),
	sumpf2 = minetest.get_content_id("sumpf:sumpf2"),
	sumpfstone = minetest.get_content_id("sumpf:junglestone"),
	sumpfcoal = minetest.get_content_id("sumpf:kohle"),
	sumpfiron = minetest.get_content_id("sumpf:eisen"),
	peat = minetest.get_content_id("sumpf:peat"),

	brown_shroom = minetest.get_content_id("riesenpilz:brown"),
	red_shroom = minetest.get_content_id("riesenpilz:red"),
	fly_agaric = minetest.get_content_id("riesenpilz:fly_agaric"),
	sumpfgrass = minetest.get_content_id("sumpf:gras"),
	junglegrass = minetest.get_content_id("default:junglegrass"),
}

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
local GROUND =	{c.gr, c.sand, c.dirt, c.desert_sand, c.water}
--USUAL_STUFF =	{"default:leaves","default:apple","default:tree","default:dry_shrub","default:cactus","default:papyrus"}
local USUAL_STUFF =	{c.dry_shrub, c.cactus, c.papyrus}
minetest.register_on_generated(function(minp, maxp, seed)

	--avoid calculating perlin noises for unneeded places
	if maxp.y <= -2
	or minp.y >= 150 then
		return
	end

	local x0,z0,x1,z1 = minp.x,minp.z,maxp.x,maxp.z	-- Assume X and Z lengths are equal
	local perlin1 = minetest.get_perlin(1123,3, 0.5, perlin_scale)	--Get map specific perlin

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

	local t1 = os.clock()

	local divs = (maxp.x-minp.x);
	local pr = PseudoRandom(seed+68)

		--Information:
	sumpf.inform("tries to generate a swamp at: x=["..minp.x.."; "..maxp.x.."]; y=["..minp.y.."; "..maxp.y.."]; z=["..minp.z.."; "..maxp.z.."]", 2)

	--[[local trees = minetest.find_nodes_in_area(minp, maxp, USUAL_STUFF)
	for i,v in pairs(trees) do
		minetest.remove_node(v)
	end]]
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for p_pos in area:iterp(minp, maxp) do	--remove tree stuff
		local d_p_pos = data[p_pos]
		for _,nam in ipairs({c.tree, c.leaves, c.apple}) do			
			if d_p_pos == nam then
				data[p_pos] = c.air
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
			elseif smooth
			and (
				test > smooth_rarity_full
				or (
					test > smooth_rarity_ran
					and pr:next(0,smooth_rarity_dif) > (smooth_rarity_full - test) * 100
				)
			) then
				in_biome = true
			elseif (not smooth)
			and test > nosmooth_rarity then
				in_biome = true
			end

			if in_biome then

				for b = minp.y,maxp.y,1 do	--remove usual stuff
					local p_pos = area:index(x, b, z)
					local d_p_pos = data[p_pos]
					for _,nam in ipairs(USUAL_STUFF) do			
						if d_p_pos == nam then
							data[p_pos] = c.air
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

					if d_p_ground == c.water then	--Dreckseen:
						if smooth then
							h = pr:next(1,2)
						else
							h = 2 --untested
						end
						if minetest.find_node_near(ground, 3+h, "group:crumbly") then
						--if data[area:index(x, ground_y-(3+pr:next(1,2)), z)] ~= c.water then
							for y=0,-pr:next(26,30),-1 do
								local p_pos = area:index(x, ground_y+y, z)
								local d_p_pos = data[p_pos]
								local pos = {x=x,y=ground_y+y,z=z}
								if d_p_pos == c.water then
									data[p_pos] = c.dirtywater
								else
									data[p_pos] = c.peat
								end
							end
						end
					else
						if swampwater	--Sumpfwasser: doesn't work like cave detection
						and pr:next(1,2) == 2
						and water_allowed(data, area, x, ground_y, z, {c.air, nil, 0})
						and d_p_boden == c.air then
							for s=0,-10-pr:next(1,9),-1 do
								local p_pos = area:index(x, ground_y+s, z)
								local d_p_pos = data[p_pos]
								if d_p_pos ~= c.air then
									data[p_pos] = c.dirtywater
								else
									break
								end
							end
						else
							local p_uuground = area:index(x, ground_y-2, z)
							if sumpf.wet_beaches
							and ground_y == 1
							and pr:next(1,3) == 1 then
								data[p_ground] = c.dirtywater
								if pr:next(1,3) == 1 then
									data[p_uground] = c.dirtywater
								else
									data[p_uground] = c.peat
							end
								data[p_uuground] = c.peat
							else --Sumpfboden:
								data[p_ground] = c.sumpfg
								data[p_uground] = c.sumpfg
								data[p_uuground] = c.sumpf2
							end
							for i=-3,-30,-1 do
								local p_pos = area:index(x, ground_y+i, z)
								local d_p_pos = data[p_pos]
								if d_p_pos ~= c.air then
									if d_p_pos == c.coal then
										data[p_pos] = c.sumpfcoal
									elseif d_p_pos == c.iron then
										data[p_pos] = c.sumpfiron
									else
										data[p_pos] = c.sumpfstone
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
								data[p_boden] = c.brown_shroom
							elseif pr:next(1,100) == 1 then
								data[p_boden] = c.red_shroom
							elseif pr:next(1,200) == 1 then
								data[p_boden] = c.fly_agaric
							elseif pr:next(1,4) == 1 then
								data[p_boden] = c.sumpfgrass
							elseif pr:next(1,6) == 1 then
								data[p_boden] = c.junglegrass
							end
						end
					end
				end
			end
		end
	end
	vm:set_data(data)
	--vm:set_lighting({day=0, night=0})
	--vm:calc_lighting()
	--vm:update_liquids()
	vm:write_to_map()
	sumpf.inform("ground finished", 2, t1)

	local t2 = os.clock()
	if plants_enabled then	--Trees:
		for _,v in ipairs(tab) do
			local p = v[2]
			if v[1] == 1 then
				mache_birke(p, 1)
			else
				sumpf_make_jungletree(p, 1)
			end
		end
	end
	sumpf.inform("trees made", 2, t2)

	local t2 = os.clock()
	fix_light(minp, maxp)
	sumpf.inform("shadows added", 2, t2)

	sumpf.inform("done", 1, t1)
end)
