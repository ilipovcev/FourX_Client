extends Node
const port = 1909;
var GameMap: Map = Map.new();
var name_player;
var players: Array
var pls_map = {};
var turn: bool = false;


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


func GetPlayerById(PlId):
	return players[pls_map[PlId]];


remote func OnRegPlayer(name, id, hp, origin: Vector2, index):
	var pl: Player = Player.new();
	GameMap.SetPlayer(index, pl);
	pl.SetName(name);
	pl.SetId(id);
	pl.SetHealth(hp);
	pl.SetOrigin(origin);
	print("Registred with name ", pl.GetName(), " (", pl.GetHealth(), " HP). Position: ", pl.GetOrigin().x, " ", pl.GetOrigin().y);
	players.append(pl);
	pls_map[pl.GetId()] = players.size()-1;

	Roll();
	Roll();
	Roll();


remote func OnMapLoaded(map: String):
	if !GameMap.LoadFromJsonStr(map):
		print('Cant load the map');
		return;
	get_tree().change_scene("res://Game.tscn");


remote func is_turn(isTurn):
	turn = isTurn;


func Roll():
	if turn:
		rpc_id(1, "IsRoll");
		turn = false;


remote func OnRoll(new_origin: Vector2, steps_number: int, index_player: int):
	print("On Roll");
	GameMap.MovePlayer(index_player, steps_number);
	if !GameMap.GetPlayer(index_player).GetOrigin() == new_origin:
		GameMap.GetPlayer(index_player).SetOrigin(new_origin);
	print("Move to  Position: ",
		GameMap.GetPlayer(index_player).GetOrigin().x,
		" ", GameMap.GetPlayer(index_player).GetOrigin().y);

	
remote func get_states(players_state: Array):
	print(players_state);
	var pl: Player;
	for i in players_state:
		pl = GetPlayerById(i[1]);
		pl.SetOrigin(i[2]);
		pl.SetHealth(i[3]);
		print(i[1]);
		print(i[2]);
		print(i[3]);