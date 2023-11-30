extends BaseInputHandler
class_name AutoFightInputHandler

func get_action(player: Entity) -> Action:
	return AutoFightAction.new(player)
