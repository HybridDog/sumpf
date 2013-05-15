local function generate_ore(name, wherein, minp, maxp, seed, chunks_per_volume, ore_per_chunk, height_min, height_max)
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed)
	local num_chunks = math.floor(chunks_per_volume * volume)
	local chunk_size = 3
	if ore_per_chunk <= 4 then
		chunk_size = 2
	end
	local inverse_chance = math.floor(chunk_size*chunk_size*chunk_size / ore_per_chunk)
	--print("generate_ore num_chunks: "..dump(num_chunks))
	for i=1,num_chunks do
	if (y_max-chunk_size+1 <= y_min) then return end
		local y0 = pr:next(y_min, y_max-chunk_size+1)
		if y0 >= height_min and y0 <= height_max then
			local x0 = pr:next(minp.x, maxp.x-chunk_size+1)
			local z0 = pr:next(minp.z, maxp.z-chunk_size+1)
			local p0 = {x=x0, y=y0, z=z0}
			for x1=0,chunk_size-1 do
			for y1=0,chunk_size-1 do
			for z1=0,chunk_size-1 do
				if pr:next(1,inverse_chance) == 1 then
					local x2 = x0+x1
					local y2 = y0+y1
					local z2 = z0+z1
					local p2 = {x=x2, y=y2, z=z2}
					if minetest.env:get_node(p2).name == wherein then
						minetest.env:set_node(p2, {name=name})
					end
				end
			end
			end
			end
		end
	end
	--print("generate_ore done")
end

local function generate_kohle(minp, maxp, seed, chunks_per_volume, chunk_size, height_min, height_max)
	generate_ore("sumpf:kohle",	"sumpf:junglestone", minp, maxp, seed, chunks_per_volume, chunk_size, height_min, height_max)
end

local function generate_eisen(minp, maxp, seed, chunks_per_volume, chunk_size, height_min, height_max)
	generate_ore("sumpf:eisen",	"sumpf:junglestone", minp, maxp, seed, chunks_per_volume, chunk_size, height_min, height_max)
end

minetest.register_alias("sumpf:pilz", "riesenpilz:brown")

local function avoid_nearby_node(pos, node)
	if minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}).name == node then return false end
	if minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}).name == node then return false end
	if minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}).name == node then return false end
	if minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}).name == node then return false end
	return true
end

local function find_ground(pos, nodes)
	for _, evground in ipairs(nodes) do
		if minetest.env:get_node(pos).name == evground then
			return true
		end
	end
	return false
end

SUMPFGROUND	=	{"default:dirt_with_grass","default:dirt","default:sand","default:desert_sand"}
EVSUMPFGROUND =	{"default:dirt_with_grass","default:dirt","default:sand","default:desert_sand", "default:water_source"}
USUAL_STUFF =	{"default:leaves","default:apple","default:tree","default:dry_shrub","default:cactus","default:papyrus"}
minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= -10 then
		local x0,z0,x1,z1 = minp.x,minp.z,maxp.x,maxp.z	-- Assume X and Z lengths are equal
		local env = minetest.env	--Should make things a bit faster.
		local perlin1 = env:get_perlin(11,3, 0.5, 200)	--Get map specific perlin

		--[[if not (perlin1:get2d({x=x0, y=z0}) > 0.53) and not (perlin1:get2d({x=x1, y=z1}) > 0.53)
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53) and not (perlin1:get2d({x=x1, y=z0}) > 0.53)
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) then]]
		if not sumpf.always_generate
		and not ( perlin1:get2d( {x=x0, y=z0} ) > 0.53 ) 					--top left
		and not ( perlin1:get2d( { x = x0 + ( (x1-x0)/2), y=z0 } ) > 0.53 )--top middle
		and not (perlin1:get2d({x=x1, y=z1}) > 0.53) 						--bottom right
		and not (perlin1:get2d({x=x1, y=z0+((z1-z0)/2)}) > 0.53) 			--right middle
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53)  						--bottom left
		and not (perlin1:get2d({x=x1, y=z0}) > 0.53)						--top right
		and not (perlin1:get2d({x=x0+((x1-x0)/2), y=z1}) > 0.53) 			--left middle
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) 			--middle
		and not (perlin1:get2d({x=x0, y=z1+((z1-z0)/2)}) > 0.53) then		--bottom middle
			print("abortsumpf")
			return
		end
		local divs = (maxp.x-minp.x);
		local pr = PseudoRandom(seed+68)

		--remove usual stuff
		local trees = env:find_nodes_in_area(minp, maxp, USUAL_STUFF)
		for i,v in pairs(trees) do
			env:remove_node(v)
		end

		--Information:
		if sumpf.info then
			local geninfo = "-#- Swamp generates: x=["..minp.x.."; "..maxp.x.."] z=["..minp.z.."; "..maxp.z.."]"
			print(geninfo)
			minetest.chat_send_all(geninfo)
		end

		local smooth = sumpf.smooth
		local swampwater = sumpf.swampwater

		for j=0,divs do
			for i=0,divs do
				local x,z = x0+i,z0+j

				--Check if we are in a "Swamp biome"
				local in_biome = false
				local test = perlin1:get2d({x=x, y=z})
				--smooth mapgen
				if sumpf.always_generate then
					in_biome = true
				elseif smooth and (test > 0.73 or (test > 0.43 and pr:next(0,29) > (0.73 - test) * 100 )) then
					in_biome = true
				elseif (not smooth) and test > 0.53 then
					in_biome = true
				end

				if in_biome then

					local ground_y = nil --Definition des Bodens:
					for y=maxp.y,0,-1 do
						if find_ground({x=x,y=y,z=z}, EVSUMPFGROUND) then
							ground_y = y
							break
						end
					end
					local ground = {x=x,y=ground_y,z=z}
					if ground_y
					and find_ground({x=x,y=ground_y,z=z}, SUMPFGROUND) then	--Pflanzen (und Pilz):
						local boden = {x=x,y=ground_y+1,z=z}
						if sumpf.enable_plants then
							if pr:next(1,80) == 1 then
								mache_birke(boden)
							elseif pr:next(1,20) == 1 then
								sumpf_make_jungletree(boden)
							elseif pr:next(1,50) == 1 then
								env:add_node(boden, {name="riesenpilz:brown"})
							elseif pr:next(1,100) == 1 then
								env:add_node(boden, {name="riesenpilz:red"})
							elseif pr:next(1,200) == 1 then
								env:add_node(boden, {name="riesenpilz:fly_agaric"})
							elseif pr:next(1,4) == 1 then
								env:add_node(boden, {name="sumpf:gras"})
							elseif pr:next(1,6) == 1 then
								env:add_node(boden, {name="default:junglegrass"})
							end
						end	--Sumpfwasser:
						if swampwater
						and pr:next(1,2) == 2
						and avoid_nearby_node(ground, "air")
						and avoid_nearby_node(ground, "default:junglegrass")
						and avoid_nearby_node(ground, "sumpf:gras")
						and avoid_nearby_node(ground, "riesenpilz:brown")
						and avoid_nearby_node(ground, "riesenpilz:red")
						and avoid_nearby_node(ground, "riesenpilz:fly_agaric")
						and avoid_nearby_node(ground, "ignore")
						and env:get_node(boden).name == "air" then
							for s=0,-20-pr:next(1,9),-1 do
								local pos = {x=x,y=ground_y+s,z=z}
								if env:get_node(pos).name ~= "air" then
									env:add_node(pos, {name="sumpf:dirtywater_source"})
								else
									break
								end
							end
						else --Sumpfboden:
							for l=-1,0,1 do
								env:add_node({x=x,y=ground_y+l,z=z}, {name="sumpf:sumpf"})
							end
							env:add_node({x=x,y=ground_y-2,z=z}, {name="sumpf:sumpf2"})
							for i=-3,-30,-1 do
								local pos = {x=x,y=ground_y+i,z=z}
								if env:get_node(pos).name ~= "air" then
									env:add_node(pos, {name="sumpf:junglestone"})
								else
									break
								end
							end
						end --Dreckseen:
					elseif ground_y
					and env:get_node(ground).name == "default:water_source"
					and env:find_node_near(ground, 3+pr:next(1,2), "group:crumbly") then
						for y=0,-30,-1 do
							local pos = {x=x,y=ground_y+y,z=z}
							if env:get_node(pos).name == "default:water_source" then
								env:add_node(pos, {name="sumpf:dirtywater_source"})
							else
								env:add_node(pos, {name="sumpf:peat"})
							end
						end
					end
				end
			end
		end
	end
	-- Generate ores
	generate_kohle(minp, maxp, seed+0, 1/8/8/8,	3, -31000,  64)
	generate_eisen(minp, maxp, seed+1, 1/12/12/12, 2,	-15,   2)
	generate_eisen(minp, maxp, seed+2, 1/9/9/9,	3,	-63, -16)
	generate_eisen(minp, maxp, seed+3, 1/7/7/7,	3, -31000, -64)
	
	generate_kohle(minp, maxp, seed+7, 1/24/24/24, 6, -31000,  0)
	generate_eisen(minp, maxp, seed+6, 1/24/24/24, 6, -31000, -64)
end)
