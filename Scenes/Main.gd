extends Node2D

@onready var map_image: Sprite2D = $Sprite2D


func _ready():
	load_regions()

func load_regions():
	var image := map_image.texture.get_image()
	var pixel_color_dict := get_pixel_color_dict(image)
	var regions_dict = import_file("res://Map_data/regions.txt")
	if regions_dict == null:
		return
	
	for region_color: String in regions_dict:
		var region := load("res://Scenes/Region_Area.tscn").instantiate() as RegionArea
		region.region_name = regions_dict[region_color]
		region.name = region_color
		get_node("Regions").add_child(region)
		
		var polygons := get_polygons(image, region_color, pixel_color_dict)
		
		for polygon in polygons:
			var region_collision = CollisionPolygon2D.new()
			var region_polygon = Polygon2D.new()
			
			region_collision.polygon = polygon
			region_polygon.polygon = polygon
			
			region.add_child(region_collision)
			region.add_child(region_polygon)
	map_image.queue_free()

## Return a dict of each color in the image mapped to their coordinates.
func get_pixel_color_dict(image: Image) -> Dictionary[String, Array]:
	var pixel_color_dict: Dictionary[String, Array] = {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel_color := "#" + str(image.get_pixel(int(x), int(y)).to_html(false))
			pixel_color_dict.get_or_add(pixel_color, []).append(Vector2i(x, y))
	return pixel_color_dict

## Return polygons for the region of a specific color in the image.
func get_polygons(image: Image, region_color: String, pixel_color_dict: Dictionary[String, Array]) -> Array[PackedVector2Array]:
	var target_image := Image.create_empty(image.get_size().x, image.get_size().y, false, Image.FORMAT_RGBA8)
	for value in pixel_color_dict[region_color]:
		target_image.set_pixelv(value, Color.WHITE)
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(target_image)
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0,0), bitmap.get_size()), 0.1)
	return polygons

## Import JSON files and converts to lists or dictionary.
func import_file(filepath: String):
	if FileAccess.file_exists(filepath):
		return JSON.parse_string(FileAccess.get_file_as_string(filepath).replace("_", " "))
	push_error("Failed to open file: ", filepath)
	return null
