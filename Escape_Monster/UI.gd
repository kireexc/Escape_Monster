extends Node

func _ready():
	$MenuButton.get_popup().add_item("VSlider")

func _on_VSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value*(-1))
