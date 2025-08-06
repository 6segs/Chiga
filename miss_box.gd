extends Area2D

signal arrow_missed(body)

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("arrows"):
		emit_signal("arrow_missed", body)
		body.queue_free()
