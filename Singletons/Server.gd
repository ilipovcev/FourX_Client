extends Node
const port = 1909;
var GameMap: Map = Map.new();
var name_player;


func ConnectServer(ip, name):
	name_player = name;
	var network = NetworkedMultiplayerENet.new();
	network.create_client(ip, port);
	get_tree().set_network_peer(null);
	get_tree().set_network_peer(network);

	network.connect("connection_succeeded", self, "_On_connection_succeeded");
	network.connect("connection_failed", self, "_On_connection_failed");


func _On_connection_succeeded():
	print("Connection succeded");
	rpc_id(1, "RegPlayer", name_player);
	print("Player registring...");


func _On_connection_failed():
	print("Connection failed");


remote func OnRegPlayer(name, id, hp, origin: Vector2, index):
	var pl: Player = Player.new();
	GameMap.SetPlayer(index, pl);

	pl.SetName(name);
	pl.SetId(id);
	pl.SetHealth(hp);
	pl.SetOrigin(origin);
	print("Registred with name ", pl.GetName(), " (", pl.GetHealth(), " HP). Position: ", pl.GetOrigin().x, " ", pl.GetOrigin().y);
	Roll();
	Roll();
	Roll();


remote func OnMapLoaded(map: String):
	if !GameMap.LoadFromJsonStr(map):
		print('Cant load the map');
		return;
	get_tree().change_scene("res://Game.tscn");


func Roll():
	rpc_id(1, "IsRoll");


remote func OnRoll(new_origin: Vector2, steps_number: int, index_player: int):
	GameMap.MovePlayer(index_player, steps_number);
	if !GameMap.GetPlayer(index_player).GetOrigin() == new_origin:
		GameMap.GetPlayer(index_player).SetOrigin(new_origin);
	print("Move to  Position: ",
		GameMap.GetPlayer(index_player).GetOrigin().x,
		" ", GameMap.GetPlayer(index_player).GetOrigin().y);