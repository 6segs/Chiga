extends Control

func DefTexto(texto: String):
	$Label.text = "[center]" + texto
	
	match texto:
		"PERFECTO!":
			$Label.set("theme_override_colors/default_color", Color("ff643f"))
		"Bien":
			$Label.set("theme_override_colors/default_color", Color("00be25"))
		"Bien":
			$Label.set("theme_override_colors/default_color", Color("cabc00"))
		_:
			$Label.set("theme_override_colors/default_color", Color("b5002e"))
