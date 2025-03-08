extends Label

func update_text(level, experience, required_xp, speed, health):
	text = """Level: %s
			Exp: %s
			Next Level: %s
			Speed: %s
			Health: %s
			""" % [level, experience, required_xp, speed, health]
