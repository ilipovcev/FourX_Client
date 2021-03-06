class_name Map

var CELL_TYPES: Dictionary = {
	"Cell": Cell,
	"CellDamage": CellDamage,
	"CellHealth": CellHealth,
	"CellWin": CellWin,
};

var Matrix = [];
var Size: Vector2;
var jMap;
var Roads: Array;
var Players: Array;

func LoadFromJson(map):
	Size = Vector2(map['Size'][0], map['Size'][1]);
	
	if map['Cells'].size() != Size.x:
		print("АШИПКА. Кривой размер карты.");
		return false;
	
	Matrix.resize(Size.x);
	for i in range(Size.x):
		if map['Cells'][i].size() != Size.y:
			print("АШИПКА. Кривой размер карты.");
			return false;
		
		var row: Array = [];
		row.resize(Size.y);
		
		for j in range(Size.y):
			var s: String;
			if typeof(map['Cells'][i][j]) == TYPE_ARRAY:
				randomize();
				s = map['Cells'][i][j][randi() % map['Cells'][i][j].size()];
			else:
				s = map['Cells'][i][j];
				if !(s in CELL_TYPES):
					s = "Cell";
					
			map['Cells'][i][j] = s;
			row[j] = CELL_TYPES[s].new();
			row[j].SetCoords(i, j);
		
		Matrix[i] = row;
		
	var RoadsCount = map['Roads'].size();
	Roads.resize(RoadsCount);
	Players.resize(RoadsCount); # Сколько путей, столько и игроков
	for i in range(RoadsCount):
		var road: Road = Road.new();
		for j in range(map['Roads'][i].size()):
			road.AddStep(GetCellByVec(UTIL_ArrToVec(map['Roads'][i][j])));
		Roads[i] = road;
	
	jMap = map;
	Init();
	
	return true;

func LoadFromJsonStr(map: String):
	return LoadFromJson(JSON.parse(map).result);

func LoadFromFile(filename: String):
	print("Чтение карты из файла ", filename);
	var file = File.new();
	file.open("res://"+filename, File.READ);
	var res: bool = LoadFromJsonStr(file.get_as_text());
	file.close();
	return res;

func Init():
	print("Карта размером ", Size.x, " на ", Size.y, " загружена.");
	print("Инициализация мира...");


func GetSize():
	return Size;

func GetCell(i, j: int):
	return Matrix[i][j];

func GetCellByVec(vec: Vector2):
	return Matrix[vec.x][vec.y];


func GetRoad(index: int):
	return Roads[index];

func MovePlayer(index: int, rng: int):
	return GetRoad(index).Move(GetPlayer(index), rng);

func GetPlayer(index: int):
	return Players[index];

func SetPlayer(index: int, pl: Player):
	Players[index] = pl;
	pl.SetOrigin(GetRoad(index).GetStep(index).GetCoords());

func ResetPlayer():
	Players.clear();
	Players.resize(Roads.size());

func RemovePlayer(index: int):
	Players.remove(index);


func to_string():
	return JSON.print(jMap);

func UTIL_ArrToVec(a: Array):
	return Vector2(a[0], a[1]);
