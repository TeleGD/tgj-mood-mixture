extends Node2D

@export var target_color = GameScript.target_color
@export var max_distance = GameScript.max_distance
@export var min_quantity = GameScript.min_quantity
@export var show_target = true

var fill_speed = .25
var is_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _on_tree_entered() -> void:
	$Potion.target_color = GameScript.target_color
	$Potion.max_distance = GameScript.max_distance
	$Potion.min_quantity = GameScript.min_quantity
	show_target = GameScript.target_color_visible
	$TargetColor/Rect.color = target_color
	update_buttons()
	if show_target:
		$TargetColor/Rect.visible = true
		$TargetColor/Unknown.visible = false
	else:
		$TargetColor/Rect.visible = false
		$TargetColor/Unknown.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var now_pressed = false
	for ingredient_button in [$CyanIngredientButton, $MagentaIngredientButton, $YellowIngredientButton, $BlackIngredientButton]:
		if ingredient_button.button_pressed:
			now_pressed = true
			$Potion.add_liquid(delta * fill_speed, ingredient_button.color)
			update_buttons()
	
	# Maj du son si besoin
	if (not is_pressed) and now_pressed:
		$Glouglou.play()
	if is_pressed and (not now_pressed):
		$Glouglou.stop()
	is_pressed = now_pressed

func _on_terminer_potion_button_pressed() -> void:
	# Return to the ClientDialog scene
	$Potion.color = Color(1, 0, 0, 0)  # Force color to Red
	_on_submit_form_button_pressed()


func update_buttons() -> void:
	$ResetFormButton.disabled = $Potion.is_empty()
	$SubmitFormButton.disabled = !$Potion.has_enough_liquid()


func _on_reset_form_button_pressed() -> void:
	$Potion.empty_liquid()
	update_buttons()


func _on_submit_form_button_pressed() -> void:
	print($Potion.is_close_to_target())
	GameScript.is_close_to_target = $Potion.is_close_to_target()
	GameScript.distance_to_target = $Potion.compute_distance()
	GameScript.is_potion_ready = true
	get_tree().change_scene_to_file("res://Scenes/ClientDialogue.tscn")
