/// Several tools in one slot.
/obj/item/borg/omnitool
	name = "generic omnitool"
	desc = "a collection of no tools which you can use to do nothing"
	icon_state = "connector"
	/// What kind of things can you pull out of this?
	var/list/item_types = list()
	/// Actual instances of our items (as weakrefs)
	var/list/contained_items = list()
	/// What is currently active?
	var/obj/item/deployed_item

/obj/item/borg/omnitool/Initialize(mapload)
	. = ..()
	for (var/item_type in item_types)
		var/obj/item/new_item = new item_type(src)
		new_item.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
		contained_items += WEAKREF(new_item)
	
/obj/item/borg/omnitool/Destroy()
	QDEL_NULL(deployed_item)
	QDEL_LIST(contained_items)
	return ..()

/obj/item/borg/omnitool/dropped(mob/user)
	retract()
	return ..()

/obj/item/borg/omnitool/melee_attack_chain(atom/attacked, mob/living/user, params)
	if (!isnull(deployed_item))
		deployed_item.melee_attack_chain(attacked, user, params)
		return TRUE
	return ..()

/obj/item/borg/omnitool/update_overlays()
	. = ..()
	if (isnull(deployed_item))
		return
	var/mutable_appearance/held_item = new /mutable_appearance(deployed_item.appearance)
	held_item.layer = layer
	held_item.plane = plane
	. += held_item

/obj/item/borg/omnitool/attack_self(mob/user, modifiers)
	. = ..()
	if (.)
		return TRUE
	if (!retract(user))
		deploy(user)
	return TRUE
	
/// Stow the current tool
/obj/item/borg/omnitool/proc/retract(mob/user)
	if (isnull(deployed_item))
		return FALSE
	balloon_alert(user, "retracted")
	deployed_item = null
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// Deploy the current tool
/obj/item/borg/omnitool/proc/deploy(mob/user)
	var/list/choice_list = list()
	for(var/datum/weakref/item_ref as anything in contained_items)
		var/obj/item/tool = item_ref?.resolve()
		if(isnull(tool))
			contained_items -= item_ref
			continue
		choice_list[tool] = image(tool)
	var/obj/item/choice = show_radial_menu(user, user, choice_list)
	if (isnull(choice))
		return
	balloon_alert(user, "deployed")
	deployed_item = choice
	update_appearance(UPDATE_OVERLAYS)

/// Medic borg surgical tools
/obj/item/borg/omnitool/surgical
	name = "surgical omnitool"
	desc = "A collection of surgical tools stored in a single apparatus."
	item_types = list(
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/surgicaldrill,
	)
