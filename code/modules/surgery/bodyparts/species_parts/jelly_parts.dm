/obj/item/bodypart/head/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)
	limb_id = SPECIES_JELLY
	is_dimorphic = FALSE
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5
	head_flags = HEAD_EYECOLOR | HEAD_EYESPRITES | HEAD_HAIR | HEAD_FACIAL_HAIR

/obj/item/bodypart/chest/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)
	limb_id = SPECIES_JELLY
	is_dimorphic = FALSE
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5
	wing_types = list(/obj/item/organ/wings/functional/slime)

/obj/item/bodypart/chest/jelly/Initialize(mapload)
	. = ..()
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/jelly_organ)

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
	biological_state = (BIO_FLESH|BIO_BLOODED)
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/arm/right/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/leg/left/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5

/obj/item/bodypart/leg/right/jelly
	icon_greyscale = 'icons/mob/human/species/jelly/bodyparts.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)
	limb_id = SPECIES_JELLY
	dmg_overlay_type = null
	burn_modifier = 0.5
	brute_modifier = 0.5
