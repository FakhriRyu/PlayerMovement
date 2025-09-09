extends Area2D

func _on_body_entered(body):
	# Check if the body that entered is the player
	if body.name == "Player":
		# Notify GameManager that a diamond was collected
		GameManager.collect_diamond()
		# Remove the diamond from the scene
		queue_free()
