local marienburg_faction_key = "wh_main_emp_marienburg"
--new and fancy Jaan
local jaan_details = {
    general_faction = marienburg_faction_key,
    unit_list = "snek_hkrul_mar_landship,hkrul_privateers,hkrul_mar_inf_goedendagers,hkrul_mar_defenders,hkrul_mar_inf_boogschutter,hkrul_carriers,hkrul_mar_inf_goedendagers", -- unit keys from main_units table
    region_key = "",
    type = "general",																				-- Agent type
    subtype = "hkrul_jk",																	-- Agent subtype
    forename = "names_name_7470711888",															-- From local_en names table, Bernhoff the Butcher is now ruler of Reikland
    clanname = "",																					-- From local_en names table
    surname = "names_name_7470711866",																-- From local_en names table
    othername = "",																					-- From local_en names table
    is_faction_leader = true																		-- Bool for whether the general being replaced is the new faction leader
}

-- make sure Jaan doesn't have the "wh3_main_bundle_character_restrict_experience_gain" EB
core:add_listener(
    "hkrul_CharacterTurnStart",
    "CharacterTurnStart",
    function(context)
        return context:character():character_subtype(jaan_details.subtype)
    end,
    function(context)    
        local character = context:character()
        cm:callback(
            function()
                if character:has_effect_bundle("wh3_main_bundle_character_restrict_experience_gain") then
                    cm:remove_effect_bundle_from_character("wh3_main_bundle_character_restrict_experience_gain", character)
                end
            end,
            0.1
        )
    end,
    true
)


-- Replaces the starting general for a specific faction
local function hkrul_mar()
    local marienburg_faction =  cm:get_faction(marienburg_faction_key)
	if cm:is_new_game() then
        cm:callback(
			function() 
                if marienburg_faction:is_null_interface() == false and marienburg_faction:is_dead() == false then
                    -- Shaping starting setup
                    if marienburg_faction:is_human() then
                        local marienburg_region = cm:get_region("wh3_main_combi_region_marienburg")
                        local marienburg_settlement = marienburg_region:settlement()
                        local marienburg_slot_list = marienburg_region:slot_list()
                        for i = 2, marienburg_slot_list:num_items() - 1 do
                        local slot = marienburg_slot_list:item_at(i)
                        cm:instantly_dismantle_building_in_region(slot)
                        end
                        cm:instantly_set_settlement_primary_slot_level(marienburg_settlement , 2)
                        cm:create_force_with_general(
                            "wh_main_chs_chaos_separatists",
                            "wh_main_chs_inf_chaos_marauders_1,wh_main_chs_inf_chaos_marauders_0,wh_main_chs_inf_chaos_marauders_0,wh_main_chs_cav_marauder_horsemen_0,wh_main_chs_mon_chaos_warhounds_0",
                            "wh3_main_combi_region_gorssel",
                            465,
                            662,
                            "general",
                            "wh_main_chs_lord",
                            "names_name_605123637",
                            "",
                            "names_name_605123638",
                            "",
                            false,
                            function(cqi)
                                cm:set_force_has_retreated_this_turn(cm:get_character_by_cqi(cqi):military_force())
                                cm:transfer_region_to_faction("wh3_main_combi_region_gorssel","wh_main_chs_chaos_separatists")
                                local gorssel_region = cm:get_region("wh3_main_combi_region_gorssel")
                                local gorssel_cqi = gorssel_region:cqi()
                                cm:heal_garrison(gorssel_cqi)
                                cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "")
                                cm:force_declare_war(marienburg_faction_key, "wh_main_chs_chaos_separatists", false, false)
                                cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "") end, 0.5)
                                cm:force_make_trade_agreement(marienburg_faction_key, "ovn_mar_house_den_euwe")
                                cm:make_diplomacy_available(marienburg_faction_key, "ovn_mar_house_den_euwe")
                            end
                        )
                    end

                    local general_x_pos, general_y_pos = cm:find_valid_spawn_location_for_character_from_settlement(jaan_details.general_faction, marienburg_faction:home_region():name(), false, true, 5)
                    
                    out(marienburg_faction_key .. " home region name is " .. jaan_details.region_key)
                    
                    
                    

                    general_x_pos = 466
                    general_y_pos  = 655

                    
                    -- Creating replacement Emil with new fancy Jaan
                    cm:create_force_with_general(
                        jaan_details.general_faction,
                        jaan_details.unit_list,
                        marienburg_faction:home_region():name(),
                        general_x_pos,
                        general_y_pos,
                        jaan_details.type,
                        jaan_details.subtype,
                        jaan_details.forename,
                        jaan_details.clanname,
                        jaan_details.surname,
                        jaan_details.othername,
                        jaan_details.is_faction_leader,
                        function(cqi)
                            local char_str = cm:char_lookup_str(cqi)
                            cm:set_character_unique(char_str, true) --makes Jaan a undisbandable "Legendary Lord"
                            --cm:set_character_immortality(char_str, true) --not needed since immortality is enabled in db
                        end
                    )
                    
                    out("Created replacement Lord " .. jaan_details.forename .. " for " .. marienburg_faction_key)
                    
                    --[[
                    --random lord for the battle
                    cm:create_force_with_general(
                        jaan_details.general_faction,
                        jaan_details.unit_list,
 --jaan is not getting units
                        marienburg_faction:home_region():name(),
                        general_x_pos,
                        general_y_pos,
                        "general",
                        "wh2_dlc13_emp_cha_huntsmarshal",
                        "",
                        "",
                        "",
                        "",
                        false,
                        function(cqi)
                        end
                    )
--]]


                    --[[--not until chorf
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_academia_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_cav_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_diplomacy_1_a")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_diplomacy_1_b")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_diplomacy_1_c")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_diplomacy_1_d")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_economy_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_infantry_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_machine_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_missile_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_purge_1")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_purge_2")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_purge_3")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_purge_4")
                    cm:lock_technology(marienburg_faction_key, "wh2_dlc13_tech_emp_elector_counts_1")
                    --]]
                    
                    --creating hkrul pg here so he could spawn near the new lord
                    local marienburg_faction_cqi = marienburg_faction:command_queue_index();  
                    cm:spawn_unique_agent(marienburg_faction_cqi,"hkrul_pg",true);
                    local hkrul_pg = cm:get_most_recently_created_character_of_type("wh_main_emp_marienburg", "champion", "hkrul_pg")
                    cm:replenish_action_points(cm:char_lookup_str(hkrul_pg:cqi())) 
                    cm:teleport_to(cm:char_lookup_str(hkrul_pg:cqi()), 468, 655) --because now the faction leader has moved
                    
                    cm:apply_dilemma_diplomatic_bonus(marienburg_faction_key, "wh_main_emp_nordland", 3)
                    cm:apply_dilemma_diplomatic_bonus(marienburg_faction_key, "wh_main_emp_middenland", 3)
                    cm:apply_dilemma_diplomatic_bonus(marienburg_faction_key, "wh_main_brt_bretonnia", 2) --becuase of tresspassing penalty I don't know of
                    
                    -- Killing old (generic) Emil permanently
                    local char_list = marienburg_faction:character_list()
                    local char_subtype = "wh_main_emp_lord" -- old (generic) Emil's agent subtype
                    local char_forename = "names_name_2147344088" -- old (generic) Emil's forename

                    for i = 0, char_list:num_items() - 1 do
                        local current_char = char_list:item_at(i)
                        local char_str = cm:char_lookup_str(current_char)

                        if current_char:is_null_interface() == false and current_char:character_subtype_key() == char_subtype and current_char:get_forename() == char_forename and current_char:has_military_force() == true then
                            cm:set_character_immortality(char_str, false)
                            cm:disable_event_feed_events(true, "wh_event_category_character", "", "")
                            cm:kill_character(current_char:command_queue_index(), true, true)
                            cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, 0.5)
                            out("Killing original " .. char_subtype .. " with forename " .. char_forename .. " for " .. marienburg_faction_key .. " permanently")
                        end
                    end
                end
            end, 0.1 --delay to make sure this runs after wh2_campaign_custom_starts.lua
        )
        cm:callback(
			function() 
                local marienburg_region = cm:get_region("wh3_main_combi_region_marienburg")
                cm:heal_garrison(marienburg_region:cqi()) --for extra 2 units
            end, 0.5
        )
	end
end


cm:add_first_tick_callback(function() hkrul_mar() end)