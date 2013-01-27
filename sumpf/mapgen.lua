local function generate_kohle(minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
	default.generate_ore(
		"sumpf:kohle", "sumpf:junglestone", minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max
	)
end

local function generate_eisen(minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
	default.generate_ore(
		"sumpf:eisen", "sumpf:junglestone", minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max
	)
end


SUMPFGROUND	=	{"default:dirt_with_grass","default:dirt","default:sand","default:desert_sand"}
EVSUMPFGROUND =	{"default:dirt_with_grass","default:dirt","default:sand","default:desert_sand", "default:water_source"}
minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= -10 then
		-- Assume X and Z lengths are equal
		local divs = (maxp.x-minp.x);
		local x0,z0,x1,z1,env = minp.x,minp.z,maxp.x,maxp.z,minetest.env
		local perlin1 = env:get_perlin(11,3, 0.5, 200)
			pr = PseudoRandom(seed+68)

		--[[if not (perlin1:get2d({x=x0, y=z0}) > 0.53) and not (perlin1:get2d({x=x1, y=z1}) > 0.53)
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53) and not (perlin1:get2d({x=x1, y=z0}) > 0.53)
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) then]]
		if not ( perlin1:get2d( {x=x0, y=z0} ) > 0.53 ) 					--top left
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

		--remove usual stuff
		local trees = env:find_nodes_in_area(minp, maxp, {"default:leaves","default:tree"})
		for i,v in pairs(trees) do
			env:remove_node(v)
		end

		--Information:
		local geninfo = "-#- Swamp generated: [x= ("..minp.x..", "..maxp.x..")] [z= ("..minp.z..", "..maxp.z..")]"
		print(geninfo)
		minetest.chat_send_all(geninfo)

		local smooth = sumpf.smooth
		local bi = pr:next(1,2) == 1

		for j=0,divs do
		for i=0,divs do
			local x,z = x0+i,z0+j

			--Check if we are in a "Swamp biome"
			local in_biome = false
			local test = perlin1:get2d({x=x, y=z})
			--smooth mapgen
			if smooth and (test > 0.73 or (test > 0.43 and pr:next(0,29) > (0.73 - test) * 100 )) then
				in_biome = true
			elseif (not smooth) and test > 0.53 then
				in_biome = true
			end

			if in_biome then

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
					end --Sumpfwasser:			doesn't work
					if pr:next(1,4) == 1 then
						if notnod == "air"
						or notnod == "group:snappy" then
							if	env:get_node({x=x+1,y=ground_y,z=z}).name ~= notnod
							and env:get_node({x=x-1,y=ground_y,z=z}).name ~= notnod
							and env:get_node({x=x,y=ground_y,z=z+1}).name ~= notnod
							and env:get_node({x=x,y=ground_y,z=z-1}).name ~= notnod  then
								for s=0,-30,-1 do
									env:add_node({x=x,y=ground_y+s,z=z}, {name="sumpf:dirtywater_source"})
									env:add_node({x=x,y=ground_y+1,z=z}, {name="air"}) --because of the plants
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
								env:add_node({x=x,y=ground_y+y,z=z}, {name="sumpf:peat"})
							end
						end
					end
					end
					end
				end
			end
		end
	end
	-- Generate ores
	generate_kohle(minp, maxp, seed+0, 1/8/8/8,	3, 8, -31000,  64)
	generate_eisen(minp, maxp, seed+1, 1/12/12/12, 2, 3,	-15,   2)
	generate_eisen(minp, maxp, seed+2, 1/9/9/9,	3, 5,	-63, -16)
	generate_eisen(minp, maxp, seed+3, 1/7/7/7,	3, 5, -31000, -64)
	
	generate_kohle(minp, maxp, seed+7, 1/24/24/24, 6,27, -31000,  0)
	generate_eisen(minp, maxp, seed+6, 1/24/24/24, 6,27, -31000, -64)
end)
