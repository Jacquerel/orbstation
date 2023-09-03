/datum/sprite_accessory/body_markings/ltigercolor
	name = "Light Tiger Body (Colored)"
	icon_state = "ltiger"
	gender_specific = 1
	color_src = FACIAL_HAIR_COLOR

/datum/sprite_accessory/body_markings/dtigercolor
	name = "Dark Tiger Body (Colored)"
	icon_state = "dtiger"
	gender_specific = 1
	color_src = FACIAL_HAIR_COLOR

/datum/sprite_accessory/body_markings/lbellycolor
	name = "Light Belly (Colored)"
	icon_state = "lbelly"
	gender_specific = 1
	color_src = FACIAL_HAIR_COLOR

/datum/preference/choiced/lizard_body_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_color"

	return data
