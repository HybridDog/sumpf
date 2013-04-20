--Habitat is a mod which adds the function to spawn nodes near certain nodes and away from others on map generate

local function arrayContains(array, value)
    for _,v in pairs(array) do
      if v == value then
        return true
      end
    end

    return false
end

--HOW TO USE
--minetest.register_on_generated(function(minp, maxp, seed)
    --generate("plants:lavender_wild", {"default:dirt_with_grass"}, minp, maxp, -10, 60, 4, 4, {"default:sand",})
--end)

function generate(node, surfaces, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes, antitat_size, antitat_nodes)
    
    if height_min > maxp.y or height_max < minp.y then --stop if min and max height of plant spawning is not generated area
		return
	end
	
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	
	local width   = maxp.x-minp.x
	local length  = maxp.z-minp.z
	local height  = height_max-height_min
    
    local y_current
	local x_current
	local z_current
	
	local x_deviation
	local z_deviation
	
	local p
	local n
	local p_top
	local n_top
	
	--loop and take steps depending on the spread of the plants
	for x_current = spread/2, width, spread do
	    for z_current = spread/2, length, spread do

	        x_deviation = math.floor(math.random(spread))-spread/2
	        z_deviation = math.floor(math.random(spread))-spread/2

	        for y_current = height_max, height_min, -1 do --loop to look for the node that is not air
	            p = {x=minp.x+x_current+x_deviation, y=y_current, z=minp.z+z_current+z_deviation}
	            n = minetest.env:get_node(p)
	            p_top = {x=p.x, y=p.y+1, z=p.z}
	            n_top = minetest.env:get_node(p_top)
	            
	            if n.name ~= "air" and n_top.name == "air" then
                    if arrayContains(surfaces, n.name) then
                        if minetest.env:find_node_near(p_top, habitat_size, habitat_nodes) ~= nil and minetest.env:find_node_near(p_top, antitat_size, antitat_nodes) == nil  then
                            minetest.env:add_node(p_top, {name=node})
                        end
                    end
	            end
	        end
	        z_current = z_current + spread
        end
    end
end

print("[Habitat] Loaded!")
