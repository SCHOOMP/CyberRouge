extends Label

func update_text(level, experience, required_xp, speed):
	text = """Level: %s
			Exp: %s
			Next Level: %s
			Speed: %s
			""" % [level, experience, required_xp, speed]
