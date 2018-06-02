extends KinematicBody2D

var eu = self
var vida_maxima = 3
var vida = 3
var energia_maxima = 100
var energia = 100
var dinheiro = 0

var dano_projetil = 1
var multiplicador_de_recarga = 10

var vetor_velocidade = Vector2()
var direcao_horizontal = 1
var velocidade_maxima = 150
var velocidade_pulo = 300
var animacao = ''

var vetor_gravidade = Vector2()
var vetor_gravidade_escorregando = Vector2(0,10)
var vetor_gravidade_subindo = Vector2(0,15)
var vetor_gravidade_descendo = Vector2(0,20)
var vetor_normal = Vector2(0,-1)

var pode_atirar = true
var esta_na_parede = false
var invencivel = false

var tiro = preload("res://Scenes/player/allied_shot.tscn")
var dano_str = preload("res://Scenes/etc/str_damage.tscn")

func _ready():
	add_to_group('Jogador')
	global.jogador = self
	global.alvo = self
	set_physics_process(true)
	
func _physics_process(delta):
	self.vida = clamp(self.vida, 0, self.vida_maxima)
	if invencivel: self.visible = not self.visible
	else: self.visible = true
	
	remove_collision_exception_with(global.plataformas)
#	if Input.is_action_just_pressed('ui_debug'):
#		energia += 10; vida += 3; dinheiro += 1000
	
	esta_na_parede = $raycast_l.is_colliding() or $raycast_r.is_colliding()
	
	if animacao != $animation_player.current_animation: $animation_player.play(animacao)
	if is_on_floor(): animacao = 'idle' if abs(vetor_velocidade.x) < 0.3 else 'walking'
	vetor_gravidade = vetor_gravidade_subindo if vetor_velocidade.y < 0 else vetor_gravidade_escorregando if esta_na_parede else vetor_gravidade_descendo
	
	$Sprite.flip_h = true if direcao_horizontal < 0 else false
	$pos_gun.position.x = -9 if $Sprite.flip_h else 9#; if esta_na_parede: $pos_gun.position.x *= -1
	
	var vetor_direcao_do_movimento = Vector2()
	var direcao_h = 1 if Input.is_action_pressed('ui_right') else -1 if Input.is_action_pressed('ui_left') else 0
	direcao_horizontal = direcao_h if direcao_h != 0 else direcao_horizontal
	vetor_direcao_do_movimento.x = direcao_h
	if direcao_h == 0 and Input.is_action_pressed('ui_down'): animacao = 'crouch'
	
	if Input.is_action_pressed('ui_shoot') and pode_atirar: atirar()
	
#	if not is_on_floor() and esta_na_parede:
#		if is_on_wall(): vetor_velocidade.y = 0
#		$Sprite.flip_h = not $Sprite.flip_h
#		animacao = 'sliding'
	
	if Input.is_action_just_pressed('ui_jump'):
		if is_on_floor():
			if Input.is_action_pressed('ui_down'):
				add_collision_exception_with(global.plataformas)
				pass
			else:
				animacao = 'jump'
				$sounds/snd_jump.play()
				vetor_velocidade.y = 0
				vetor_direcao_do_movimento.y -= 1
#		elif $raycast_l.is_colliding():
#			animacao = 'jump'
#			$sounds/snd_walljump.play()
#			vetor_velocidade.y = 0
#			vetor_direcao_do_movimento.x = 1
#			vetor_direcao_do_movimento.y -= 1
#			vetor_velocidade.x = vetor_direcao_do_movimento.x * velocidade_maxima
#		elif $raycast_r.is_colliding():
#			animacao = 'jump'
#			$sounds/snd_walljump.play()
#			vetor_velocidade.y = 0
#			vetor_direcao_do_movimento.x = -1
#			vetor_direcao_do_movimento.y -= 1
#			vetor_velocidade.x = vetor_direcao_do_movimento.x * velocidade_maxima
	
	vetor_velocidade.x = lerp(vetor_velocidade.x, vetor_direcao_do_movimento.x * velocidade_maxima, 0.2)
	vetor_velocidade.y += vetor_gravidade.y + vetor_direcao_do_movimento.y * velocidade_pulo
	vetor_velocidade = move_and_slide(vetor_velocidade, vetor_normal)
	
func atirar():
#	if energia >= 0:
#		energia -= 5
	$sounds/snd_shot.play()
	pode_atirar = false; $tmr_shoot.start()
	var i = tiro.instance()
	i.global_position = $pos_gun.global_position
	var lado = PI if direcao_horizontal < 0 else 0#; if esta_na_parede: lado += PI
	i.vetor_direcao = Vector2(1,0).rotated(lado)
	$raycast_l.add_exception(i); $raycast_r.add_exception(i)
	get_parent().add_child(i)
		

func causar_dano(dano):
	if not invencivel:
		invencivel = true
		$tmr_invincibility.start()
		
		$sounds/snd_hurt.play()
		var i = dano_str.instance()
		i.rect_global_position = self.global_position + Vector2(0, -i.get_line_height())
		i.text = str(dano)
		get_parent().add_child(i)
		
		vida -= dano
		if vida <= 0:
			animacao = 'dead'; $animation_player.play(animacao)
			set_physics_process(false)
			$CollisionShape2D.disabled = true
			
			yield(get_tree().create_timer(5.0), 'timeout')
			get_tree().reload_current_scene()
	#		self.queue_free()

func _on_tmr_shoot_timeout(): pode_atirar = true

func _on_tmr_invincibility_timeout(): invencivel = false
