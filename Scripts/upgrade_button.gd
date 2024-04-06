extends Button
signal clicked(id)

var UpgradeIcon = preload("res://Sprites/Sprite-0001.png")

var id
var price = 0

var effects = {'building': '', 'effect': '', 'action': '', 'value': null}
var applied = false

func change_icon(newIcon: String):
	var iconRes = load(newIcon)
	$upgrade_button.icon = iconRes
	UpgradeIcon = iconRes

func change_name(newName: String):
	pass

func _on_pressed():
	clicked.emit(id)
