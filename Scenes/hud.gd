extends Label

func update_text(level, experience, required_xp):
	text = """Level: %s
			Exp: %s
			Next Level: %s
			""" % [level, experience, required_xp]
