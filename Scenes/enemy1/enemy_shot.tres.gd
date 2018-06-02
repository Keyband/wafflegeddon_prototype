extends Area2D
var dano = global.dano_projetil
var vetor_direcao = Vector2(1,0)
var velocidade_maxima = 50
var textures = [preload("res://Resources/Sprites/proj2.png"), preload("res://Resources/Sprites/proj3.png")]

func _ready():
	self.rotation = vetor_direcao.angle()

func _physics_process(delta): global_translate( vetor_direcao.normalized() * velocidade_maxima * delta)

func _on_allied_shot_body_entered(body):
	if not body.is_in_group('Inimigo'):
		if body.is_in_group('Jogador'):
			body.causar_dano(dano)
			self.queue_free()
		else:
			self.queue_free()

func _on_tmr_free_timeout(): self.queue_free()


func _on_tmr_changetexture_timeout(): $sprite.texture = textures[0] if $sprite.texture != textures[0] else textures[1]