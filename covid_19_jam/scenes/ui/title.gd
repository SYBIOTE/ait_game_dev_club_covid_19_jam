extends Control



func _on_play_pressed():
	Loader.goto_scene("res://scenes/map/indoors/bed_room.tscn")


func _on_quit_pressed():
	get_tree().quit()
