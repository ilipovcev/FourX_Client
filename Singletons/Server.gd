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
	get_tree().change_scene("res://WaitingScreen.tscn");
	print("Player registring...");


func _On_connection_failed():
	print("Connection failed");


func GetPlayerById(PlId):
	for i in players:
		pls_map[i.GetId()] = players.find(i);
		print("id: ", i.GetId(), ". index: ", players.find(i));
	return players[pls_map[PlId]];

remote func OnRegPlayer(name, id, hp, origin: Vector2):
	print("Registred with name ", name, " id: ", id, " (", hp, " HP). Position: ",origin.x, " ", origin.y);

remote func StartGame(players_state):
	var pl: Player
	for i in players_state:
		pl = Player.new();
		pl.SetName(i[0]);
		pl.SetId(i[1]);
		pl.SetHealth(i[3]);
		GameMap.SetPlayer(i[4], pl);
		pl = GameMap.GetPlayer(i[4]);
		pl.SetOrigin(i[2]);
		players.append(pl);
		pls_map[pl.GetId()] = players.size()-1;
	get_tree().change_scene("res://Game.tscn");


remote func OnMapLoaded(map: String):
	if !GameMap.LoadFromJsonStr(map):
		print('Cant load the map');
		return;


remote func is_turn(isTurn):
	turn = isTurn;


remote func on_roll():
	Roll();	

func Roll():
	if turn == true:
		turn = false;
		rpc_id(1, "IsRoll");


remote func OnRoll(new_origin: Vector2, steps_number: int, index_player: int):
	print("On Roll");
	GameMap.MovePlayer(index_player, steps_number);
	if !GameMap.GetPlayer(index_player).GetOrigin() == new_origin:
		GameMap.GetPlayer(index_player).SetOrigin(new_origin);
	print("Move to  Position: ",
		GameMap.GetPlayer(index_player).GetOrigin().x,
		" ", GameMap.GetPlayer(index_player).GetOrigin().y);

	
remote func get_states(players_state: Array):
	print("States: ", players_state);
	var pl: Player;
	for i in players_state:
		print(i[1]);
		print(i[2]);
		print(i[3]);
		print(i[4]);
		pl = GetPlayerById(i[1]);
		pl.SetOrigin(i[2]);
		pl.SetHealth(i[3]);
		print(pl.GetOrigin());


remote func on_dead():
	print("Dead..");
	get_tree().change_scene("res://StartMenu/Menu.tscn");
	get_tree().set_network_peer(null);


remote func on_player_dead(id: int):
	var pl: Player = GetPlayerById(id);
	print("Player ", pl.GetName(), " is dead");
	pls_map.erase(pl.GetId());
	GameMap.RemovePlayer(players.find(pl));
	players.erase(pl);
	for i in players:
		pls_map[i.GetId()] = players.find(i);
		print("id: ", i.GetId(), ". index: ", players.find(i));


remote func on_win():
	print("Win..");


remote func on_player_win(id: int):
	var pl: Player = GetPlayerById(id);
	print("Player ", pl.GetName(), " is winner!");
	print("Stop game");


remote func stop_game():
	print("Stop game");
	turn = false;
	get_tree().change_scene("res://StartMenu/Menu.tscn");
	get_tree().set_network_peer(null);