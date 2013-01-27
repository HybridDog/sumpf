local function generate_ore(name, wherein, minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed)
	local num_chunks = math.floor(chunks_per_volume * volume)
	local inverse_chance = math.floor(chunk_size*chunk_size*chunk_size / ore_per_chunk)
	--print("generate_ore num_chunks: "..dump(num_chunks))
	for i=1,num_chunks do
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
local function generate_kohle(minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
generate_ore("sumpf:kohle", "sumpf:junglestone", minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
end
local function generate_eisen(minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
generate_ore("sumpf:eisen", "sumpf:junglestone", minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
end

SUMPFGROUND	=	{"default:dirt_with_grass","default:dirt","default:sand","default:desert_sand"}
EVSUMPFGROUND =	{"default:dirt_with_grass","default:dirt","default:sand","default:desert_sand", "default:water_source"}
minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= -10
	and maxp.y <= 200
	and minp.y >= -10
		then
		-- Assume X and Z lengths are equal
		local divs = (maxp.x-minp.x);
		local x0,z0,x1,z1,env = minp.x,minp.z,maxp.x,maxp.z,minetest.env
		local perlin1 = env:get_perlin(11,3, 0.5, 200)
			pr = PseudoRandom(seed+68)

		if not (perlin1:get2d({x=x0, y=z0}) > 0.53) and not (perlin1:get2d({x=x1, y=z1}) > 0.53)
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53) and not (perlin1:get2d({x=x1, y=z0}) > 0.53)
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) then
			print("abortsumpf")
			return
		end

		for j=0,divs do
			for i=0,divs do
				local x,z = x0+i,z0+j
				local bi = pr:next(1,2) == 1
				local test = perlin1:get2d({x=x, y=z})
				if test > 0.53 then

					local ground_y = nil --Definition des Bodens:
					for _, ground in ipairs(SUMPFGROUND) do
						for _, evground in ipairs(EVSUMPFGROUND) do
							for y=maxp.y,0,-1 do
								if env:get_node({x=x,y=y,z=z}).name == evground then
									ground_y = y
									break
								end
							end

						if ground_y
						and env:get_node({x=x,y=ground_y,z=z}).name == ground then
							if bi then --Pflanzen (und Pilz):
								if pr:next(1,40) == 1 then
									mache_birke({x=x,y=ground_y+1,z=z})
								elseif pr:next(1,10) == 1 then
									env:add_node({x=x,y=ground_y+1,z=z}, {name="jungletree:sapling"})
								elseif pr:next(1,25) == 1 then
									env:add_node({x=x,y=ground_y+1,z=z}, {name="sumpf:pilz"})
								elseif pr:next(1,2) == 1 then
									env:add_node({x=x,y=ground_y+1,z=z}, {name="sumpf:gras"})
								elseif pr:next(1,3) == 1 then
									env:add_node({x=x,y=ground_y+1,z=z}, {name="default:junglegrass"})
								end
							end --Sumpfwasser:
							if pr:next(1,4) == 1 then
								if notnod == "air"
								or notnod == "group:snappy" then
									if	env:get_node({x=x+1,y=ground_y,z=z}).name ~= notnod
									and env:get_node({x=x-1,y=ground_y,z=z}).name ~= notnod
									and env:get_node({x=x,y=ground_y,z=z+1}).name ~= notnod
									and env:get_node({x=x,y=ground_y,z=z-1}).name ~= notnod  then
										for s=0,-30,-1 do
											env:add_node({x=x,y=ground_y+s,z=z}, {name="sumpf:dirtywater_source"})
											env:add_node({x=x,y=ground_y+1,z=z}, {name="air"})
										end
									end
								end
							else --Sumpfboden:
								for i=-3,-30,-1 do
									for l=-1,0,1 do
										if env:get_node({x=x,y=ground_y+i,z=z}).name ~= "air" then
											env:add_node({x=x,y=ground_y+l,z=z}, {name="sumpf:sumpf"})
											env:add_node({x=x,y=ground_y-2,z=z}, {name="sumpf:sumpf2"})
											env:add_node({x=x,y=ground_y+i,z=z}, {name="sumpf:junglestone"})
										else break
										end
									end
								end
							end --Dreckseen:
							elseif ground_y
							and env:get_node({x=x,y=ground_y,z=z}).name == "default:water_source"
							and env:find_node_near({x=x,y=ground_y,z=z}, 2+math.random(3), "group:crumbly") then
								for y=0,-30,-1 do
									if env:get_node({x=x,y=ground_y+y,z=z}).name == "default:water_source" then
										env:add_node({x=x,y=ground_y+y,z=z}, {name="sumpf:dirtywater_source"})
									else
										env:add_node({x=x,y=ground_y+y+1,z=z}, {name="sumpf:junglestone"})
										break
									end
								end
							end
						end
					end
				end
			end
		end  --Information:
		local geninfo = "-#- Swamp generated: [x= ("..minp.x..", "..maxp.x..")] [z= ("..minp.z..", "..maxp.z..")]"
		print(geninfo)
		minetest.chat_send_all(geninfo)
	-- Generate ores
	generate_kohle(minp, maxp, seed+0, 1/8/8/8,    3, 8, -31000,  64)
	generate_eisen(minp, maxp, seed+1, 1/12/12/12, 2, 3,    -15,   2)
	generate_eisen(minp, maxp, seed+2, 1/9/9/9,    3, 5,    -63, -16)
	generate_eisen(minp, maxp, seed+3, 1/7/7/7,    3, 5, -31000, -64)
	
	generate_kohle(minp, maxp, seed+7, 1/24/24/24, 6,27, -31000,  0)
	generate_eisen(minp, maxp, seed+6, 1/24/24/24, 6,27, -31000, -64)
	end
end)
