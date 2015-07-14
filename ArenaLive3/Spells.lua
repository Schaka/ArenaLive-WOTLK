ArenaLive.spellDB = {
			["Trinket"] = { 42292, 120 }, -- SpellID and cooldown of the PvP-Trinket
			["Racials"] = {
					-- First Number is the SpellID, 2nd one is the CD. Use 0 if they don't have a shared CD.
					["Human"] = { 59752, 120 },
					["Dwarf"] = { 20594, 120 },
					["NightElf"] = { 58984, 120 },
					["Gnome"] = { 20589, 90 },
					["Draenei"] = { -- For some reason, as a Draenei every class has it's own "Gift of the Naaru" spell. So we have to add them all into the table
						["WARRIOR"] =  { 28880, 180 },
						["PALADIN"] = { 59542, 180 },
						["HUNTER"] = { 59543, 180 },
						["PRIEST"] = { 59544, 180 },
						["DEATHKNIGHT"] = { 59545, 180 },
						["SHAMAN"] = { 59547, 180 },
						["MAGE"] = { 59548, 180 },
						["MONK"] = { 121093, 180 } -- Need to test this as soon as MoP is out.
					},
					["Worgen"] = { 68992, 120, 0 },
					["Orc"] = { -- Since Orcs also have class-specific racials, we need to add all of them
						["WARRIOR"] = { 20572, 120 },
						["HUNTER"] = { 20572, 120 },
						["ROGUE"] = { 20572, 120 },
						["SHAMAN"] = { 33697, 120 },
						["MAGE"] = { 33702, 120 },
						["WARLOCK"] = { 33702, 120 },
						["DEATHKNIGHT"] = { 20572, 120 },
						["MONK"] = { 33697, 120 } -- I guess Monks will get the same racial version as Shamans, since it increases AP+Spell Power. Test this as soon as MoP is out
					},
					["Scourge"] = { 7744, 120 },
					["Tauren"] = { 20549, 120 },
					["Troll"] = { 26297, 180 },
					["BloodElf"] = {
						["PALADIN"] = { 28730, 120 },
						["HUNTER"] = { 80483, 120 },
						["ROGUE"] = { 25046, 120 },
						["PRIEST"] = { 28730, 120 },
						["MAGE"] = { 28730, 120 },
						["WARLOCK"] = { 28730, 120 },
						["DEATHKNIGHT"] = { 50613, 120 },
					},
			},
			["CooldownResets"] = {
				[11958] = {				-- Mage: Cold Snap
					[120] = true,			-- Cone of Cold
					[122] = true,			-- Frost Nova
					[45438] = true,			-- Ice Block
				},
				[14185] = {				-- Rogue: Preparation
					[2983] = true,
					[1856] = true,
					[5277] = true,
				},
			},			
			["CCIndicator"] = { -- This table is used to track those spells, that are shown in the cc indcator.
				-- The order is [spellID] = Priority-Type.

				-- Death Knight
				[48707] = "defCD",			-- Anti-Magic Shell
				[51271] = "offCD", 			-- Pillar of Frost
				[49016] = "offCD",			-- Unholy Frenzy
				[47481] = "stun",			-- Gnaw (Petstun)
				[47476] = "silence",		-- Strangulate
				
				-- Druid
				[22812] = "defCD",			-- Barkskin
				[33786] = "defCD",			-- Cyclone (Made that one a def CD, because the enemy is immune to everything during cyclone)
				[22570] = "stun",			-- Maim
				[8983] = "stun",			-- Mighty Bash
				[339] = "root",				-- Entangling Roots
				[66070] = "root",			-- Entangling Roots (Force of Nature)
				[53312] = "root",			-- Entangling Roots (Nature's Grasp)

				-- Hunter
				[5384] = "defCD",			-- Feign Death
				[19263] = "defCD",			-- Deterrence
				[19577] = "stun",			-- Intimidation (stun)
				[3355] = "crowdControl",	-- Freezing Trap
				[19386] = "crowdControl",	-- Wyvern Sting
				[64803] = "root",			-- Entrapment (trap-roots)
				
				-- Mage
				[45438] = "defCD",			-- Ice Block
				[12472] = "offCD",			-- Icy Veins
				[44572] = "stun",			-- Deep Freeze
				[118] = "crowdControl",		-- Standard Polymorph
				[61305] = "crowdControl",	-- Polymorph Cat
				[28272] = "crowdControl",	-- Polymorph Pig
				[28271] = "crowdControl",	-- Polymorph Turtle
				[31661] = "crowdControl",	-- Dragon's Breath
				[122] = "root",				-- Frost Nova
				[33395] = "root",			-- Freeze (Pet Nova)

				-- Paladin
				[31850] = "defCD",			-- Ardent Defender
				[642] = "defCD",			-- Divine Shield
				[1022] = "defCD",			-- Hand of Protection
				[31842] = "offCD",			-- Avenging Wrath: Holy
				[31884] = "offCD",			-- Avenging Wrath: Retribution
				[10308] = "stun",			-- Hammer of Justice
				[31935] = "silence",		-- Avenger's Shield
				[10326] = "crowdControl",	-- Turn Evil
				[20066] = "crowdControl",	-- Repentance
				[6940] = "usefulBuffs",		-- Hand of Sacrifice
				
				-- Priest
				[33206] = "defCD",			-- Pain Suppression
				[47788] = "defCD",			-- Guardian Spirit
				[47585] = "defCD",			-- Dispersion
				[10060] = "offCD",			-- Power Infusion
				[64044] = "stun",			-- Psychic Horror
				[15487] = "silence",		-- Silence
				[27610] = "crowdControl",	-- Psychic Scream
				[11446] = "crowdControl",	-- Mind Control
				[9484] = "crowdControl",	-- Shackle Undead
				[6346] = "usefulBuffs",		-- Fear Ward
				[34914] = "usefulDebuffs",	-- Vampiric Touch
				
				-- Rogue	
				[5277] = "defCD",			-- Evasion
				[31224] = "defCD",			-- Cloak of Shadows
				[13750] = "offCD",			-- Adrenaline Rush
				[51690] = "offCD",			-- Killing Spree
				[51713] = "offCD",			-- Shadow Dance
				[8643] = "stun", 			-- Kidney Shot
				[1833] = "stun",			-- Cheap Shot
				[1330] = "silence",			-- Garrote - Silence
				[2094] = "crowdControl", 	-- Blind
				[1776] = "crowdControl", 	-- Gouge
				[51724] = "crowdControl", 	-- Sap
				
				-- Shaman
				[30823] = "defCD",			-- Shamanistic Rage
				[16166] = "offCD",			-- Elemental Mastery
				[51514] = "crowdControl",	-- Hex
				[8178] = "usefulBuffs",		-- Grounding Totem
				
				-- Warlock
				[18647] = "defCD",			-- Banish (It is marked as def CD for the same reason as Cyclone)
				[47860] = "stun",			-- Death Coil
				[30283] = "stun",			-- Shadowfury
				[22703] = "stun",			-- Infernal Awakening
				[5484] = "crowdControl",	-- Howl of Terror
				[6215] = "crowdControl",	-- Fear
				[6358] = "crowdControl",	-- Seduce (Pet-Charm)
				[30108] = "usefulDebuffs",	-- Unstable Affliction		
				
				-- Warrior
				[871] = "defCD",			-- Shield Wall
				[1719] = "offCD",			-- Recklessness
				[58977] = "stun",			-- Shockwave
				[12809] = "stun",			-- Concussion Blow
				[58357] = "silence",		-- Heroic Throw silence ?
				[5246] = "crowdControl",	-- Intimidating Shout
				[23920] = "usefulBuffs",	-- Spell Reflection
				[47995] = "stun",			-- Intercept (Stun)
			},
			["FilteredSpells"] = { --[[This list blocks spells that cause bugs in the casthistory.]]--
					[75] = "Auto Shot", -- For every autoshot a hunter casts, the cast history will create a button. So we filter it.
					[5374] = "Mutilate", -- The real Mutilate-Spell triggers these two spells. We don't need to show all three of them in the CastHistory, so we block them too.
					[27576] = "Mutilate Off-Hand",
					[836] = "LOGINEFFECT",
			},
			["DefensiveCooldowns"] = {
				["DEATHKNIGHT"] = {
					[48707] = 45,		-- Anti-Magic Shell
				},
				["DRUID"] = {
					[22812] = 60,		-- Barkskin
					[61336] = 180,		-- Survival Instincts	
				},
				["HUNTER"] = {
					[19263] = 180		-- Deterrence
				},
				["MAGE"] = {
					[45438] = 300,		-- Ice Block
				},
				["PALADIN"] = {
					[642] = 300,		-- Divine Shield
				},
				["PRIEST"] = {
					[33206] = 120,			-- Pain Suppression (with Setbonus)
					[47788] = 120,			-- Guardian Spirit
					[47585] = 120,			-- Dispersion (Unglyphed)
				},
				["ROGUE"] = {
					[5277] = 120,			-- Evasion
				},
				["SHAMAN"] = {
					[30823] = 60,			-- Shamanistic Rage
				},
				["WARRIOR"] = {
					[871] = 180,			-- Shield Wall
				},
				["WARLOCK"] = {
				},
			},
			["ShownBuffs"] = { -- I've decided to just show certain Buffs on the Buff-frame. Here is the List.
			-- Order is [SpellID] = "Castname",

				--[[Death Knight
				[48707] = "Anti-Magic Shell",
				[51052] = "Anti-Magic Zone",
				[48263] = "Blood Presence",
				[49222] = "Bone Shield",
				[118009] = "Desecrated Ground",
				[48266] = "Frost Presence",
				[48792] = "Icebound Fortitude",
				[49039] = "Lichborne",
				[51271] = "Pillar of Frost",
				[114556] = "Purgatory",
				[55610] = "Unholy Aura",
				[115989] = "Unholy Blight",
				[49016] = "Unholy Frenzy",
				[48265] = "Unholy Presence",
				[55233] = "Vampiric Blood",


				-- Druid
				[22812] = "Barkskin",
				[5487] = "Bear Form",
				[106951] = "Berserk",
				[50334] = "Berserk",
				[155835] = "Bristling Fur",
				[768] = "Cat Form",
				[102352] = "Cenarion Ward",
				[171745] = "Claws of Shirvallah (Improved Catform)",
				[1850] = "Dash",
				[108291] = "Heart of the Wild (Balance)",
				[108292] = "Heart of the Wild (Feral)",
				[108293] = "Heart of the Wild (Guardian)",
				[108294] = "Heart of the Wild (Restoration)",
				[102560] = "Incarnation: Chosen of Elune",
				[102543] = "Incarnation: King of the Jungle",
				[102558] = "Incarnation: Son of Ursoc",
				[33891] = "Incarnation: Tree of Life",
				[29166] = "Innervate",
				[102342] = "Ironbark",
				[17007] = "Leader of the Pack",
				[33763] = "Lifebloom",
				[59990] = "Lifebloom",
				[94447] = "Lifebloom",
				[1126] = "Mark of the Wild",
				[106922] = "Might of Ursoc",
				[24858] = "Moonkin Form",
				[132158] = "Nature's Swiftness",
				[124974] = "Nature's Vigil",
				[5215] = "Prowl",
				[774] = "Rejuvenation",
				[155777] = "Rejuvenation (Germination)",
				[8936] = "Regrowth",
				[77764] = "Stampeding Roar",
				[77761] = "Stampeding Roar",
				[106898] = "Stampeding Roar",
				[48505] = "Starfall",
				[61336] = "Survival Instincts",
				[5217] = "Tiger's Fury",
				[740] = "Tranquility",
				[783] = "Travel Form",
				
				-- Hunter
				[5118] = "Aspect of the Cheetah",
				[172106] = "Aspect of the Fox",
				[13165] = "Aspect of the Hawk",
				[13159] = "Aspect of the Pack",
				[19574] = "Bestial Wrath",
				[51755] = "Camouflage",
				[19263] = "Deterrence",
				[148467] = "Deterrence (Crouching Tiger, Hidden Chimera)",
				[5384] = "Feign Death",
				[119449] = "Glyph of Camouflage",
				[109260] = "Iron Hawk",
				[62305] = "Master's Call",
				[54216] = "Master's Call",
				[3045] = "Rapid Fire",
				[19506] = "Trueshot Aura",

				
				--Mage
				[110909] = "Alter Time",
				[1459] = "Arcane Brilliance",
				[12042] = "Arcane Power",
				[159916] = "Amplify Magic",
				[57761] = "Brain Freeze",
				[87023] = "Cauterize",
				[61316] = "Dalaran Brilliance",
				[12051] = "Evocation",
				[7302] = "Frost Armor",
				[113862] = "Greater Invisibility",
				[11426] = "Ice Barrier",
				[45438] = "Ice Block",
				[108839] = "Ice Floes",
				[12472] = "Icy Veins",
				[66] = "Invisibility",
				[6117] = "Mage Armor",
				[30482] = "Molten Armor",
				[12043] = "Presence of Mind",

				
				-- Monk
				[157535] = "Breath of the Serpent",
				[122278] = "Dampen Harm",
				[122783] = "Diffuse Magic",
				[116781] = "Legacy of the White Tiger",
				[116849] = "Life Cocoon",
				[137562] = "Nimble Brew",
				[119611] = "Renewing Mist",
				[116844] = "Ring of Peace",
				[152173] = "Serenity",
				[122470] = "Touch of Karma",
				[115176] = "Zen Meditation",
				
				--Paladin 
				[31850] = "Ardent Defender",
				[156910] = "Beacon of Faith",
				[157007] = "Beacon of Insight",
				[53563] = "Beacon of Light",
				[20217] = "Blessing of Kings",
				[19740] = "Blessing of Might",
				[31842] = "Avenging Wrath: Holy",
				[31884] = "Avenging Wrath: Retribution",
				[31821] = "Devotion Aura",
				[31842] = "Divine Favor",
				[54428] = "Divine Plea",
				[498] = "Divine Protection",
				[642] = "Divine Shield",
				[86659] = "Guardian of Ancient Kings (Protection)",
				[1044] = "Hand of Freedom",
				[1022] = "Hand of Protection",
				[114039] = "Hand of Purity",
				[6940] = "Hand of Sacrifice",
				[1038] = "Hand of Salvation",
				[105809] = "Holy Avenger",
				[20925] = "Sacred Shield",
				[105361] = "Seal of Command",
				[20164] = "Seal of Justice",
				[20154] = "Seal of Righteousness",
				[31801] = "Seal of Truth",
				[152262] = "Seraphim",
				[85499] = "Speed of Light",				
				
				
				--Priest
				[121557] = "Angelic Feather",
				[81700] = "Archangel",
				[81209] = "Chakra: Chastise",
				[81206] = "Chakra: Sanctuary",
				[81208] = "Chakra: Serenity",
				[152118] = "Clarity of Will",
				[47585] = "Dispersion",
				[64843] = "Divine Hymn",
				[159630] = "Shadow Magic (Fade Aura Mastery)",
				[6346] = "Fear Ward",
				[45242] = "Focused Will",
				[120587] = "Glyph of Mind Flay",
				[47788] = "Guardian Spirit",
				[33206] = "Pain Suppression",
				[114239] = "Phantasm",
				[10060] = "Power Infusion",
				[81782] = "Power Word: Barrier",
				[21562] = "Power Word: Fortitude",
				[17] = "Power Word: Shield",
				[41637] = "Prayer of Mending",
				[139] = "Renew",
				[15473] = "Shadowform",
				[112833] = "Spectral Guise",
				[27827] = "Spirit of Redemption",
				[109964] = "Spirit Shell",
				[114908] = "Spirit Shell: Absorb",
				[114255] = "Surge of Light",
				
				
				--Rogue
				[13750] = "Adrenaline Rush",
				[108212] = "Burst of Speed",
				[31224] = "Cloak of Shadows",
				[74001] = "Combat Readiness",
				[74002] = "Combat Insight (Combat Readiness Stacks)",
				[3408] = "Crippling Poison",
				[2823] = "Deadly Poison",
				[5277] = "Evasion",
				[1966] = "Feint",
				[51690] = "Killing Spree",
				[108211] = "Leeching Poison",
				[5761] = "Mind-numbing Poison",
				[73651] = "Recuperate",
				[51713] = "Shadow Dance",
				[114018] = "Shroud of Concealment",
				[5171] = "Slice and Dice",
				[2983] = "Sprint",
				[1784] = "Stealth",
				[1856] = "Vanish",
				[8679] = "Wound Poison",
				

				--Shaman
				[108281] = "Ancestral Guidance",
				[16188] = "Ancestral Swiftness",
				[165339] = "Ascendance (Elemental)",
				[165341] = "Ascendance (Enhancement)",
				[165344] = "Ascendance (Restoration)",
				[108271] = "Astral Shift",
				[974] = "Earth Shield",
				[16166] = "Elemental Mastery",
				[119523] = "Healing Stream Totem",
				[324] = "Lightning Shield",
				[61295] = "Riptide",
				[30823] = "Shamanistic Rage",
				[58875] = "Spirit Walk",
				[79206] = "Spiritwalker's Grace",
				[52127] = "Water Shield",
	
				
				--Warlock
				[111397] = "Blood Horror",
				[166928] = "Blood Pact",
				[111400] = "Burning Rush",
				[114168] = "Dark Apotheosis",
				[110913] = "Dark Bargain",
				[109773] = "Dark Intent",
				[108359] = "Dark Regeneration",
				[113858] = "Dark Soul: Instability",
				[113861] = "Dark Soul: Knowledge",
				[113860] = "Dark Soul: Misery",
				[689] = "Drain Life",
				[103103] = "Drain Soul",
				[108503] = "Grimoire of Sacrifice",
				[171975] = "Grimoire of Synergy",
				[119049] = "Kil'jaeden's Cunning",
				[108508] = "Mannoroth's Fury",
				[103958] = "Metamorphosis",
				[79957] = "Soul Link",
				[108416] = "Sacrificial Pact",
				[104773] = "Unending Resolve",

				
				--Warrior
				[107574] = "Avatar",
				[18499] = "Berserker Rage",
				[46924] = "Bladestorm",
				[12292] = "Bloodbath",
				[118038] = "Die by the Sword",
				[55694] = "Enraged Regeneration",
				[3411] = "Intervene",
				[12975] = "Last Stand",
				[114028] = "Mass Spell Reflection",
				[97463] = "Rallying Cry",
				[1719] = "Recklessness",
				[114029] = "Safeguard",
				[125667] = "Second Wind",
				[871] = "Shield Wall",
				[23920] = "Spell Reflection",
				[12328] = "Sweeping Strikes",
				[114030] = "Vigilance",

				
				-- Other:
				[121279] = "Lifeblood",
				--]]
			},
		["Dispels"] = {
			-- TO DO: SPEC SPECIFIC SPELLS
			["DRUID"] = { 88423, 8 }, 			-- Nature's Cure
			["MAGE"] = { 475, 8 },				-- Remove Curse
			["PALADIN"] = { 4987, 8 }, 			-- Cleanse
			["PRIEST"] = { 527, 8 }, 			-- Purify
			["SHAMAN"] = { 51886, 8 }, 			-- Cleanse Spirit
		},
		["Interrupts"] = {
			["DEATHKNIGHT"] = { 47528, 15 },	-- Mind Freeze
			["DRUID"] = { 16979, 15 }, 			-- Feral Charge
			["HUNTER"] = { 42671, 24 },			-- Silencing Shot
			["MAGE"] = { 2139, 24 },			-- Counter Spell
			["ROGUE"] = { 1766, 15 }, 			-- Kick
			["SHAMAN"] = { 57994, 12 },			-- Wind Shear
			["WARLOCK"] = { 19647, 24 }, 		-- Spell lock Warlock (I use this one for all warlock counters and let them have a shared CD via the "SharedCooldowns" table.
			["WARRIOR"] = { 6552, 15 },			-- Pummel		
		},
		["SharedCooldowns"] = {
				[42292] = { -- PvP-Insignia
					[59752] = 120,			-- Human Racial
					[7744] = 30,			-- Will of the Forsaken
				},
				[59752] = { -- Human Racial
					[42292] = 120,			-- PvP-Insignia
				},
				[7744] = { -- Will of the Forsaken
					[42292] = 30,			-- PvP-Insignia
				},
			},
		["DiminishingReturns"] =
			{
				-- Disorients:
				[33786] = "disorient",			-- Cyclone
				
				[31661] = "disorient", 			-- Dragon's Breath
				
				[105421] = "disorient", 		-- Blinding Light
				[10326] = "disorient", 			-- Turn Evil
				
				[8122] = "disorient", 			-- Psychic Scream
				
				[2094] = "disorient", 			-- Blind

				[5484] = "disorient", 			-- Howl of Terror
				[6358] = "disorient", 			-- Seduction

				[5246] = "disorient",			-- Intimidating Shout
				
				
				-- Incapacitates:
				[99] = "incapacitate", 			-- Incapacitating Roar
				
				[3355] = "incapacitate", 		-- Freezing Trap
				[19386] = "incapacitate", 		-- Wyvern Sting
				
				[118] = "incapacitate", 		-- Polymorph
				
				[20066] = "incapacitate", 		-- Repentance
				
				[605] = "incapacitate",			-- Dominate Mind
				[64044] = "incapacitate", 		-- Psychic Horror
				[9484] = "incapacitate", 		-- Shackle Undead (?)				
				
				[1776] = "incapacitate", 		-- Gouge
				[6770] = "incapacitate", 		-- Sap
				
				[51514] = "incapacitate", 		-- Hex
				
				[710] = "incapacitate",			-- Banish
				[6789] = "incapacitate", 		-- Mortal Coil
				
				
				
				-- Roots:
				[96294] = "root", 				-- Chains of Ice
				
				[339] = "root", 				-- Entangling Roots

				
				[53148] = "root",				-- Charge (Tenacity Pet)
				[64803] = "root",				-- Entrapment (trap-roots)
				
				[33395] =  "root",  			-- Freeze
				[122] = "root",  				-- Frost Nova
				
				-- Silences:
				[47476] = "silence", 			-- Strangulate
				
				[31935] = "silence", 			-- Avenger's Shield
				
				[15487] = "silence", 			-- Silence
				
				[1330] = "silence", 			-- Garrote - Silence
							
				[28730] = "silence",
				[25046] = "silence",
				[28730] = "silence",
				[28730] = "silence",
				[28730] = "silence",
				[50613] = "silence",
		
				-- Stuns:		
				[22570] = "stun", 				-- Maim
				[5211] = "stun", 				-- Mighty Bash

				[19577] = "stun",				-- Intimidation

				[44572] = "stun", 				-- Deep Freeze
				
				[853] = "stun",					-- Hammer of Justice
				
				[1833] = "stun", 				-- Cheap Shot
				[408] = "stun", 				-- Kidney Shot
				
				[22703] = "stun",				-- Infernal Awakening
				[30283] = "stun", 				-- Shadowfury
				
				[20549] = "stun", 				-- War Stomp (Tauren Racial)
			},
	};