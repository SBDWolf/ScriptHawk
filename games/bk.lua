local Game = {};

--------------------
-- Region/Version --
--------------------

-- Only patch US 1.0
-- TODO - Figure out how to patch other versions
local allowFurnaceFunPatch = false;

local slope_timer;
local moves_bitfield;

local x_vel;
local y_vel;
local z_vel;

local x_pos;
local y_pos;
local z_pos;

local x_rot;
local facing_angle;
local moving_angle;
local z_rot;

local camera_rot; -- TODO: JP/PAL

local map;
local frame_timer;
local object_array_pointer;

local notes;

-- Relative to notes
-- TODO: Redo with correct datatypes
-- TODO: Add jinjos
local eggs = 4;
local red_feathers = 12;
local gold_feathers = 16;
local health = 32;
local health_containers = 36;
local lives = 40;
local air = 43;
local air_timer = 44;
local mumbo_tokens_on_hand = 61;
local mumbo_tokens = 97;
local jiggies = 104;

local max_notes = 100;
local max_eggs = 200;
local max_red_feathers = 50;
local max_gold_feathers = 10;
local max_health = 16;
local max_health_containers = 16;
local max_lives = 9;
local max_air = 0x0E;
local max_air_timer = 0x10;
local max_mumbo_tokens = 99;
local max_jiggies = 100;

local eep_checksum_offsets = {
	0x74,
	0xEC,
	0x164,
	0x1DC,
	0x1FC
};

local eep_checksum_values = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000
}

Game.maps = {
	"SM - Spiral Mountain",
	"MM - Mumbo's Mountain",
	"Unknown 0x03",
	"Unknown 0x04",
	"TTC - Blubber's Ship",
	"TTC - Nipper's Shell",
	"TTC - Treasure Trove Cove",
	"Unknown 0x08",
	"Unknown 0x09",
	"TTC - Sandcastle",
	"CC - Clanker's Cavern",
	"MM - Termite Mound",
	"BGS - Bubblegloop Swamp",
	"Mumbo's Skull (MM)",
	"Unknown 0x0F",
	"BGS - Mr. Vile",
	"BGS - Tiptup",
	"GV - Gobi's Valley",
	"GV - Matching Game",
	"GV - Maze",
	"GV - Water",
	"GV - Snake",
	"Unknown 0x17",
	"Unknown 0x18",
	"Unknown 0x19",
	"GV - Sphinx",
	"MMM - Mad Monster Mansion",
	"MMM - Church",
	"MMM - Cellar",
	"Intro - Start - Nintendo",
	"Intro - Start - Rareware",
	"Intro - End Scene 2: Not 100",
	"CC - Inside A",
	"CC - Inside B",
	"CC - Gold Feather Room",
	"MMM - Tumblar's Shed",
	"MMM - Well",
	"MMM - Dining Room",
	"FP - Freezeezy Peak",
	"MMM - Room 1",
	"MMM - Room 2",
	"MMM - Room 3: Fireplace",
	"MMM - Church",
	"MMM - Room 4: Bathroom",
	"MMM - Room 5: Bedroom",
	"MMM - Room 6: Floorboards",
	"MMM - Barrel",
	"Mumbo's Skull (MMM)",
	"RBB - Rusty Bucket Bay",
	"Unknown 0x32",
	"Unknown 0x33",
	"RBB - Engine Room",
	"RBB - Warehouse 1",
	"RBB - Warehouse 2",
	"RBB - Container 1",
	"RBB - Container 3",
	"RBB - Crew Cabin",
	"RBB - Boss Boom Box",
	"RBB - Store Room",
	"RBB - Kitchen",
	"RBB - Navigation Room",
	"RBB - Container 2",
	"RBB - Captain's Cabin",
	"CCW - Start",
	"FP - Boggy's Igloo",
	"Unknown 0x42",
	"CCW - Spring",
	"CCW - Summer",
	"CCW - Autumn",
	"CCW - Winter",
	"Mumbo's Skull (BGS)",
	"Mumbo's Skull (FP)",
	"Unknown 0x49",
	"Mumbo's Skull (CCW Spring)",
	"Mumbo's Skull (CCW Summer)",
	"Mumbo's Skull (CCW Autumn)",
	"Mumbo's Skull (CCW Winter)",
	"Unknown 0x4E",
	"Unknown 0x4F",
	"Unknown 0x50",
	"Unknown 0x51",
	"Unknown 0x52",
	"FP - Inside Xmas Tree",
	"Unknown 0x54",
	"Unknown 0x55",
	"Unknown 0x56",
	"Unknown 0x57",
	"Unknown 0x58",
	"Unknown 0x59",
	"CCW - Zubba's Hive (Summer)",
	"CCW - Zubba's Hive (Spring)",
	"CCW - Zubba's Hive (Autumn)",
	"Unknown 0x5D",
	"CCW - Nabnut's House (Spring)",
	"CCW - Nabnut's House (Summer)",
	"CCW - Nabnut's House (Autumn)",
	"CCW - Nabnut's House (Winter)",
	"CCW - Nabnut's Room 1 (Winter)",
	"CCW - Nabnut's Room 2 (Autumn)",
	"CCW - Nabnut's Room 2 (Winter)",
	"CCW - Top (Spring)",
	"CCW - Top (Summer)",
	"CCW - Top (Autumn)",
	"CCW - Top (Winter)",
	"Lair - Flr 1, Area 1: Mumbo",
	"Lair - Flr 1, Area 2",
	"Lair - Flr 1, Area 3",
	"Lair - Flr 1, Area 3a: Cauldron",
	"Lair - Flr 1, Area 4: TTC Lobby",
	"Lair - Flr 2, Area 1: GV Lobby",
	"Lair - Flr 2, Area 2: MMM/FP",
	"Lair - Flr 1, Area 5: Pipes room",
	"Lair - Flr 1, Area 6: Lair statue",
	"Lair - Flr 1, Area 7: BGS Lobby",
	"Unknown 0x73",
	"Lair - Flr 2, Area 4: GV Puzzle",
	"Lair - Flr 2, Area 5: MMM Lobby",
	"Lair - Flr 3, Area 1",
	"Lair - Flr 3, Area 2: RBB Lobby",
	"Lair - Flr 3, Area 3",
	"Lair - Flr 3, Area 4: CCW trunks",
	"Lair - Flr 2, Area 5a: Crypt inside",
	"Intro - Grunties Lair 1 - Scene 1",
	"Intro - Inside Banjo's Cave 1 - Scenes 3,7",
	"Intro - Spiral 'A' - Scenes 2,4",
	"Intro - Spiral 'B' - Scenes 5,6",
	"FP - Wozza's Cave",
	"Lair - Flr 3, Area 4a",
	"Intro - Grunties Lair 2",
	"Intro - Grunties Lair 3 - Machine 1",
	"Intro - Grunties Lair 4 - Game Over",
	"Intro - Grunties Lair 5",
	"Intro - Spiral 'C'",
	"Intro - Spiral 'D'",
	"Intro - Spiral 'E'",
	"Intro - Spiral 'F'",
	"Intro - Inside Banjo's Cave 2",
	"Intro - Inside Banjo's Cave 3",
	"RBB - Anchor room",
	"SM - Banjo's House",
	"MMM - Inside Loggo",
	"Lair - Furnace Fun",
	"TTC - Sharkfood Island",
	"Lair - Battlements",
	"File Select Screen",
	"GV - Secret Chamber",
	"Lair - Flr 5, Area 1: Grunty's rooms",
	"Intro - Spiral 'G'",
	"Intro - End Scene 3: All 100",
	"Intro - End Scene",
	"Intro - End Scene 4",
	"Intro - Grunty Threat 1",
	"Intro - Grunty Threat 2"
}

function Game.detectVersion(romName)
	if bizstring.contains(romName, "Europe") then
		frame_timer = 0x280700;
		slope_timer = 0x37CCB4;
		moves_bitfield = 0x37CD70;
		x_vel = 0x37CE88;
		x_pos = 0x37CF70;
		x_rot = 0x37CF10;
		moving_angle = 0x37D064;
		camera_rot = 0x37D96C; -- TODO
		z_rot = 0x37D050;
		map = 0x37F2C5;
		notes = 0x386943;
		object_array_pointer = 0x36EAE0;
	elseif bizstring.contains(romName, "Japan") then
		frame_timer = 0x27F718;
		slope_timer = 0x37CDE4;
		moves_bitfield = 0x37CEA0;
		x_vel = 0x37CFB8;
		x_pos = 0x37D0A0;
		x_rot = 0x37D040;
		moving_angle = 0x37D194;
		camera_rot = 0x37D96C; -- TODO
		z_rot = 0x37D180;
		map = 0x37F405;
		notes = 0x386AA3;
		object_array_pointer = 0x36F260;
	elseif bizstring.contains(romName, "USA") and bizstring.contains(romName, "Rev A") then
		frame_timer = 0x27F718;
		slope_timer = 0x37B4E4;
		moves_bitfield = 0x37B5A0;
		x_vel = 0x37B6B8;
		x_pos = 0x37B7A0;
		x_rot = 0x37B740;
		moving_angle = 0x37B894;
		camera_rot = 0x37CDA8;
		z_rot = 0x37B880;
		map = 0x37DAF5;
		notes = 0x385183;
		object_array_pointer = 0x36D760;
	elseif bizstring.contains(romName, "USA") then
		frame_timer = 0x2808D8;
		allowFurnaceFunPatch = true;
		slope_timer = 0x37C2E4;
		moves_bitfield = 0x37C3A0;
		x_vel = 0x37C4B8;
		x_pos = 0x37C5A0;
		x_rot = 0x37C540;
		moving_angle = 0x37C694;
		camera_rot = 0x37D96C;
		z_rot = 0x37C680;
		map = 0x37E8F5;
		notes = 0x385F63;
		object_array_pointer = 0x36E560;
	else
		return false;
	end

	y_pos = x_pos + 4;
	z_pos = y_pos + 4;

	y_vel = x_vel + 4;
	z_vel = y_vel + 4;

	facing_angle = moving_angle - 4;

	-- Read EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local i;
		for i=1,#eep_checksum_offsets do
			eep_checksum_values[i] = memory.read_u32_be(eep_checksum_offsets[i]);
		end
	end
	memory.usememorydomain("RDRAM");

	return true;
end

local options_toggle_neverslip;

local function neverSlip()
	mainmemory.writefloat(slope_timer, 0.0, true);
end

-----------------
-- Moves stuff --
-----------------

local options_moves_dropdown;
local options_moves_button;

local move_levels = {
	["0. None"]                 = 0x00000000,
	["1. Spiral Mountain 100%"] = 0x00009DB9,
	["2. FFM Setup"]            = 0x007FFDBF,
	["3. All"]                  = 0x007FFFFF,
	["3. Demo"]                 = 0xFFFFFFFF
};

local function unlock_moves()
	local level = forms.gettext(options_moves_dropdown);
	mainmemory.write_u32_be(moves_bitfield, move_levels[level]);
end

--------------------
-- Movement state --
--------------------

-- Current Movement state  0x37D167 (US 1.0)
-- Previous Movement state 0x37D163 (US 1.0)

local movementStates = {
	[0x01] = "Idle",
	[0x02] = "Slow walking",
	[0x03] = "Walking",
	[0x04] = "Fast walking",

	[0x05] = "Jumping",
	[0x06] = "Bear punch",
	[0x07] = "Crouching",
	[0x08] = "Jumping (Talon Trot)",
	[0x0C] = "Skidding",
	[0x0E] = "Taking damage",
	[0x0F] = "Beak Buster",
	[0x10] = "Feathery Flap",
	[0x11] = "Rat-a-tat rap",
	[0x12] = "Backflip (Flap Flip)",
	[0x13] = "Beak Barge",

	[0x14] = "Entering Talon Trot",
	[0x15] = "Talon Trot Idle",
	[0x16] = "Talon Trot Moving",
	[0x17] = "Leaving Talon Trot",

	[0x1A] = "Entering Wonderwing",
	[0x1B] = "Idle (Wonderwing)",
	[0x1C] = "Moving (Wonderwing)",
	[0x1D] = "Jumping (Wonderwing)",
	[0x1E] = "Leaving Wonderwing",

	[0x1F] = "Creeping",
	[0x20] = "Landing (after jump)",

	[0x25] = "Entering Wading Boots",
	[0x26] = "Idle (Wading Boots)",
	[0x27] = "Moving (Wading Boots)",
	[0x28] = "Jumping (Wading Boots)",
	[0x29] = "Leaving Wading Boots",

	[0x2F] = "Landing (with peck?)",

	[0x31] = "Rolling",

	[0x32] = "Slipping down slope",
	[0x45] = "Slipping down slope (Talon Trot)",
	[0x55] = "Slipping down slope (Wading Boots)",

	[0x5A] = "Loading zone?",

	[0x5E] = "Idle (Croc)",
	[0x5F] = "Moving (Croc)",
	[0x60] = "Jumping (Croc)",
	[0x6E] = "Biting (Croc)",

	[0x73] = "Locked - Cutscene?",
	[0x74] = "Locked - Jiggy pad, Mumbo transformation, bottles",
	[0x8D] = "Locked - Mumbo transformation",
	[0x94] = "Locked - Mumbo transformation",
	[0x98] = "Locked - Loading zone, Mumbo transformation",
};

--------------------------
-- Sandcastle positions --
--------------------------

local sandcastlePositions = {
	["A"] = {180, -700},
	["B"] = {0, 540},
	["C"] = {360, -540},
	["D"] = {-360, -180},
	["E"] = {0, -540},
	["F"] = {360, 180},
	["G"] = {-180, -700},
	["H"] = {-360, 540},
	["I"] = {540, 0},
	["J"] = {-540, -700},
	["K"] = {360, 540},
	["L"] = {540, -700},
	["M"] = {-540, -360},
	["N"] = {-180, -360},
	["O"] = {0, -180},
	["P"] = {540, -360},
	-- There's no Q in the sandcastle
	["R"] = {180, -360},
	["S"] = {360, -180},
	["T"] = {0, 180},
	["U"] = {-180, 0},
	["V"] = {-360, -540},
	["W"] = {180, 360},
	["X"] = {-360, 180},
	["Y"] = {180, 0},
	["Z"] = {-540, 0},
};

function gotoSandcastleLetter(letter)
	if type(sandcastlePositions[letter]) == "table" then
		Game.setXPosition(sandcastlePositions[letter][1]);
		Game.setZPosition(sandcastlePositions[letter][2]);
	else
		print("Letter not found.");
	end
end

-------------------------------
-- Sandcastle string decoder --
-------------------------------

local sandcastleStringConversionTable = {
	[0x00] = " ",
	[0x30] = "C",
	[0x31] = "M",
	[0x32] = "S",
	[0x33] = "Z",
	[0x34] = "I",
	[0x35] = "G",
	[0x36] = "O",
	[0x37] = "W",
	[0x38] = "K",
	[0x39] = "R",
	[0x61] = "V",
	[0x62] = "L",
	[0x63] = "F",
	[0x64] = "T",
	[0x65] = "Y",
	[0x67] = "U",
	[0x68] = "X",
	[0x69] = "N",
	[0x6A] = "E",
	[0x6B] = "B",
	[0x6C] = "D",
	[0x6D] = "H",
	[0x6E] = "A",
	[0x70] = "J",
	[0x72] = "P",
};

function decodeSandcastleString(base, length, nullTerminate)
	nullTerminate = nullTerminate or false;
	local i;
	local builtString = "";
	for i = base, base + length do
		local byte = mainmemory.readbyte(i);

		if byte == 0 and nullTerminate then
			break;
		end

		if type(sandcastleStringConversionTable[byte]) ~= "nil" then
			builtString = builtString..sandcastleStringConversionTable[byte];
		else
			builtString = builtString.."?".."("..bizstring.hex(byte).." = "..string.char(byte)..")";
		end
	end
	print(builtString);
end

-----------------------
-- Furnace fun stuff --
-----------------------

local options_allow_ff_patch;

local function applyFurnaceFunPatch()
	if allowFurnaceFunPatch and forms.ischecked(options_allow_ff_patch) then
		mainmemory.write_u16_be(0x320064, 0x080a);
		mainmemory.write_u16_be(0x320066, 0x1840);

		mainmemory.write_u16_be(0x286100, 0xac86);
		mainmemory.write_u16_be(0x286102, 0x2dc8);
		mainmemory.write_u16_be(0x286104, 0x0c0c);
		mainmemory.write_u16_be(0x286106, 0x8072);

		mainmemory.write_u16_be(0x28610C, 0x080c);
		mainmemory.write_u16_be(0x28610E, 0x801b);
	end
end

----------------------
-- Vile state stuff --
----------------------

-- Wave UI
local options_wave_button;
local options_heart_button;
local options_fire_all_button;

local game_type = 0x90;

local previous_game_type = 0x91
local player_score = 0x92;
local vile_score = 0x93;

local minigame_timer = 0x94;

local number_of_slots = 25;
-- TODO: Figure out object type for vile slots
local first_slot_base = 0x28;
local slot_base = 0x318;
local slot_size = 0x180;

-- Relative to slot base + (slot number * slot size)

-- 00000 0x00 disabled
-- 00100 0x04 idle
-- 01000 0x08 rising
-- 01100 0x0c alive
-- 10000 0x10 falling (no eat)
-- 10100 0x14 eaten
local slot_state = 0x00;

-- Float 0-1
local popped_amount = 0x6c;

-- 0x00 = yum, > 0x00 = grum
local slot_type = 0x70;

-- Float 0-15?
local slot_timer = 0x74;

local function getSlotBase(index)
	if index < 12 then
		return slot_base + (index - 1) * slot_size;
	end
	return slot_base + index * slot_size;
end

local function fireSlot(vile_state, index, slotType)
	current_slot_base = getSlotBase(index);
	mainmemory.writebyte(vile_state + current_slot_base + slot_state, 0x08);
	mainmemory.writebyte(vile_state + current_slot_base + slot_type, slotType);
	mainmemory.writefloat(vile_state + current_slot_base + popped_amount, 1.0, true);
	mainmemory.writefloat(vile_state + current_slot_base + slot_timer, 0.0, true);
end

local vileMap = {
	{ 22, 24, 16 },
	{ 21, 23, 14, 15 },
	{ 20, 19, 17, 13, 12 },
	{ 9,  18, 11, 4 },
	{ 10, 7,  8,  2,  1  },
	{ 6,  5,  3,  0 }
};

local heart = {
	{2, 2}, {2, 3},
	{3, 2}, {3, 3}, {3, 4},
	{4, 2}, {4, 3},
	{5, 3}
};

local waveFrames = {
	{ {3, 1}, {5, 1} },
	{ {2, 1}, {4, 1}, {6, 1} },
	{ {1, 1}, {3, 2}, {5, 2} },
	{ {2, 2}, {4, 2}, {6, 2} },
	{ {1, 2}, {3, 3}, {5, 3} },
	{ {2, 3}, {4, 3}, {6, 3} },
	{ {1, 3}, {3, 4}, {5, 4} },
	{ {2, 4}, {4, 4}, {6, 4} },
	{ {3, 5}, {5, 5} }
}

function getSlotIndex(row, col)
	row = math.max(row, 1);
	if row <= #vileMap then
		col = math.max(col, 1);
		col = math.min(col, #vileMap[row]);
		return vileMap[row][col] + 1;
	end
	return 1;
end

local waving = false;
local wave_counter = 0;
local wave_delay = 10;
local wave_frame = 1;
local wave_colour = 0;

local function initWave()
	waving = true;
	wave_frame = 1;
	wave_counter = 0;
	wave_colour = math.random(0, 1);
end

local function updateWave()
	if waving then
		wave_counter = wave_counter + 1;
		if wave_counter == wave_delay then
			local i;
			local vile_state = mainmemory.read_u24_be(object_array_pointer + 1);
			for i=1,#waveFrames[wave_frame] do
				fireSlot(vile_state, getSlotIndex(waveFrames[wave_frame][i][1], waveFrames[wave_frame][i][2]), wave_colour);
			end
			wave_counter = 0;
			wave_frame = wave_frame + 1;
		end
		if wave_frame > #waveFrames then
			waving = false;
		end
	end
end

local function doHeart()
	local vile_state = mainmemory.read_u24_be(object_array_pointer + 1);
	local i;

	for i=1,#heart do
		fireSlot(vile_state, getSlotIndex(heart[i][1], heart[i][2]), 0);
	end
end

local function fireAllSlots()
	local vile_state = mainmemory.read_u24_be(object_array_pointer + 1);
	local i;

	local colour = math.random(0, 1);
	for i=1,number_of_slots do
		fireSlot(vile_state, i, colour);
	end
end

------------------------
-- Roll Flutter stuff --
------------------------

RF_absolute_target_angle = 180;

local RF_max_analog = 127;

function set_angle(num)
	RF_absolute_target_angle = num;
end

local function RF_step()
	local current_camera_rot = mainmemory.readfloat(camera_rot, true) % 360;
	local analog_angle = rotation_to_radians(math.abs(RF_absolute_target_angle - current_camera_rot) % 360);
	local analog_x = math.sin(analog_angle) * RF_max_analog;
	local analog_y = -1 * math.cos(analog_angle) * RF_max_analog;
	--print("camera rot: "..current_camera_rot);
	--print("analog angle: "..analog_angle);
	--print("raw sincos: "..math.sin(analog_angle)..","..math.cos(analog_angle));
	--print("analog inputs: "..analog_x..","..analog_y);
	joypad.setanalog({['X Axis'] = analog_x, ['Y Axis'] = analog_y}, 1);
end

-------------------------------
--              Conga.lua    --
-- written by Isotarge, 2015 -- 
-------------------------------

local conga_slot_size = 0x80;
local throw_slot = 0x77;
local orange_timer = 0x1C;

local orange_timer_value = 0.5;

function set_orange_timer()
	joypad_pressed = input.get();
	if joypad_pressed["C"] then
		local level_object_array_base = mainmemory.read_u24_be(object_array_pointer + 1);
		mainmemory.writefloat(level_object_array_base + throw_slot * conga_slot_size + orange_timer, orange_timer_value, true);
		--print(toHexString(level_object_array_base + throw_slot * conga_slot_size + orange_timer));
	end
end

--------------
-- Encircle --
--------------

local encircle_checkbox;
local dynamic_radius_checkbox;
local dynamic_radius_factor = 15;

-- Relative to level_object_array
local max_slots = 0x100;
local radius = 1000;

-- Relative to slot
local slot_x_pos = 0x164;
local slot_y_pos = 0x168;
local slot_z_pos = 0x16C;

local function get_num_slots()
	local level_object_array_state = mainmemory.read_u24_be(object_array_pointer + 1);
	return math.min(max_slots, mainmemory.read_u32_be(level_object_array_state));
end

local function get_slot_base(index)
	local level_object_array_state = mainmemory.read_u24_be(object_array_pointer + 1);
	return level_object_array_state + first_slot_base + index * slot_size;
end

local function encircle_banjo()
	local i, x, z;

	local current_banjo_x = Game.getXPosition();
	local current_banjo_y = Game.getYPosition();
	local current_banjo_z = Game.getZPosition();
	local currentPointers = {};

	num_slots = get_num_slots();

	if forms.ischecked(dynamic_radius_checkbox) then
		radius = num_slots * dynamic_radius_factor;
	else
		radius = 1000;
	end

	-- Fill and sort pointer list
	for i=0,num_slots - 1 do
		table.insert(currentPointers, get_slot_base(i));
	end
	table.sort(currentPointers);

	-- Iterate and set position
	for i=1,#currentPointers do
		x = current_banjo_x + math.cos(math.pi * 2 * i / #currentPointers) * radius;
		z = current_banjo_z + math.sin(math.pi * 2 * i / #currentPointers) * radius;

		mainmemory.writefloat(currentPointers[i] + slot_x_pos, x, true);
		mainmemory.writefloat(currentPointers[i] + slot_y_pos, current_banjo_y, true);
		mainmemory.writefloat(currentPointers[i] + slot_z_pos, z, true);
	end
end

-------------------
-- Physics/Scale --
-------------------

Game.speedy_speeds = { .1, 1, 5, 10, 20, 35, 50, 75, 100 };
Game.speedy_index = 6;

Game.rot_speed = 5;
Game.max_rot_units = 360;

function Game.isPhysicsFrame()
	local frameTimerValue = mainmemory.read_s32_be(frame_timer);
	return frameTimerValue <= 0 and not emu.islagged();
end

--------------
-- Position --
--------------

function Game.getXPosition()
	return mainmemory.readfloat(x_pos, true);
end

function Game.getYPosition()
	return mainmemory.readfloat(y_pos, true);
end

function Game.getZPosition()
	return mainmemory.readfloat(z_pos, true);
end

function Game.setXPosition(value)
	mainmemory.writefloat(x_pos, value, true);
	mainmemory.writefloat(x_pos + 0x10, value, true);
end

function Game.setYPosition(value)
	mainmemory.writefloat(y_pos, value, true);
	mainmemory.writefloat(y_pos + 0x10, value, true);

	-- Nullify gravity when setting Y position
	Game.setYVelocity(0);
end

function Game.setZPosition(value)
	mainmemory.writefloat(z_pos, value, true);
	mainmemory.writefloat(z_pos + 0x10, value, true);
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	return mainmemory.readfloat(x_rot, true);
end

function Game.getYRotation()
	return mainmemory.readfloat(moving_angle, true);
end

function Game.getZRotation()
	return mainmemory.readfloat(z_rot, true);
end

function Game.setXRotation(value)
	mainmemory.writefloat(x_rot, value, true);

	-- Also set the target
	mainmemory.writefloat(x_rot + 4, value, true);
end

function Game.setYRotation(value)
	mainmemory.writefloat(moving_angle, value, true);
	mainmemory.writefloat(facing_angle, value, true);
end

function Game.setZRotation(value)
	mainmemory.writefloat(z_rot, value, true);

	-- Also set the target
	mainmemory.writefloat(z_rot + 4, value, true);
end

--------------
-- Velocity --
--------------

function Game.getXVelocity()
	return mainmemory.readfloat(x_vel, true);
end

function Game.getYVelocity()
	return mainmemory.readfloat(y_vel, true);
end

function Game.getZVelocity()
	return mainmemory.readfloat(z_vel, true);
end

function Game.setXVelocity(value)
	return mainmemory.writefloat(x_vel, value, true);
end

function Game.setYVelocity(value)
	return mainmemory.writefloat(y_vel, value, true);
end

function Game.setZVelocity(value)
	return mainmemory.writefloat(z_vel, value, true);
end

------------
-- Events --
------------

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		mainmemory.writebyte(map, value);
	end
end

function Game.applyInfinites()
	mainmemory.writebyte(notes, max_notes);
	mainmemory.writebyte(notes + eggs, max_eggs);
	mainmemory.writebyte(notes + red_feathers, max_red_feathers);
	mainmemory.writebyte(notes + gold_feathers, max_gold_feathers);
	mainmemory.writebyte(notes + health, max_health);
	mainmemory.writebyte(notes + health_containers, max_health_containers);
	mainmemory.writebyte(notes + lives, max_lives);
	mainmemory.writebyte(notes + air, max_air);
	mainmemory.writebyte(notes + air_timer, max_air_timer);
	mainmemory.write_u32_be(notes + mumbo_tokens, max_mumbo_tokens);
	mainmemory.write_u32_be(notes + mumbo_tokens_on_hand, max_mumbo_tokens);
	mainmemory.writebyte(notes + jiggies, max_jiggies);
end

function Game.initUI(form_handle, col, row, button_height, label_offset, dropdown_offset)
	options_toggle_neverslip = forms.checkbox(form_handle, "Never Slip", col(0) + dropdown_offset, row(6) + dropdown_offset);
	options_allow_ff_patch = forms.checkbox(form_handle, "Allow FF patch", col(0) + dropdown_offset, row(7) + dropdown_offset);

	encircle_checkbox = forms.checkbox(form_handle, "Encircle (Beta)", col(5) + dropdown_offset, row(4) + dropdown_offset);
	dynamic_radius_checkbox = forms.checkbox(form_handle, "Dynamic Radius", col(5) + dropdown_offset, row(5) + dropdown_offset);

	-- Vile
	options_wave_button =     forms.button(form_handle, "Wave", initWave,         col(10), row(4), col(4) + 8, button_height);
	options_heart_button =    forms.button(form_handle, "Heart", doHeart,         col(10), row(5), col(4) + 8, button_height);
	options_fire_all_button = forms.button(form_handle, "Fire all", fireAllSlots, col(10), row(6), col(4) + 8, button_height);

	-- Moves
	options_moves_dropdown = forms.dropdown(form_handle, { "0. None", "1. Spiral Mountain 100%", "2. FFM Setup", "3. All", "3. Demo" }, col(10) + dropdown_offset, row(7) + dropdown_offset);
	options_moves_button = forms.button(form_handle, "Unlock Moves", unlock_moves, col(5), row(7), col(4) + 8, button_height);
end

function Game.eachFrame()
	-- Furnace fun patch
	applyFurnaceFunPatch();

	updateWave();

	set_orange_timer();
	
	if forms.ischecked(options_toggle_neverslip) then
		neverSlip();
		RF_step();
	end

	if forms.ischecked(encircle_checkbox) then
		encircle_banjo();
	end

	-- Check EEPROM checksums
	if memory.usememorydomain("EEPROM") then
		local i, checksum_value;
		for i=1,#eep_checksum_offsets do
			checksum_value = memory.read_u32_be(eep_checksum_offsets[i]);
			if eep_checksum_values[i] ~= checksum_value then
				print("Slot "..i.." Checksum: "..toHexString(eep_checksum_values[i]).." -> "..toHexString(checksum_value));
				eep_checksum_values[i] = checksum_value;
			end
		end
	end
	memory.usememorydomain("RDRAM");
end

return Game;