extends Node
const port = 1909;
var ip = "127.0.0.1"
var pl: Player = Player.new();
var GameMap: Map = Map.new();


func ConnectServer():
	var network = NetworkedMultiplayerENet.new();
	network.create_client(ip, port);
	get_tree().set_network_peer(null);
	get_tree().set_network_peer(network);

	network.connect("connection_succeeded", self, "_On_connection_succeeded");
	network.connect("connection_failed", self, "_On_connection_failed");


func _On_connection_succeeded():
	pl.SetName("ilipa");
	print("Connection succeded");
	rpc_id(1, "RegPlayer", pl.GetName());
	print("Player registring...");


func _On_connection_failed():
	print("Connection failed");


remote func OnRegPlayer(name, id, hp, origin: Vector2):
	pl.SetName(name);
	pl.SetId(id);
	pl.SetHealth(hp);
	pl.SetOrigin(origin);
	print("Registred with name ", pl.GetName(), " (", pl.GetHealth(), " HP). Position:", pl.GetOrigin().x, " ", pl.GetOrigin().y);

	


remote func OnMapLoaded(map: String):
	if !GameMap.LoadFromJsonStr(map):
		print('Cant load the map');


func Roll():
	rpc_id(1, "IsRoll");