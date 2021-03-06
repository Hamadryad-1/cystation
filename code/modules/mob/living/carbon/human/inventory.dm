/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = 0)
	if(dna)
		return dna.species.can_equip(I, slot, disable_warning, src)
	else
		switch(slot)
			if(slot_l_hand)
				if(l_hand)
					return 0
				return 1
			if(slot_r_hand)
				if(r_hand)
					return 0
				return 1
			if(slot_wear_mask)
				if(wear_mask)
					return 0
				if( !(I.slot_flags & SLOT_MASK) )
					return 0
				return 1
			if(slot_back)
				if(back)
					return 0
				if( !(I.slot_flags & SLOT_BACK) )
					return 0
				return 1
			if(slot_wear_suit)
				if(wear_suit)
					return 0
				if( !(I.slot_flags & SLOT_OCLOTHING) )
					return 0
				return 1
			if(slot_gloves)
				if(gloves)
					return 0
				if( !(I.slot_flags & SLOT_GLOVES) )
					return 0
				return 1
			if(slot_shoes)
				if(shoes)
					return 0
				if( !(I.slot_flags & SLOT_FEET) )
					return 0
				return 1
			if(slot_belt)
				if(belt)
					return 0
				if(!w_uniform)
					if(!disable_warning)
						src << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
					return 0
				if( !(I.slot_flags & SLOT_BELT) )
					return
				return 1
			if(slot_glasses)
				if(glasses)
					return 0
				if( !(I.slot_flags & SLOT_EYES) )
					return 0
				return 1
			if(slot_head)
				if(head)
					return 0
				if( !(I.slot_flags & SLOT_HEAD) )
					return 0
				return 1
			if(slot_ears)
				if(ears)
					return 0
				if( !(I.slot_flags & SLOT_EARS) )
					return 0
				return 1
			if(slot_w_uniform)
				if(w_uniform)
					return 0
				if( !(I.slot_flags & SLOT_ICLOTHING) )
					return 0
				return 1
			if(slot_wear_id)
				if(wear_id)
					return 0
				if(!w_uniform)
					if(!disable_warning)
						src << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
					return 0
				if( !(I.slot_flags & SLOT_ID) )
					return 0
				return 1
			if(slot_l_store)
				if(I.flags & NODROP) //Pockets aren't visible, so you can't move NODROP items into them.
					return 0
				if(l_store)
					return 0
				if(!w_uniform)
					if(!disable_warning)
						src << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
					return 0
				if(I.slot_flags & SLOT_DENYPOCKET)
					return
				if( I.w_class <= 2 || (I.slot_flags & SLOT_POCKET) )
					return 1
			if(slot_r_store)
				if(I.flags & NODROP)
					return 0
				if(r_store)
					return 0
				if(!w_uniform)
					if(!disable_warning)
						src << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
					return 0
				if(I.slot_flags & SLOT_DENYPOCKET)
					return 0
				if( I.w_class <= 2 || (I.slot_flags & SLOT_POCKET) )
					return 1
				return 0
			if(slot_s_store)
				if(I.flags & NODROP) //Suit storage NODROP items drop if you take a suit off, this is to prevent people exploiting this.
					return 0
				if(s_store)
					return 0
				if(!wear_suit)
					if(!disable_warning)
						src << "<span class='warning'>You need a suit before you can attach this [I.name]!</span>"
					return 0
				if(!wear_suit.allowed)
					if(!disable_warning)
						usr << "<span class='warning'>You somehow have a suit with no defined allowed items for suit storage, stop that!</span>"  //should be src?
					return 0
				if(I.w_class > 4)
					if(!disable_warning)
						usr << "<span class='warning'>The [I.name] is too big to attach!</span>"  //should be src?
					return 0
				if( istype(I, /obj/item/device/pda) || istype(I, /obj/item/weapon/pen) || is_type_in_list(I, wear_suit.allowed) )  //ugly and un-polymorphic.
					return 1
				return 0
			if(slot_handcuffed)
				if(handcuffed)
					return 0
				if(!istype(I, /obj/item/weapon/restraints/handcuffs))
					return 0
				return 1
			if(slot_legcuffed)
				if(legcuffed)
					return 0
				if(!istype(I, /obj/item/weapon/restraints/legcuffs))
					return 0
				return 1
			if(slot_in_backpack)
				if (back && istype(back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = back
					if(B.contents.len < B.storage_slots && I.w_class <= B.max_w_class)
						return 1
				return 0
		return 0 //Unsupported slot



/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		var/obj/item/weapon/storage/S = H.get_inactive_hand()
		if(!I)
			H << "<span class='warning'>You are not holding anything to equip!</span>"
			return
		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand()
			else
				update_inv_r_hand()
		else if(s_active && s_active.can_be_inserted(I,1))	//if storage active insert there
			s_active.handle_item_insertion(I)
		else if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))	//see if we have box in other hand
			S.handle_item_insertion(I)
		else
			S = H.get_item_by_slot(slot_belt)
			if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))		//else we put in belt
				S.handle_item_insertion(I)
			else
				S = H.get_item_by_slot(slot_back)	//else we put in backpack
				if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))
					S.handle_item_insertion(I)
					playsound(src.loc, "rustle", 50, 1, -5)
				else
					H << "<span class='warning'>You are unable to equip that!</span>"


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/I, list/slots, qdel_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot], qdel_on_fail = 0))
			return slot
	if(qdel_on_fail)
		qdel(I)
	return null


// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_belt)
			return belt
		if(slot_wear_id)
			return wear_id
		if(slot_ears)
			return ears
		if(slot_glasses)
			return glasses
		if(slot_gloves)
			return gloves
		if(slot_head)
			return head
		if(slot_shoes)
			return shoes
		if(slot_wear_suit)
			return wear_suit
		if(slot_w_uniform)
			return w_uniform
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_s_store)
			return s_store
	return null


/mob/living/carbon/human/unEquip(obj/item/I)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return


	if(I == wear_suit)
		if(s_store)
			unEquip(s_store, 1) //It makes no sense for your suit storage to stay on you if you drop your suit.
		wear_suit = null
		if(I.flags_inv & HIDEJUMPSUIT)
			update_inv_w_uniform()
		update_inv_wear_suit()
	else if(I == w_uniform)
		if(r_store)
			unEquip(r_store, 1) //Again, makes sense for pockets to drop.
		if(l_store)
			unEquip(l_store, 1)
		if(wear_id)
			unEquip(wear_id)
		if(belt)
			unEquip(belt)
		w_uniform = null
		update_suit_sensors()
		update_inv_w_uniform()
	else if(I == gloves)
		gloves = null
		update_inv_gloves()
	else if(I == glasses)
		glasses = null
		update_inv_glasses()
	else if(I == ears)
		ears = null
		update_inv_ears()
	else if(I == shoes)
		shoes = null
		update_inv_shoes()
	else if(I == belt)
		belt = null
		update_inv_belt()
	else if(I == wear_mask)
		wear_mask = null
		if(I.flags & BLOCKHAIR)
			update_hair()	//rebuild hair
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		sec_hud_set_ID()
		update_inv_wear_mask()
	else if(I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		update_inv_wear_id()
	else if(I == r_store)
		r_store = null
		update_inv_pockets()
	else if(I == l_store)
		l_store = null
		update_inv_pockets()
	else if(I == s_store)
		s_store = null
		update_inv_s_store()

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, redraw_mob = 1)
	if(!slot)	return
	if(!istype(I))	return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.equipped(src, slot)
	I.layer = 20

	switch(slot)
		if(slot_back)
			back = I
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			wear_mask = I
			if(wear_mask.flags & BLOCKHAIR)
				update_hair(redraw_mob)	//rebuild hair
			sec_hud_set_ID()
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			handcuffed = I
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			legcuffed = I
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			l_hand = I
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			r_hand = I
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			belt = I
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			wear_id = I
			sec_hud_set_ID()
			update_inv_wear_id(redraw_mob)
		if(slot_ears)
			ears = I
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			glasses = I
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			gloves = I
			update_inv_gloves(redraw_mob)
		if(slot_head)
			head = I
			if(head.flags & BLOCKHAIR)
				update_hair(redraw_mob)	//rebuild hair
			update_inv_head(redraw_mob)
		if(slot_shoes)
			shoes = I
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			wear_suit = I
			if(I.flags_inv & HIDEJUMPSUIT)
				update_inv_w_uniform()
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			w_uniform = I
			update_suit_sensors()
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			l_store = I
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			r_store = I
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			s_store = I
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(get_active_hand() == I)
				unEquip(I)
			I.loc = back
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"
			return

//Cycles through all clothing slots and tests them for destruction
/mob/living/carbon/human/proc/shred_clothing(bomb,shock)
	var/covered_parts = 0	//The body parts that are protected by exterior clothing/armor
	var/head_absorbed = 0	//How much of the shock the headgear absorbs when it is shredded. -1=it survives
	var/suit_absorbed = 0	//How much of the shock the exosuit absorbs when it is shredded. -1=it survives

	//Backpacks can never be protected but are annoying as fuck to lose, so they get a lower chance to be shredded
	if(back)
		back.shred(bomb,shock-20,src)

	if(head)
		covered_parts |= head.flags_inv
		head_absorbed = head.shred(bomb,shock,src)
	if(wear_mask)
		var/absorbed = ((covered_parts & HIDEMASK) ? head_absorbed : 0) //Check if clothing covering this part absorbed any of the shock
		if(absorbed >= 0)
			//Masks can be used to shield other parts, but are simplified to simply add their absorbsion to the head armor if it covers the face
			var/mask_absorbed = wear_mask.shred(bomb,shock-absorbed,src)
			if(wear_mask.flags_inv & HIDEFACE)
				covered_parts |= wear_mask.flags_inv
				if(mask_absorbed < 0) //If the mask didn't get shredded, everything else on the head is protected
					head_absorbed = -1
				else
					head_absorbed += mask_absorbed
	if(ears)
		var/absorbed = ((covered_parts & HIDEEARS) ? head_absorbed : 0)
		if(absorbed >= 0)
			ears.shred(bomb,shock-absorbed,src)
	if(glasses)
		var/absorbed = ((covered_parts & HIDEEYES) ? head_absorbed : 0)
		if(absorbed >= 0)
			glasses.shred(bomb,shock-absorbed,src)

	if(wear_suit)
		covered_parts |= wear_suit.flags_inv
		suit_absorbed = wear_suit.shred(bomb,shock,src)
	if(gloves)
		var/absorbed = ((covered_parts & HIDEGLOVES) ? suit_absorbed : 0)
		if(absorbed >= 0)
			gloves.shred(bomb,shock-absorbed,src)
	if(shoes)
		var/absorbed = ((covered_parts & HIDESHOES) ? suit_absorbed : 0)
		if(absorbed >= 0)
			shoes.shred(bomb,shock-absorbed,src)
	if(w_uniform)
		var/absorbed = ((covered_parts & HIDEJUMPSUIT) ? suit_absorbed : 0)
		if(absorbed >= 0)
			w_uniform.shred(bomb,shock-20-absorbed,src)	//Uniforms are also annoying to get shredded

/obj/item/proc/shred(bomb,shock,mob/living/carbon/human/Human)
	if(flags & ABSTRACT)
		return -1

	var/shredded

	if(!bomb)
		if(burn_state != -1)
			shredded = 1 //No heat protection, it burns
		else
			shredded = -1 //Heat protection = Fireproof

	else if(shock > 0)
		if(prob(max(shock-armor["bomb"],0)))
			shredded = armor["bomb"] + 10 //It gets shredded, but it also absorbs the shock the clothes underneath would recieve by this amount
		else
			shredded = -1 //It survives explosion

	if(shredded > 0)
		if(Human) //Unequip if equipped
			Human.unEquip(src)

		if(bomb)
			for(var/obj/item/Item in contents) //Empty out the contents
				Item.loc = src.loc
			spawn(1) //so the shreds aren't instantly deleted by the explosion
				var/obj/effect/decal/cleanable/shreds/Shreds = new(loc)
				Shreds.desc = "The sad remains of what used to be [src.name]."
				qdel(src)
		else
			burn()

	return shredded