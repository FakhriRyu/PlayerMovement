extends Control

@onready var diamond_counter = $DiamondCounter

func _ready():
	# Wait for GameManager to be ready
	await get_tree().process_frame
	# Connect to GameManager signals
	GameManager.diamond_collected.connect(_on_diamond_collected)
	# Initialize the display
	diamond_counter.text = str(GameManager.diamond_count)

func _on_diamond_collected():
	# Update the diamond counter display
	diamond_counter.text = str(GameManager.diamond_count)
