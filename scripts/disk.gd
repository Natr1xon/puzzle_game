extends ColorRect

var disk_size: int

func setup(s: int):
	disk_size = s
	self.size = Vector2(20 * s, 20)
