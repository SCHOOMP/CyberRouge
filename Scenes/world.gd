extends Node2D

@onready var _character = $PlayerCharacter
@onready var _label = $PlayerCharacter/Camera2D/HUD/Stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_label.update_text(_character.level, _character.experience, _character.experience_required, _character.speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_label.update_text(_character.level, _character.experience, _character.experience_required, _character.speed)
