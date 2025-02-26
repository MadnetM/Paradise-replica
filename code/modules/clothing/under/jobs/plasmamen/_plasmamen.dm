/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	strip_delay = 200
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5
	icon = 'icons/obj/clothing/species/plasmaman/uniform.dmi'
	species_restricted = list(SPECIES_PLASMAMAN)
	sprite_sheets = list(SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/uniform.dmi')
	icon_state = "plasmaman"
	item_state = "plasmaman"
	item_color = "plasmaman"
	can_adjust = FALSE

/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are [extinguishes_left] extinguisher charges left in this suit.</span>"

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit automatically extinguishes [H.p_them()]!</span>","<span class='warning'>Your suit automatically extinguishes you.</span>")
			if(!extinguishes_left)
				to_chat(H, "<span class='warning'>Onboard auto-extinguisher depleted, refill with a cartridge.</span>")
			playsound(H.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return FALSE


/obj/item/clothing/under/plasmaman/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/extinguisher_refill))
		add_fingerprint(user)
		if(extinguishes_left >= 5)
			to_chat(user, span_warning("The inbuilt extinguisher is full."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		extinguishes_left = 5
		to_chat(user, span_notice("You refill the suit's built-in extinguisher, using up the cartridge"))
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "A cartridge loaded with a compressed extinguisher mix, used to refill the automatic extinguisher on plasma envirosuits."
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'
