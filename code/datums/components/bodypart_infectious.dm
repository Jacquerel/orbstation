/// Bodypart which transforms other bodyparts on the host
/datum/component/bodypart_infectious
	/// Biotypes that are not converted
	var/biotypes_immune
	/// Biotypes that are damaged until destroyed
	var/biotypes_hostile
	/// Other body zones that this one will try to convert, mapped to outcome typepath
	var/list/target_zones

/datum/component/bodypart_infectious/Initialize(biotypes_immune, biotypes_hostile, list/target_zones)
	. = ..()
	if (!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE

	src.biotypes_immune = biotypes_immune
	src.biotypes_hostile = biotypes_hostile
	src.target_zones = target_zones

/datum/component/bodypart_infectious/RegisterWithParent()
	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(on_parent_attached))
	RegisterSignal(parent, COMSIG_BODYPART_REMOVED, PROC_REF(on_parent_removed))

/datum/component/bodypart_infectious/UnregisterFromParent()
	var/obj/item/bodypart/part_parent = parent
	UnregisterSignal(parent, list(COMSIG_BODYPART_ATTACHED, COMSIG_BODYPART_REMOVED))
	if (part_parent.owner)
		on_parent_removed(parent, part_parent.owner)

/// When put into a mob, check its other parts and wait for more parts to attach
/datum/component/bodypart_infectious/proc/on_parent_attached(obj/item/bodypart/part, mob/living/carbon/new_owner)
	SIGNAL_HANDLER
	RegisterSignal(new_owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_new_part))
	for (var/obj/item/bodypart/other_part in new_owner.bodyparts) // Not as anything just in case they're still typepaths for some reason
		on_new_part(new_owner, other_part)

/// When removed from a mob, stop listening to shit
/datum/component/bodypart_infectious/proc/on_parent_removed(obj/item/bodypart/part, mob/living/carbon/former_owner)
	SIGNAL_HANDLER
	UnregisterSignal(former_owner, COMSIG_CARBON_POST_ATTACH_LIMB)
	for (var/part_zone as anything in target_zones)
		var/obj/item/bodypart/part_path = target_zones[part_zone]
		former_owner.remove_status_effect(/datum/status_effect/corrode_limb, part_zone, part_path::plaintext_zone)
		former_owner.remove_status_effect(/datum/status_effect/corrode_limb/transform, part_zone, part_path::plaintext_zone, part_path)

/// When a bodypart is attached, check if we hate it
/datum/component/bodypart_infectious/proc/on_new_part(mob/living/carbon/limb_haver, obj/item/bodypart/new_part, special)
	SIGNAL_HANDLER
	var/transform_result = target_zones[new_part.body_zone]
	if (!transform_result)
		return // We don't care about this body zone
	if (new_part.biological_state & biotypes_immune)
		limb_haver.remove_status_effect(/datum/status_effect/corrode_limb, new_part.body_zone, new_part.plaintext_zone)
		limb_haver.remove_status_effect(/datum/status_effect/corrode_limb, new_part.body_zone, new_part.plaintext_zone, transform_result)
		return

	if (new_part.biological_state & biotypes_hostile)
		limb_haver.apply_status_effect(/datum/status_effect/corrode_limb, new_part.body_zone, new_part.plaintext_zone)
	else
		limb_haver.apply_status_effect(/datum/status_effect/corrode_limb/transform, new_part.body_zone, new_part.plaintext_zone, transform_result)

/// Just repeatedly damage a limb
/datum/status_effect/corrode_limb
	id = "corrode_limb"
	alert_type = null // You can have it effect several limbs at once, don't want to spam the alert area
	status_type = STATUS_EFFECT_MULTIPLE
	/// What body zone are we targeting?
	var/target_zone
	/// Body zone string used for output
	var/plaintext_zone
	/// String to print when applied
	var/apply_string = "burns at the joints, your body is rejecting it!"
	/// String to print when taking damage
	var/harm_string = "burns as your body attacks it!"
	/// Chance per second to damage limb
	var/damage_chance = 20
	/// Damage dealt per chance
	var/damage = 3
	/// Cooldown before displaying a warning that you are taking damage, so it doesn't spam chat
	var/time_between_alerts = 30 SECONDS
	/// Time between telling someone their limb is corroding
	COOLDOWN_DECLARE(alert_cooldown)

/datum/status_effect/corrode_limb/on_creation(mob/living/new_owner, target_zone, plaintext_zone)
	if (!iscarbon(new_owner))
		return FALSE
	if (!target_zone || !plaintext_zone)
		return FALSE
	src.target_zone = target_zone
	src.plaintext_zone = plaintext_zone
	return ..()

/datum/status_effect/corrode_limb/on_apply()
	RegisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(on_part_removed))
	to_chat(owner, span_warning("Your [plaintext_zone] [apply_string]"))
	return TRUE

/datum/status_effect/corrode_limb/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB)

/datum/status_effect/corrode_limb/tick(seconds_between_ticks)
	if (!SPT_PROB(damage_chance, seconds_between_ticks))
		return
	owner.apply_damage(damage = damage, damagetype = BURN, def_zone = target_zone)
	if (COOLDOWN_FINISHED(src, alert_cooldown))
		COOLDOWN_START(src, alert_cooldown, time_between_alerts)
		to_chat(owner, span_warning("Your [plaintext_zone] [harm_string]"))

/// Check if the relevant limb was removed
/datum/status_effect/corrode_limb/proc/on_part_removed(mob/living/carbon/new_owner, obj/item/bodypart/part)
	SIGNAL_HANDLER
	if (part.body_zone == target_zone)
		qdel(src)

/// Transforms the limb into a new one at the end of the process
/datum/status_effect/corrode_limb/transform
	id = "transform_limb"
	duration = 2 MINUTES
	damage_chance = 5
	apply_string = "tingles at the joints as your body begins integrating it."
	harm_string = "itches painfully."
	time_between_alerts = 10 SECONDS
	/// What are we going to create?
	var/replace_type

/datum/status_effect/corrode_limb/transform/on_creation(mob/living/new_owner, target_zone, plaintext_zone, replace_type)
	if (!replace_type)
		return FALSE
	src.replace_type = replace_type
	return ..()

/datum/status_effect/corrode_limb/transform/on_remove()
	. = ..()
	if (duration >= world.time)
		return
	// We timed out
	var/obj/item/bodypart/new_bodypart = new replace_type()
	if (new_bodypart.replace_limb(owner, special = TRUE, delete_replaced = TRUE))
		to_chat(owner, span_warning("Your [plaintext_zone] completes its transformation into a [new_bodypart]!"))
	else
		qdel(new_bodypart)
