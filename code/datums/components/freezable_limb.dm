/// Disable limb when below a certain temperature
/datum/component/freezable_limb
	/// Temp below which it stops working
	var/freeze_temp
	/// Are we currently frozen?
	var/frozen = FALSE

/datum/component/freezable_limb/Initialize(freeze_temp = BODYTEMP_COLD_DAMAGE_LIMIT)
	. = ..()
	if (!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE

	src.freeze_temp = freeze_temp

/datum/component/freezable_limb/RegisterWithParent()
	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(register_with_carbon))
	RegisterSignal(parent, COMSIG_BODYPART_REMOVED, PROC_REF(unregister_from_carbon))
	var/obj/item/bodypart/part = parent
	if (part.owner)
		register_with_carbon(part, part.owner)

/datum/component/freezable_limb/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_BODYPART_ATTACHED, COMSIG_BODYPART_REMOVED))
	var/obj/item/bodypart/part = parent
	if (part.owner)
		unregister_from_carbon(part.owner)

	REMOVE_TRAIT(parent, TRAIT_PARALYSIS, FROZEN_LIMB_TRAIT)

/// When we attach to someone check their temperature
/datum/component/freezable_limb/proc/register_with_carbon(obj/item/bodypart/part, mob/living/carbon/limb_haver)
	SIGNAL_HANDLER
	RegisterSignal(limb_haver, COMSIG_MOB_BODYTEMP_CHANGED, PROC_REF(on_temp_changed))
	RegisterSignal(limb_haver, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	on_temp_changed(limb_haver, limb_haver.bodytemperature)

/// If we stop being attached to someone stop caring
/datum/component/freezable_limb/proc/unregister_from_carbon(obj/item/bodypart/part, mob/living/carbon/limb_lacker)
	SIGNAL_HANDLER
	UnregisterSignal(limb_lacker, list(COMSIG_MOB_BODYTEMP_CHANGED, COMSIG_ATOM_EXAMINE))

/// Called when our mob's body temperature changes
/datum/component/freezable_limb/proc/on_temp_changed(mob/living/carbon/the_temperaturer, temperature)
	SIGNAL_HANDLER
	if (temperature < freeze_temp)
		if (!frozen)
			frozen = TRUE
			ADD_TRAIT(parent, TRAIT_PARALYSIS, FROZEN_LIMB_TRAIT)
	else if (frozen)
		frozen = FALSE
		REMOVE_TRAIT(parent, TRAIT_PARALYSIS, FROZEN_LIMB_TRAIT)

/// Called when someone takes a peek
/datum/component/freezable_limb/proc/on_examined(mob/living/carbon/examinee, mob/the_looker, list/examine_list)
	SIGNAL_HANDLER
	if (frozen)
		examine_list += span_warning("[examinee.p_their()] [parent] is frozen solid!")
