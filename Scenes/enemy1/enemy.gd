extends KinematicBody2D

var vida = 1#int(round(3*global.dificuldade))

var velocidade_maxima = 25
var theta = 0

var dano_str = preload("res://Scenes/etc/str_damage.tscn")

func _ready():
	add_to_group('Inimigo')
	set_physics_process(true)

func _physics_process(delta):
	if not vida <= 0:
		theta += delta
		move_and_slide(((global.jogador.global_position - self.global_position).normalized() + Vector2(0, sin(theta*PI))) * velocidade_maxima, Vector2())
	else:
		pass
	
func causar_dano(dano):
	var i = dano_str.instance()
	i.rect_global_position = self.global_position + Vector2(0, -i.get_line_height())
	i.text = str(dano)
	get_parent().add_child(i)
	
	vida -= dano
	if vida <= 0:
		global.dificuldade += 0.1
		$collision_shape_2d.disabled = true
		$area_2d/collision_shape_2d.disabled = true
		$tween_dead_x.interpolate_property(self, 'global_position:x', self.global_position.x, self.global_position.x + rand_range(20, 25), 1.5, Tween.TRANS_SINE, Tween.EASE_OUT)
		$tween_dead_y.interpolate_property(self, 'global_position:y', self.global_position.y, self.global_position.y + rand_range(150, 200), 1.0, Tween.TRANS_BACK, Tween.EASE_IN)
		$tween_dead_rotacao.interpolate_property(self, 'rotation', self.rotation, self.rotation + (2*PI/2)*rand_range(0.1, 0.9), 1.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
		$tween_dead_x.start()
		$tween_dead_y.start()
		$tween_dead_rotacao.start()

func _on_area_2d_body_entered(body): if body.is_in_group('Jogador'): body.causar_dano(1)
func _on_tween_dead_y_tween_completed(object, key): self.queue_free()
