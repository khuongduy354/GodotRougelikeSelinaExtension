extends Action 
class_name AutoFightAction 

func perform()->bool: 
	var map_data = get_map_data() 
	var nearest_enemy = map_data.get_nearest_enemy()
	
	if !nearest_enemy: 
		MessageLog.send_message("No enemies in view!", GameColors.IMPOSSIBLE)
		return false 
	
	var paths = map_data.pathfinder.get_id_path(entity.grid_position, nearest_enemy.grid_position)
	
	var offset: Vector2i = paths[1] - entity.grid_position
	
	if paths.size() == 2: 
		return MeleeAction.new(entity, offset.x, offset.y).perform()
	else: 
		return MovementAction.new(entity, offset.x, offset.y).perform()
	
	
	
