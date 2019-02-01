/obj/machinery/antigrav
	name = "antigrav generetor"
	desc = "It temporarily disables gravity around."
	icon_state = "GraviMobile"
	density = 1
	anchored = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10000
	circuit = /obj/item/weapon/circuitboard/autolathe

	var/on = FALSE
	var/image/ball = null
	var/area/area = null

/obj/machinery/antigrav/proc/start()
	area = get_area(src)
	if(area.gravity_blocker && area.gravity_blocker != src)
		src.visible_message(SPAN_NOTICE("\The [src] failed to start."))
		return

	area.gravity_blocker = src
	area.has_gravity = FALSE

	if(!on)
		start_anim()

	on = TRUE
	use_power = 2
	update_icon()

/obj/machinery/antigrav/proc/stop()
	if(area)
		area.gravity_blocker = null
		area.gravitychange(area.cached_gravity, area)
		area = null

	if(on)
		stop_anim()

	on = FALSE
	use_power = 1
	update_icon()

/obj/machinery/antigrav/Process()
	if(stat & NOPOWER || !on)
		stop()
		return


/obj/machinery/antigrav/attack_hand(mob/user)
	if(!on)
		if(anchored)
			start()
		else
			user << SPAN_WARNING("Fasten \the [src] to the floor first.")
	else
		stop()

/obj/machinery/antigrav/attackby(var/obj/item/I, var/mob/user)
	src.add_fingerprint(usr)
	if (I.has_quality(QUALITY_BOLT_TURNING))
		if (anchored)
			if(!on)
				user << SPAN_NOTICE("You begin to unfasten \the [src] from the floor...")
				if (I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_ROB))
					user.visible_message( \
						SPAN_NOTICE("\The [user] unfastens \the [src]."), \
						SPAN_NOTICE("You have unfastened \the [src]. Now it can be pulled somewhere else."), \
						"You hear ratchet.")
					src.anchored = 0
			else
				user << SPAN_WARNING("Turn off \the [src] first.")
		else
			user << SPAN_NOTICE("You begin to fasten \the [src] to the floor...")
			if (I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_ROB))
				user.visible_message( \
					SPAN_NOTICE("\The [user] fastens \the [src]."), \
					SPAN_NOTICE("You have fastened \the [src]. Now it can dispense pipes."), \
					"You hear ratchet.")
				src.anchored = 1
		update_icon()
	else
		return ..()


/obj/machinery/antigrav/proc/start_anim()
	if(ball)
		ball.icon_state = "GraviMobile_working_ball"
	else
		ball = image(icon, icon_state = "GraviMobile_working_ball")
	ball.pixel_y = 32
	ball.layer = src.layer
	ball.plane = src.plane
	ball.loc = src.loc
	world << ball

	flick("GraviMobile_starting", src)
	flick("GraviMobile_starting_ball", ball)

/obj/machinery/antigrav/proc/stop_anim()
	if(ball)
		ball.icon_state = "GraviMobile_none_ball"
	else
		ball = image(icon, icon_state = "GraviMobile_none_ball")
	ball.pixel_y = 32
	ball.layer = src.layer
	ball.plane = src.plane
	ball.loc = src.loc
	world << ball

	flick("GraviMobile_stoping", src)
	flick("GraviMobile_stoping_ball", ball)

/obj/machinery/antigrav/update_icon()
	if(!anchored)
		icon_state = "GraviMobile"
		return

	if(on)
		icon_state = "GraviMobile_working"
	else
		icon_state = "GraviMobile_deploy"
