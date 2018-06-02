extends KinematicBody2D

var vida = int(round(1*global.dificuldade))

var animacao = 'moving'
var velocidade_maxima = 25
var theta = 0

var tiro = preload("res://Scenes/enemy1/enemy_shot.tscn")
var dano_str = preload("res://Scenes/etc/str_damage.tscn")
var coracao = preload("res://Scenes/etc/heart.tscn")

func _ready():
	add_to_group('Inimigo')
	add_to_group('Voador')
	set_physics_process(true)

func _physics_process(delta):
	if animacao != $animation_player.current_animation: $animation_player.play(animacao)
#	$sprite.flip_h = false if (global.jogador.global_position - self.global_position).x < 0 else true
	if not vida <= 0:
		theta += delta
		move_and_slide((Vector2(-1,0) + Vector2(0, - 0.15 * pow(sin(theta*PI), 2))) * velocidade_maxima, Vector2(0, 0))
		#move_and_slide(((global.jogador.global_position - self.global_position).normalized() + Vector2(0, - 1.4 * pow(sin(theta*PI), 2))) * velocidade_maxima, Vector2())
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
		
		animacao = 'dead'
		global.dificuldade += 0.1
		global.jogador.dinheiro += 15
		$collision_shape_2d.disabled = true
		$area_2d/collision_shape_2d.disabled = true
		$tween_dead_x.interpolate_property(self, 'global_position:x', self.global_position.x, self.global_position.x + rand_range(20, 25), 1.5, Tween.TRANS_SINE, Tween.EASE_OUT)
		$tween_dead_y.interpolate_property(self, 'global_position:y', self.global_position.y, self.global_position.y + rand_range(150, 200), 1.0, Tween.TRANS_BACK, Tween.EASE_IN)
		$tween_dead_rotacao.interpolate_property(self, 'rotation', self.rotation, self.rotation + (2*PI/2)*rand_range(0.1, 0.9), 1.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
		$tween_dead_x.start()
		$tween_dead_y.start()
		$tween_dead_rotacao.start()

func atirar():
	$snd_shot.play()
	var i = tiro.instance()
	i.global_position = self.global_position
	i.vetor_direcao = Vector2(1,0).rotated((global.jogador.global_position - self.global_position).angle())
	get_parent().add_child(i)

func _on_area_2d_body_entered(body): if body.is_in_group('Jogador'): body.causar_dano(1)
func _on_tween_dead_y_tween_completed(object, key): self.queue_free()

#func _on_tmr_newpath_timeout():
#	caminho = get_parent().get_node('Navigation2D').get_simple_path(self.global_position, global.alvo.global_position, false)
#	caminho.remove(caminho.size())
#	#Se o caminho tiver mais de um valor, entao descubra a direcao para continuar no caminho,
#	#e sete a velocidade_vetor com ela.
#	if caminho.size() > 1:
#		var distancia_ao_proximo_ponto = caminho[1] - self.global_position
#		var direcao_do_caminho = distancia_ao_proximo_ponto.normalized()
#
#		if distancia_ao_proximo_ponto.length() > distancia_minima_para_parar_o_movimento or caminho.size() > 2:
#			velocidade_vetor = direcao_do_caminho * VELOCIDADE_MAXIMA * delta
#		else:
#			velocidade_vetor = Vector2()
