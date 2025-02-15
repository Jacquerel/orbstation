/// What's the most amount of ooze you can have?
#define MAX_OOZE 300
/// Above this amount of ooze of ooze you mutate
#define OOZE_AMOUNT_SLUG 200
/// Above this amount of ooze you start slowing down
#define OOZE_AMOUNT_BLOATED 150
/// Under this amount of ooze you stop slowing down
#define OOZE_AMOUNT_NORMAL 125
/// Under this amount of ooze you start losing limbs
#define OOZE_AMOUNT_DISMEMBER 60
/// Under this amount of ooze you become a simple mob
#define OOZE_AMOUNT_BLOB 30
/// We gain more ooze from eating than we do from starving, just feels better
#define OOZE_NUTRITION_GAIN_MODIFIER 2
/// Regular modifier of damage -> ooze, in case we need to tune this
#define OOZE_DAMAGE_MODIFIER 1
/// Gaining and losing toxins has increased effect on your ooze
#define OOZE_TOX_MODIFIER 1.5
/// When we're wet we lose ooze to physical damage twice as fast
#define OOZE_WET_MODIFIER 2
/// We usually heal less ooze than we take as damage, except via toxins
#define OOZE_HEAL_MODIFIER 0.5
/// All of these damage signals lead into the same proc, toxin signal has different timing so it fires even if you have no toxin damage
#define OOZE_NORMAL_DAMAGE_SIGNALS list(COMSIG_LIVING_POST_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_POST_ADJUST_BURN_DAMAGE, COMSIG_LIVING_POST_ADJUST_OXY_DAMAGE, COMSIG_LIVING_POST_ADJUST_STAMINA_DAMAGE, COMSIG_LIVING_ADJUST_TOX_DAMAGE)

/// Handles the jellyperson ooze mechanic
/datum/component/jelly_ooze
	/// Our current ooze level
	var/ooze_amount = 100
	/// UI displaying our ooze level
	var/atom/movable/screen/jelly_ooze/ooze_display

	var/mob/living/carbon/inserted_mob

/datum/component/jelly_ooze/Initialize()
	. = ..()
	if (!isorgan(parent)) // We put this on a brain and want the amount to persist between insertions into things
		return COMPONENT_INCOMPATIBLE

	ooze_amount = rand (90, 110) // Lose about 3 per minute from nutrition, 20 minutes minimum before you lose all of your limbs

/datum/component/jelly_ooze/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(register_with_carbon))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(remove_from_carbon))

	var/obj/item/organ/brain_item = parent
	if (brain_item.owner)
		register_with_carbon(brain_item, brain_item.owner)

/datum/component/jelly_ooze/UnregisterFromParent()
	var/obj/item/organ/brain_item = parent
	UnregisterSignal(parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if (brain_item.owner)
		remove_from_carbon(brain_item, brain_item.owner)

/// Most of our work is actually done on a mob with the brain in it
/datum/component/jelly_ooze/proc/register_with_carbon(obj/item/organ/source, mob/living/new_guy)
	SIGNAL_HANDLER

	inserted_mob = new_guy
	RegisterSignal(inserted_mob, COMSIG_HUMAN_NUTRITION_ADJUSTED, PROC_REF(on_hunger_changed))
	RegisterSignal(inserted_mob, COMSIG_CARBON_LIMB_POST_DAMAGED, PROC_REF(on_limb_damage))
	RegisterSignal(inserted_mob, COMSIG_CARBON_LIMB_POST_HEALED, PROC_REF(on_limb_healed))
	RegisterSignals(inserted_mob, OOZE_NORMAL_DAMAGE_SIGNALS, PROC_REF(on_adjust_damage))
	RegisterSignal(inserted_mob, COMSIG_LIVING_REVIVE, PROC_REF(on_full_heal))
	RegisterSignal(inserted_mob, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(inserted_mob, COMSIG_QDELETING, PROC_REF(on_mob_deleted))

	if (inserted_mob.hud_used)
		setup_hud()
	else
		RegisterSignal(inserted_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(setup_hud))

/// Stop tracking shit when we're not in a mob
/datum/component/jelly_ooze/proc/remove_from_carbon(obj/item/organ/source, mob/living/old_guy)
	SIGNAL_HANDLER

	inserted_mob = null
	UnregisterSignal(old_guy, list(
		COMSIG_MOB_HUD_CREATED,
		COMSIG_LIVING_REVIVE,
		COMSIG_LIVING_LIFE,
		COMSIG_HUMAN_NUTRITION_ADJUSTED,
		COMSIG_CARBON_LIMB_POST_DAMAGED,
		COMSIG_CARBON_LIMB_POST_HEALED,
		COMSIG_QDELETING,
	) + OOZE_NORMAL_DAMAGE_SIGNALS)
	old_guy.hud_used?.infodisplay -= ooze_display

/// Called every life tick
/datum/component/jelly_ooze/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if (source.stat == DEAD)
		return

	var/static/list/heal_organs = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)
	for (var/organ_slot as anything in heal_organs)
		source.adjustOrganLoss(organ_slot, amount = -1 * seconds_per_tick, required_organ_flag = ORGAN_ORGANIC)

/// Add our ooze tracker
/datum/component/jelly_ooze/proc/setup_hud()
	SIGNAL_HANDLER
	UnregisterSignal(inserted_mob, COMSIG_MOB_HUD_CREATED)
	var/datum/hud/hud_used = inserted_mob.hud_used

	if (ooze_display)
		hud_used.infodisplay -= ooze_display
	else
		ooze_display = new(null, inserted_mob)

	hud_used.infodisplay += ooze_display
	hud_used.show_hud(hud_used.hud_version)

	ooze_display.update_display(ooze_amount)

/// Add or subtract some ooze
/datum/component/jelly_ooze/proc/increment_ooze(increment_value)
	ooze_amount = clamp(ooze_amount + round(increment_value, DAMAGE_PRECISION), 0, MAX_OOZE)
	ooze_display?.update_display(ooze_amount)

/// Called when nutrition updates
/datum/component/jelly_ooze/proc/on_hunger_changed(mob/living/carbon/our_mob, hunger_adjustment)
	SIGNAL_HANDLER
	if (hunger_adjustment > 0 && HAS_TRAIT(our_mob, TRAIT_OOZE_DIGESTION))
		hunger_adjustment *= OOZE_NUTRITION_GAIN_MODIFIER
	increment_ooze(hunger_adjustment)

/// Called when we take some kind of damage
/datum/component/jelly_ooze/proc/on_adjust_damage(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (amount < 0 && (type == STAMINA || type == OXY))
		return // Stamina & Oxygen healing doesn't restore ooze

	var/modifier = OOZE_DAMAGE_MODIFIER
	if (type == TOX)
		modifier = OOZE_TOX_MODIFIER
	else if (type != OXY)
		if (amount > 0 && HAS_TRAIT(inserted_mob, TRAIT_IS_WET))
			modifier = OOZE_WET_MODIFIER
		else if (amount < 0)
			modifier = OOZE_HEAL_MODIFIER

	increment_ooze(amount * -modifier)

/// Called when a limb takes damage
/datum/component/jelly_ooze/proc/on_limb_damage(mob/living/our_mob, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER
	if (!(limb.biological_state & BIO_OOZE))
		return // We only care about oozey parts
	var/modifier = HAS_TRAIT(inserted_mob, TRAIT_IS_WET) ? OOZE_WET_MODIFIER : OOZE_DAMAGE_MODIFIER
	increment_ooze((brute + burn) * -modifier)

/// Called when a limb heals damage
/datum/component/jelly_ooze/proc/on_limb_healed(mob/living/our_mob, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER
	if (!(limb.biological_state & BIO_OOZE))
		return // We only care about oozey parts
	increment_ooze((brute + burn) * OOZE_HEAL_MODIFIER)

/// If we get fully healed from an effect which usually resets blood level, restore ooze
/datum/component/jelly_ooze/proc/on_full_heal(mob/living/our_mob, full_heal_flags)
	SIGNAL_HANDLER
	if (full_heal_flags & HEAL_BLOOD)
		increment_ooze(100 - ooze_amount)

/// If mob is deleted but we are still listening to it then clear our refs
/datum/component/jelly_ooze/proc/on_mob_deleted(mob/living/our_mob)
	SIGNAL_HANDLER
	remove_from_carbon(parent, our_mob)

#undef MAX_OOZE
#undef OOZE_AMOUNT_SLUG
#undef OOZE_AMOUNT_BLOATED
#undef OOZE_AMOUNT_NORMAL
#undef OOZE_AMOUNT_DISMEMBER
#undef OOZE_AMOUNT_BLOB
#undef OOZE_NUTRITION_GAIN_MODIFIER
#undef OOZE_TOX_MODIFIER
#undef OOZE_NORMAL_DAMAGE_SIGNALS
