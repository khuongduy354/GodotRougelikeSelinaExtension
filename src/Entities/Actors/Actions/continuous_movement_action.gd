extends ActionWithDirection
class_name ContinuousMovementAction

func check_line_or_col_unwalkable(source: Vector2i)->bool:
	# source is top left corner
	# xxx
	# 000
	# 000
	
	# or 
	
	# 00x
	# 00x
	# 00x 
	
	# check row 
	var row_blocked = false
	for i in range(3): 
		for j in range(3): 
			var tile = get_map_data().get_tile(source + Vector2i(i,j))
			if tile.is_walkable(): 
				continue
			if j == 2: 
				row_blocked = true
	# check col 
	var col_blocked = false 
	for i in range(3): 
		for j in range(3): 
			var tile = get_map_data().get_tile(source + Vector2i(j,i))
			if tile.is_walkable(): 
				continue
			if j == 2: 
				col_blocked = true
	return col_blocked or row_blocked

func perform() -> bool:
	# check enemy in sight 
	var map_data = get_map_data()
	var enemy_in_sight = map_data.get_nearest_enemy() != null
	
	# check intersection 
	var path_dirs = [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
	var block_dirs = [Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(1,-1 )]
	var paths_count = 0 
	var blocks_count = 0 
	var curr_pos = entity.grid_position
	
	for i in range(0,4): 
		var straight_tile = map_data.get_tile(curr_pos+path_dirs[i])
		var dia_tile = map_data.get_tile(curr_pos+block_dirs[i])
		if straight_tile.is_walkable(): 
			paths_count += 1 
		if !dia_tile.is_walkable():
			blocks_count +=1
	
	var intersected = paths_count >= 3 and blocks_count >=3
	
	# edge case for intersection 
	if intersected and paths_count == 3 and blocks_count == 3:  
		var source = curr_pos + Vector2i(-1,-1)
		# contain = not intersected
		intersected = !check_line_or_col_unwalkable(source)		
	
	# single path corridor
	var candidate = offset 
	# among walkable paths of 2, if intended dir is walkable pick it
	# else pick the one that isn't the previous position
	if paths_count == 2: 
		for dir in path_dirs: 
			var tpos = curr_pos + dir
			var tile = map_data.get_tile(tpos)
			if tile.is_walkable(): 
				if offset == dir: 
					candidate = dir
					break 
				elif map_data.previous_player_position != tpos and blocks_count == 4: 
					candidate = dir
	offset = candidate

	# dont walk over item
	var is_on_item = false
	for item in map_data.get_items(): 
		if item.grid_position == entity.grid_position: 
			is_on_item = true
			break
		

	if !enemy_in_sight and !intersected and !is_on_item:
		return MovementAction.new(entity, offset.x, offset.y).perform()
	return false 


# autofight: keep attacking unless
# at least 1 enemy in sight
