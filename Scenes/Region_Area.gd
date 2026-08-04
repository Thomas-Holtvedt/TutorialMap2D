class_name RegionArea
extends Area2D

var region_name := ""


func _on_child_entered_tree(node):
	if node is Polygon2D:
		node.color = Color.html(name)

func _on_mouse_entered():
	print(region_name)
	for node in get_children():
		if node is Polygon2D:
			node.color = Color(1,1,1,1)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		print(str(region_name) + " Clicked")

func _on_mouse_exited():
	for node in get_children():
		if node is Polygon2D:
			node.color = Color.html(name)
