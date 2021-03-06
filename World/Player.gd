class_name Player

var Health: int = 6;
var Nick: String = "Unnamed";
var Id: int;
var Origin: Vector2;

func OnTakeDamage(dmg: int):
	Health -= dmg;
	print("Игрок ", Nick, " получил ", dmg, " урона. (", Health, "HP)");
	if Health <= 0:
		OnDeath();

func OnTakeHealth(hp: int):
	Health += hp;
	print("Игрок ", Nick, " получил ", hp, " здоровья. (", Health, "HP)" );

func OnWin():
	print("Игрок ", Nick, " выиграл.")
	
func OnDeath():
	print("Игрок ", Nick, " умер.");

func SetName(name: String):
	Nick = name;

func GetName():
	return Nick;

func SetHealth(hp):
	Health = hp;

func GetHealth():
	return Health;
	
func SetOrigin(vec: Vector2):
	Origin = vec;
	print("Игрок ", Nick, " передвинут на координаты ", vec);
	
func GetOrigin():
	return Origin;

func SetId(id):
	Id = id;

func GetId():
	return Id;