extends Button

var UpgradeIcon = preload("res://Sprites/Sprite-0001.png")

func change_icon(newIcon: String):
	var iconRes = load(newIcon)
	$itemIcon.texture = iconRes
	UpgradeIcon = iconRes

func change_building_mps():
	
