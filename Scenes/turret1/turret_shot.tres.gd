extends Area2D
var dano = 1#global.jogador.dano_projetil
var vetor_direcao = Vector2(1,0)
var velocidade_maxima = 250

func _ready():
	self.rotation = vetor_direcao.angle()

func _physics_process(delta): global_translate( vetor_direcao.normalized() * velocidade_maxima * delta)

func _on_allied_shot_body_entered(body):
	if not body.is_in_group('Jogador'):
		if body.is_in_group('Inimigo'):
			body.causar_dano(dano)
			self.queue_free()
		else:
			self.queue_free()

func _on_tmr_free_timeout(): self.queue_free()


func _on_allied_shot_area_entered(area): pass
#	if area.is_in_group('Torreta'):
#		area.recarregar(dano)
#		self.queue_free()
