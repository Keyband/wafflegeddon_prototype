extends KinematicBody2D

var vida = int(round(1*global.dificuldade))

var vetor_velocidade = Vector2()
var animacao = 'idle'
var vetor_gravidade = Vector2(0,20)
var vetor_normal = Vector2(0,-1)

var velocidade_pulo = 150
var velocidade_maxima = 65

var dano_str = preload("res://Scenes/etc/str_damage.tscn")
var coracao = preload("res://Scenes/etc/heart.tscn")

func _ready():
	add_to_group('Inimigo')
	set_physics_process(true)

func _physics_process(delta):
	if animacao != $animation_player.current_animation: $animation_player.play(animacao)
#	$sprite.flip_h = false#false if (global.jogador.global_position - self.global_position).x < 0 else true
	if not vida <= 0:
		var vetor_direcao_do_movimento = Vector2(-1, 0)#(global.jogador.global_position - self.global_position).normalized()
#		print(vetor_direcao_do_movimento)
		vetor_velocidade.x = vetor_direcao_do_movimento.x * velocidade_maxima#lerp(vetor_velocidade.x, vetor_direcao_do_movimento.x * velocidade_maxima, 0.1)
		vetor_velocidade.y += vetor_gravidade.y# + vetor_direcao_do_movimento.y * velocidade_pulo
		vetor_velocidade = move_and_slide(vetor_velocidade, vetor_normal)
		animacao = 'idle' if vetor_velocidade.length() < 0.1 else 'moving'
	else:
		pass

func causar_dano(dano):
	var i = dano_str.instance()
	i.rect_global_position = self.global_position + Vector2(0, -i.get_line_height())
	i.text = str(dano)
	get_parent().add_child(i)

	vida -= dano
	if vida <= 0:
		randomize()
		if randf() > 0.75:
			var j = coracao.instance()
			j.global_position = self.global_position
			get_parent().add_child(j)
		
		global.jogador.dinheiro += 10
		animacao = 'dead'
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
