extends Area2D

@export var required_diamonds = 3
@export var next_scene_path = "res://Scenes/level_one.tscn"

@onready var diamond_label = $DiamondLabel

func _ready():
	# Wait for GameManager to be ready
	await get_tree().process_frame
	# Connect to GameManager signals to update label
	GameManager.diamond_collected.connect(_on_diamond_collected)
	# Initialize the label
	update_diamond_label()

func _on_diamond_collected():
	update_diamond_label()

func update_diamond_label():
	diamond_label.text = str(GameManager.diamond_count) + "/" + str(required_diamonds)

func _on_body_entered(body):
	# Check if the body that entered is the player
	if body.name == "Player":
		# Check if player has enough diamonds
		if GameManager.diamond_count >= required_diamonds:
			# Reset diamond counter before changing scene
			GameManager.reset_diamonds()
			# Transition to next scene using call_deferred to avoid physics callback issues
			get_tree().call_deferred("change_scene_to_file", next_scene_path)
		else:
			# Show message that more diamonds are needed
			var needed = required_diamonds - GameManager.diamond_count
			print("You need ", needed, " more diamonds to open this door!")
			print("Current diamonds: ", GameManager.diamond_count, "/", required_diamonds)
			
			# Show message on screen (optional - you can add UI for this)
			show_message("Need " + str(needed) + " more diamonds!")

func show_message(text: String):
	# Create a temporary label to show the message
	var label = Label.new()
	label.text = text
	label.position = Vector2(100, 100)
	label.add_theme_font_size_override("font_size", 24)
	
	# Add to scene tree safely
	if is_inside_tree() and get_tree().current_scene:
		get_tree().current_scene.add_child(label)
		
		# Remove the label after 2 seconds
		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(label):
			label.queue_free()
