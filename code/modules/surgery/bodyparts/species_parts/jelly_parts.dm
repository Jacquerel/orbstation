/obj/item/bodypart/head/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = BIO_SLIME
	limb_id = SPECIES_JELLY
	is_dimorphic = FALSE
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5
	head_flags = HEAD_EYECOLOR | HEAD_EYESPRITES | HEAD_HAIR | HEAD_FACIAL_HAIR

/obj/item/bodypart/head/jelly/Initialize(mapload)
	. = ..()

	var/list/target_zone_list = string_list(list(
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly,
	))

	AddElement(/datum/element/inherit_mutantcolour)
	AddComponent(/datum/component/bodypart_infectious, biotypes_immune = BIO_OOZE, biotypes_hostile = BIO_METAL, target_zones = target_zone_list)

/obj/item/bodypart/chest/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = BIO_SLIME
	limb_id = SPECIES_JELLY
	is_dimorphic = FALSE
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5
	wing_types = list(/obj/item/organ/wings/functional/slime)

/obj/item/bodypart/chest/jelly/Initialize(mapload)
	. = ..()
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/jelly_organ)

	var/list/target_zone_list = string_list(list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly,
	))

	AddElement(/datum/element/inherit_mutantcolour)
	AddComponent(/datum/component/bodypart_infectious, biotypes_immune = BIO_OOZE, biotypes_hostile = BIO_METAL, target_zones = target_zone_list)

/obj/item/bodypart/chest/jelly/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_SLIME)

/obj/item/bodypart/chest/jelly/apply_ownership(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddElement(/datum/element/soft_landing)

/obj/item/bodypart/chest/jelly/clear_ownership(mob/living/carbon/old_owner)
	. = ..()
	old_owner.RemoveElement(/datum/element/soft_landing)

/datum/bodypart_overlay/simple/jelly_organ
	icon_state = "jelly_organ"
	layers = EXTERNAL_BEHIND

/obj/item/bodypart/arm/left/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = BIO_SLIME
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/arm/left/jelly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/inherit_mutantcolour)
	AddComponent(/datum/component/bodypart_dependent, biotypes_required = BIO_OOZE, target_zone = BODY_ZONE_CHEST)

/obj/item/bodypart/arm/right/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = BIO_SLIME
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/arm/right/jelly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/inherit_mutantcolour)
	AddComponent(/datum/component/bodypart_dependent, biotypes_required = BIO_OOZE, target_zone = BODY_ZONE_CHEST)

/obj/item/bodypart/leg/left/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = BIO_SLIME
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/leg/left/jelly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/inherit_mutantcolour)
	AddComponent(/datum/component/bodypart_dependent, biotypes_required = BIO_OOZE, target_zone = BODY_ZONE_CHEST)

/obj/item/bodypart/leg/right/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = BIO_SLIME
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/leg/right/jelly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/inherit_mutantcolour)
	AddComponent(/datum/component/bodypart_dependent, biotypes_required = BIO_OOZE, target_zone = BODY_ZONE_CHEST)
