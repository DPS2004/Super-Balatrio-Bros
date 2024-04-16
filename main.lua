--- STEAMODDED HEADER
--- MOD_NAME: Super Balatrio Bros.
--- MOD_ID: superbalatriobros
--- MOD_AUTHOR: [DPS2004]
--- MOD_DESCRIPTION: So Retro!
--- DISPLAY_NAME: Super Balatrio
--- BADGE_COLOUR: F8451C


local jokerInfoDefault = {
	name = 'NONE',
	config = nil,
	text = {'text'},
	baseEffect = nil,
	rarity = 1,
	cost = 1,
	canBlueprint = true,
	canEternal = true,
	--functions
	locDef = nil,
	init = nil,
	calculate = nil,
	update = nil
}

local function fillInDefaults(t,d)
	for k,v in pairs(d) do
		if t[k] == nil then t[k] = v end
	end
end


function SMODS.INIT.superbalatriobros()
	local mod = SMODS.findModByID('superbalatriobros')
	
	
	
	--local jokerInfo = love.filesystem.load(mod.path .. 'jokers/'..v..'.lua')()
	--fillInDefaults(jokerInfo,jokerInfoDefault)
	
	local joker = SMODS.Joker:new(
		"Super Balatrio Bros.",
		'supermariobros', {},
		{x=0,y=0},
		{name = "Super Balatrio Bros.",text = {'So Retro!'}},
		3,
		5,
		true,
		true,
		false,
		true
	)
	
	joker:register()
	
	local jself = SMODS.Jokers['j_supermariobros']
	
	
	
	--jself.loc_def = jokerInfo.locDef
	
	--jself.set_ability = jokerInfo.init
	
	--jself.calculate = jokerInfo.calculate
	
	
	--load sprite
	SMODS.Sprite:new('j_supermariobros',mod.path,'supermariobros.png',71,95,'asset_atli'):register()
		

	
	
	--updates
	local card_updateRef = Card.update
	function Card.update(self, dt)
		if self.ability.name == "Super Balatrio Bros." then
			if G.STAGE == G.STAGES.RUN then
				--do the Mario
				--swing your arms from side to side
			end
		end
		card_updateRef(self,dt)
	end
	
	--[[
	for k,v in pairs(localizations) do
		G.localization.misc.dictionary[k] = v
	end
    init_localization()
	]]
	
	--Debug deck, for easy testing.
	local Backapply_to_runRef = Back.apply_to_run
	-- Function used to apply new Deck effects
	function Back.apply_to_run(arg_56_0)
		
		if arg_56_0.effect.config.mariodeck then
			G.E_MANAGER:add_event(Event({
				func = function()
					local card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_supermariobros', nil)
					card:add_to_deck()
					G.jokers:emplace(card)
					card:start_materialize()
					G.GAME.joker_buffer = 0

					return true
				end
			
			}))
		
		end
		Backapply_to_runRef(arg_56_0)
	end

	local debugDeckLoc = {
		name="Super Balatrio Bros testing deck",
		text={
			"If Mario, then only Bros!",
		},
	}
	
	local debugDeckSprite = SMODS.Sprite:new('centers', mod.path, 'Enhancers.png', 71, 95, "asset_atli")
	debugDeckSprite:register()

	local debugDeck = SMODS.Deck:new("Super Balatrio Bros testing deck", "mariodeck", {mariodeck = true}, {x = 0, y = 5}, debugDeckLoc)
	debugDeck:register()

end