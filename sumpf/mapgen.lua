minetest.register_alias("sumpf:pilz", "riesenpilz:brown")

local function swampore(pos, env)
	if env:get_node(pos).name == "default:stone_with_coal" then
		return "kohle"
	end
	if env:get_node(pos).name == "default:stone_with_iron" then
		return "eisen"
	end
	return "junglestone"
end

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

local function find_ground(pos, nodes)
	for _, evground in ipairs(nodes) do
		if minetest.env:get_node(pos).name == evground then
			return true
		end
	end
	return false
end

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
			print("[sumpf] abortsumpf")
			return
		end
		local divs = (maxp.x-minp.x);
		local pr = PseudoRandom(seed+68)

		--[[for i = minp.x,maxp.x,1 do
			for j = minp.y,maxp.y,1 do
				for k = minp.z,maxp.z,1 do
					if env:get_node({x=i,y=j,z=k}).name == "sumpf:sumpf" then
						local warning = "[sumpf] wants to generate again at: x=["..minp.x.."; "..maxp.x.."]; z=["..minp.z.."; "..maxp.z.."] ..not aborting"
						print(warning)
						minetest.chat_send_all(warning)
					end
				end
			end
		end]]

		--remove usual stuff
		local trees = env:find_nodes_in_area(minp, maxp, USUAL_STUFF)
		for i,v in pairs(trees) do
			env:remove_node(v)
		end

		--Information:
		if sumpf.info then
			local geninfo = "[sumpf] tries to generate a swamp at: x=["..minp.x.."; "..maxp.x.."]; z=["..minp.z.."; "..maxp.z.."]"
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
					if ground_y then
						local ground =	{x=x,y=ground_y,	z=z}
						local boden =	{x=x,y=ground_y+1,	z=z}

						if env:get_node(ground).name == "default:water_source" then	--Dreckseen:
							if env:find_node_near(ground, 3+pr:next(1,2), "group:crumbly") then
								for y=0,-30,-1 do
									local pos = {x=x,y=ground_y+y,z=z}
									if env:get_node(pos).name == "default:water_source" then
										env:add_node(pos, {name="sumpf:dirtywater_source"})
									else
										env:add_node(pos, {name="sumpf:peat"})
									end
								end
							end
						else
							if swampwater	--Sumpfwasser:
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
										env:add_node(pos, {name="sumpf:"..swampore(pos, env)})
									else
										break
									end
								end
							end

							if sumpf.enable_plants then	--Pflanzen (und Pilz):
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
							end
						end
					end
				end
			end
		end
	end
end)
