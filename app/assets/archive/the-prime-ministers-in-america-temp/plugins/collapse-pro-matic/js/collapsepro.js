/*!
 * Collapse-Pro-Matic v1.5.9
 * http://plugins.twinpictures.de/premium-plugins/collapse-pro-matic/
 *
 * Copyright 2016, Twinpictures
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, blend, trade,
 * bake, hack, scramble, difiburlate, digest and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

function setCookie (cookieName, cookieValue, cookieExpire) {
	wbarDate = new Date();
	wbarDate.setTime(wbarDate.getTime() + cookieExpire);
	wbarExpireDate = wbarDate.toUTCString();
	document.cookie=cookieName + '=' + cookieValue + '; expires='+ wbarDate.toUTCString() +'; path=/';
}

function readCookie(cookieName){
	var results = document.cookie.match(cookieName + '=(.*?)(;|$)')
	if(results){
		return(results[1])
	    }
	else {return null}
}

function collapse_init() {
	//force collapse
	jQuery('.force_content_collapse').each(function(index) {
		jQuery(this).css('display', 'none');
	});

	//inital collapse
	jQuery('.collapseomatic:not(.colomat-close)').each(function(index) {
		var thisid = jQuery(this).attr('id');
		//check for lockheight
		if ( jQuery('[id^=lockheight][id$='+thisid+']').length ) {
			//check for swaptarget
			if ( jQuery('[id^=swaptarget][id$='+thisid+']').length ) {
				//which one is larger?
				var fix_height = Math.max( jQuery('[id^=target][id$='+thisid+']').outerHeight(), jQuery('[id^=swaptarget][id$='+thisid+']').outerHeight() );
			}
			else{
				var fix_height = jQuery('[id^=target][id$='+thisid+']').outerHeight();
			}
			jQuery('[id^=lockheight][id$='+thisid+']').css('height', fix_height);
		}

		//check for cookies
		if(jQuery(this).attr('cookie') || jQuery(this).attr('gcookie')){
			var cookie = readCookie( jQuery(this).attr('gcookie') );
			//if no global cookie, use local
			if (!cookie) {
				cookie = readCookie( jQuery(this).attr('cookie') );
			}
			//if the cookie has been set, mark the item as visited
			if(cookie){
				jQuery(this).addClass('colomat-visited');
			}
			//if the expand element was left open
			if(cookie == 'open'){
				//console.log('keep the collapse open');
				jQuery(this).addClass('colomat-close');
				//remove maptastic if exists
				jQuery('[id^=target][id$='+thisid+']').removeClass('maptastic');
				return;
			}
		}
		//record height
		//jQuery('[id^=target][id$='+thisid+']').data("finalHeight",jQuery('[id^=target][id$='+thisid+']').css('height'));

		//hide the element
		jQuery('[id^=target][id$='+thisid+']').css('display', 'none');
	});

	//inital swaptitle for pre-expanded elements
	jQuery('.collapseomatic.colomat-close').each(function(index) {
		var thisid = jQuery(this).attr('id');
		//check for cookies
		if(jQuery(this).attr('cookie')){
			var cookie = readCookie( jQuery(this).attr('cookie') );
			if(cookie == 'closed'){
				//console.log('close the cookie even though it is default open');
				jQuery(this).removeClass('colomat-close');
				jQuery('[id^=target][id$='+thisid+']').css('display', 'none');
				return;
			}
		}

		if(jQuery("#swap-"+thisid).length > 0){
			swapTitle(this, "#swap-"+thisid);
		}
		if(jQuery("#swapexcerpt-"+thisid).length > 0){
			swapTitle("#excerpt-"+thisid, "#swapexcerpt-"+thisid);
		}
	});
}

function swapTitle(origObj, swapObj){
	if(jQuery(origObj).prop("tagName") == 'IMG'){
		var origsrc = jQuery(origObj).prop('src');
		var swapsrc = jQuery(swapObj).prop('src');

		jQuery(origObj).prop('src',swapsrc);
		jQuery(swapObj).prop('src',origsrc);

		if( jQuery(swapObj).prop('alt') ){
			var origalt = jQuery(origObj).prop('alt');
			var swapalt = jQuery(swapObj).prop('alt');

			jQuery(origObj).prop({'alt': swapalt, 'title': swapalt});
			jQuery(swapObj).prop('alt', origalt);
		}
	}
	else{
		var orightml = jQuery(origObj).html();
		var swaphtml = jQuery(swapObj).html();
		jQuery(origObj).html(swaphtml);
		jQuery(swapObj).html(orightml);

		//swap out the title if swapalt, if set
		if (jQuery(swapObj).attr('title')) {
			var origalt = jQuery(origObj).attr('title');
			var swapalt = jQuery(swapObj).attr('title');
			jQuery(origObj).attr({
				title: swapalt
			});
			jQuery(swapObj).attr('title', origalt);
		}

		//is cufon involved? if so, do that thing
		if(swaphtml.indexOf("<cufon") != -1){
			var trigelem = jQuery(this).get(0).tagName;
			Cufon.replace(trigelem);
		}
	}
}

function toggleState (obj, id, trig_id) {

	if (jQuery('[id^=target][id$='+id+']').hasClass('maptastic') ) {
		jQuery('[id^=target][id$='+id+']').removeClass('maptastic');
	}

	//pre-callback so precalls?
	//before collapse
	if (jQuery('[id^=target][id$='+id+']').is(':visible') ) {
		if ( typeof pre_collapse_callback != 'undefined' ) {
			pre_collapse_callback();
		}
	}
	//before expand
	else{
		if ( typeof pre_expand_callback != 'undefined' ) {
			pre_expand_callback();
		}
	}
	//both
	if ( typeof pre_colomat_callback != 'undefined' ) {
			pre_colomat_callback();
	}

	colslideEffect = colomatslideEffect;
	if (obj.attr('data-animation-effect')) {
		colslideEffect = obj.attr('data-animation-effect');
	}

	colduration = colomatduration;
	if (obj.attr('data-duration')) {
		colduration = obj.attr('data-duration');
	}

	//if colduration is a number, make it a intiger
	if( isFinite(colduration) ){
		colduration = parseFloat(colduration);
	}

	coldirection = colomatdirection;
	if (obj.attr('data-direction')) {
		coldirection = obj.attr('data-direction');
	}

	coldistance = '';
	if (obj.attr('data-distance')) {
		coldistance = obj.attr('data-distance');
	}

	//slideToggle
	if(colslideEffect == 'slideToggle'){
		jQuery('[id^=target][id$='+id+']').slideToggle(colduration, function() {
			// Animation complete.

			if( jQuery(this).hasClass('colomat-inline') && jQuery(this).is(':visible') ){
				jQuery(this).css('display', 'inline');
			}

			//callbacks
			//expand
			if (jQuery(this).is(':visible') ) {
				if ( typeof expand_callback != 'undefined' ) {
					expand_callback();
				}
			}
			//collapse
			else{
				if ( typeof collapse_callback != 'undefined' ) {
					collapse_callback();
				}
			}
			//both
			if ( typeof colomat_callback != 'undefined' ) {
					colomat_callback();
			}

			var offset_top;
			//deal with any findme links
			if(trig_id && jQuery('#'+trig_id).is('.find-me.colomat-close')){
				//offset_top = jQuery('#find-'+trig_id).attr('name');
				offset_top = jQuery('#'+trig_id).attr('data-findme');

				if(!offset_top || offset_top == 'auto'){
					target_offset = jQuery('#'+trig_id).offset();
					offset_top = target_offset.top;
				}
			}

			//deal with any scroll to links
			else if(jQuery('#'+trig_id + ':not(.colomat-close)').is('.scroll-to-trigger')){
				offset_top = jQuery('#scrollonclose-'+trig_id).attr('name');
				if (!offset_top || offset_top == 'auto') {
					var target_offset = jQuery('#scrollonclose-'+trig_id).offset();
					offset_top = target_offset.top;
				}
			}

			if ( offset_top ) {
				//offset
				if( jQuery('#'+trig_id).attr('data-offset') ) {
					offset_top = parseFloat ( offset_top + parseFloat( jQuery('#'+trig_id).attr('data-offset') ) );
				}
				//console.log(offset_top);
				jQuery('html, body').animate({scrollTop:offset_top}, 500);
			}
		});

		jQuery('[id^=swaptarget][id$='+id+']').slideToggle(colduration, function() {
			// Animation complete.
		});
	}
	//slideFade
	else if(colslideEffect == 'slideFade'){
		//console.log('orginal height was: ' + jQuery('[id^=target][id$='+id+']').data("finalHeight"));
		jQuery('[id^=target][id$='+id+']').animate({
			height: "toggle",
			opacity: "toggle"
		}, colduration, function (){
			//Animation complete
			if( jQuery(this).hasClass('colomat-inline') && jQuery(this).is(':visible') ){
				jQuery(this).css('display', 'inline');
			}

			//callbacks
			//expand
			if (jQuery(this).is(':visible') ) {
				if ( typeof expand_callback != 'undefined' ) {
					expand_callback();
				}
			}
			//collapse
			else{
				if ( typeof collapse_callback != 'undefined' ) {
					collapse_callback();
				}
			}
			//both
			if ( typeof colomat_callback != 'undefined' ) {
					colomat_callback();
			}

			var offset_top;
			//deal with any findme links
			if(trig_id && jQuery('#'+trig_id).is('.find-me.colomat-close')){
				//offset_top = jQuery('#find-'+trig_id).attr('name');
				offset_top = jQuery('#'+trig_id).attr('data-findme');
				if(!offset_top || offset_top == 'auto'){
					target_offset = jQuery('#'+trig_id).offset();
					offset_top = target_offset.top;
				}
			}

			//deal with any scroll to links
			else if(jQuery('#'+trig_id + ':not(.colomat-close)').is('.scroll-to-trigger')){
				offset_top = jQuery('#scrollonclose-'+trig_id).attr('name');
				if (!offset_top || offset_top == 'auto') {
					var target_offset = jQuery('#scrollonclose-'+trig_id).offset();
					offset_top = target_offset.top;
				}
			}

			if ( offset_top ) {
				//offset
				if( jQuery('#'+trig_id).attr('data-offset') ) {
					offset_top = parseFloat ( offset_top + parseFloat( jQuery('#'+trig_id).attr('data-offset') ) );
				}
				//console.log(offset_top);
				jQuery('html, body').animate({scrollTop:offset_top}, 500);
			}

		});

		jQuery('[id^=swaptarget][id$='+id+']').animate({
			height: "toggle",
			opacity: "toggle"
		}, colduration, function (){
			//Animation complete
		});
	}
	else if(colslideEffect == 'toggle'){
		//slide
		jQuery('[id^=target][id$='+id+']').toggle( 'slide', {
			direction: coldirection,
			distance: coldistance,
		}, function(){
			// Animation complete.
			if( jQuery(this).hasClass('colomat-inline') && jQuery(this).is(':visible') ){
				jQuery(this).css('display', 'inline');
			}

			//callbacks
			//expand
			if (jQuery(this).is(':visible') ) {
				if ( typeof expand_callback != 'undefined' ) {
					expand_callback();
				}
			}
			//collapse
			else{
				if ( typeof collapse_callback != 'undefined' ) {
					collapse_callback();
				}
			}
			//both
			if ( typeof colomat_callback != 'undefined' ) {
					colomat_callback();
			}

			var offset_top;

			//deal with any findme links
			if(trig_id && jQuery('#'+trig_id).is('.find-me.colomat-close')){
				//offset_top = jQuery('#find-'+trig_id).attr('name');
				offset_top = jQuery('#'+trig_id).attr('data-findme');
				if(!offset_top || offset_top == 'auto'){
					target_offset = jQuery('#'+trig_id).offset();
					offset_top = target_offset.top;
				}
			}

			//deal with any scroll to links
			else if(jQuery('#'+trig_id + ':not(.colomat-close)').is('.scroll-to-trigger')){
				offset_top = jQuery('#scrollonclose-'+trig_id).attr('name');
				if (!offset_top || offset_top == 'auto') {
					var target_offset = jQuery('#scrollonclose-'+trig_id).offset();
					offset_top = target_offset.top;
				}
			}

			if ( offset_top ) {
				//offset
				if( jQuery('#'+trig_id).attr('data-offset') ) {
					offset_top = parseFloat( offset_top + parseFloat( jQuery('#'+trig_id).attr('data-offset') ) );
				}

				//console.log(offset_top);
				jQuery('html, body').animate({scrollTop:offset_top}, 500);
			}
		});

		jQuery('[id^=swaptarget][id$='+id+']').toggle( 'slide', {
			direction: coldirection
		}, function(){

		});
	}

	//deal with google maps builder resize
	if(jQuery('#'+id).hasClass('colomat-close')){
		jQuery('.google-maps-builder').each(function(index) {
			map = jQuery(".google-maps-builder")[index];
			google.maps.event.trigger(map, 'resize');
		});
	}

}

function closeOtherGroups(rel){
	jQuery('.collapseomatic[rel!="' + rel +'"]').each(function(index) {
		//add close class if open
		if(jQuery(this).hasClass('colomat-expand-only') && jQuery(this).hasClass('colomat-close')){
			return;
		}
		if(jQuery(this).hasClass('colomat-close') && jQuery(this).attr('rel') !== undefined){
			jQuery(this).removeClass('colomat-close');
			var id = jQuery(this).attr('id');
			//remove parent highlight class
			jQuery('#parent-'+id).removeClass('colomat-parent-highlight');

			//check if the title needs to be swapped out
			if(jQuery("#swap-"+id).length > 0){
				swapTitle(this, "#swap-"+id);
			}

			//check if the excerpt needs to be swapped out
			if(jQuery("#swapexcerpt-"+id).length > 0){
				swapTitle("#exerpt-"+id, "#swapexcerpt-"+id);
			}

			toggleState(jQuery(this), id, false);

			//check if there are nested children that need to be collapsed
			var ancestors = jQuery('.collapseomatic', '#target-'+id);
			ancestors.each(function(index) {
				jQuery(this).removeClass('colomat-close');
				var thisid = jQuery(this).attr('id');
				jQuery('#target-'+thisid).css('display', 'none');
			})
		}
	});
}

function closeOtherMembers(rel, id){
	jQuery('[rel="' + rel +'"], .' + rel ).each(function(index) {
		//assign highlander status classes
		if( !jQuery('#' + id).hasClass( 'colomat-close' ) || jQuery(this).attr('id') == id){
			jQuery(this).removeClass( rel + '_closed' );
		}
		else{
			jQuery(this).addClass( rel + '_closed' );
		}

		if(jQuery(this).hasClass('colomat-expand-only') && jQuery(this).hasClass('colomat-close')){
			return;
		}

		//add close class if open
		if(jQuery(this).attr('id') != id && jQuery(this).hasClass('colomat-close') && jQuery(this).attr('rel') !== undefined){
			//collapse the element
			jQuery(this).removeClass('colomat-close');

			var thisid = jQuery(this).attr('id');
			//remove parent highlight class
			jQuery('#parent-'+thisid).removeClass('colomat-parent-highlight');

			//deal with cookies
			if(jQuery(this).attr('cookie')){
				status = 'closed';
				expires = colomatcookielife * 86400000;
				setCookie( jQuery(this).attr('cookie') , status, expires);
			}

			//check if the title needs to be swapped out
			if(jQuery("#swap-"+thisid).length > 0){
				swapTitle(this, "#swap-"+thisid);
			}

			//check if the excerpt needs to be swapped out
			if(jQuery("#swapexcerpt-"+thisid).length > 0){
				swapTitle("#excerpt-"+thisid, "#swapexcerpt-"+thisid);
			}

			//check for snap-shut
			if(!jQuery(this).hasClass('colomat-close') && jQuery(this).hasClass('snap-shut')){
				jQuery('#target-'+thisid).hide();
			}

			else {
				toggleState(jQuery(this), thisid, false);
			}

			//check if there are nested children that need to be collapsed
			//var ancestors = jQuery('.collapseomatic', '#target-'+id);
			var ancestors = jQuery('.collapseomatic', '#target-'+thisid);
			ancestors.each(function(index) {

				if(jQuery(this).hasClass('colomat-expand-only') && jQuery(this).hasClass('colomat-close')){
					return;
				}
				//deal with extra tirggers
				var pre_id = id.split('-');
				if (pre_id[0].indexOf('extra') != '-1') {
					//console.log('this is an extra trigger');
					pre = pre_id.splice(0, 1);
					id = pre_id.join('-');

					//deal with must-be-one
					if(jQuery('#'+id).hasClass('must-be-one')){
						console.log('nope');
						return;
					}

					//deal with any scroll to links from the Title Trigger
					if(jQuery('#'+id).hasClass('scroll-to-trigger')){
						offset_top = jQuery('#scrollonclose-'+id).attr('name');
						if (!offset_top || offset_top == 'auto') {
							var target_offset = jQuery('#'+id).offset();
							//var target_offset = jQuery('#scrollonclose-'+id).offset();
							offset_top = target_offset.top;
						}
					}

					if( jQuery('#'+trig_id).attr('data-offset') ) {
						offset_top = offset_top + parseFloat( jQuery('#'+trig_id).attr('data-offset') );
					}

					//toggle master trigger arrow
					jQuery('#'+id).toggleClass('colomat-close');

					//toggle any other extra trigger arrows
					jQuery('[id^=extra][id$='+id+']').toggleClass('colomat-close');
				}

				if(jQuery(this).attr('id').indexOf('bot-') == '-1'){
					jQuery(this).removeClass('colomat-close');
					var thisid = jQuery(this).attr('id');
					//check if the title needs to be swapped out
					if(jQuery("#swap-"+thisid).length > 0){
						swapTitle(this, "#swap-"+thisid);
					}
					//check if the excerpt needs to be swapped out
					if(jQuery("#swapexcerpt-"+thisid).length > 0){
						swapTitle("#excerpt-"+thisid, "#swapexcerpt-"+thisid);
					}
					jQuery('#target-'+thisid).css('display', 'none');
				}
			})
		}
	});

}

function colomat_expandall(loop_items){
	if (typeof loop_items == 'undefined') {
		loop_items = jQuery('.collapseomatic.colomat-close');
	}
	loop_items.each(function(index) {
		if(jQuery(this).hasClass('colomat-expand-only') && jQuery(this).hasClass('colomat-close')){
			return;
		}

		jQuery(this).addClass('colomat-close');
		var thisid = jQuery(this).attr('id');
		jQuery('#parent-'+thisid).removeClass('colomat-parent-highlight');

		if(jQuery("#swap-"+thisid).length > 0){
			swapTitle(this, "#swap-"+thisid);
		}

		if(jQuery("#swapexcerpt-"+thisid).length > 0){
			swapTitle("#excerpt-"+thisid, "#swapexcerpt-"+thisid);
		}

		toggleState(jQuery(this), thisid, false);

	});
}

function colomat_collapseall(loop_items){
	if (!loop_items) {
		loop_items  = jQuery('.collapseomatic.colomat-close');
	}
	loop_items.each(function(index) {
		if(jQuery(this).hasClass('colomat-expand-only') && jQuery(this).hasClass('colomat-close')){
			return;
		}

		jQuery(this).removeClass('colomat-close');
		var thisid = jQuery(this).attr('id');
		jQuery('#parent-'+thisid).removeClass('colomat-parent-highlight');

		if(jQuery("#swap-"+thisid).length > 0){
			swapTitle(this, "#swap-"+thisid);
		}

		if(jQuery("#swapexcerpt-"+thisid).length > 0){
			swapTitle("#excerpt-"+thisid, "#swapexcerpt-"+thisid);
		}

		toggleState(jQuery(this), thisid, false);

	});
}

jQuery(document).ready(function() {
	collapse_init();

	//Display the collapse wrapper... use to reverse the show-all on no JavaScript degredation.
	jQuery('.content_collapse_wrapper').each(function(index) {
		jQuery(this).css('display', 'inline');
	});

	jQuery(document).on({
		mouseenter: function(){
			//stuff to do on mouseover
			jQuery(this).addClass('colomat-hover');
		},
		mouseleave: function(){
			//stuff to do on mouseleave
			jQuery(this).removeClass('colomat-hover');
		},
		focusin: function(){
			//stuff to do on keyboard focus
			jQuery(this).addClass('colomat-hover');
		},
		focusout: function(){
			//stuff to do on losing keyboard focus
			jQuery(this).removeClass('colomat-hover');
 		}
	}, '.collapseomatic'); //pass the element as an argument to .on

	//tabindex enter
	jQuery(document).on('keypress','.collapseomatic', function(event) {
		if (event.which == 13) {
			event.currentTarget.click();
		};
	});

	//the main collapse/expand function
	jQuery(document).on('click', '.collapseomatic', function(event) {
		var offset_top;

		if(jQuery(this).hasClass('colomat-expand-only') && jQuery(this).hasClass('colomat-close')){
			return;
		}

		//highlander must be one
		if(jQuery(this).attr('rel') && jQuery(this).attr('rel').indexOf('-highlander') != '-1' && jQuery(this).hasClass('must-be-one') && jQuery(this).hasClass('colomat-close')){
			return;
		}

		//deal with cookies
		if(jQuery(this).attr('cookie')){
			status = 'open';
			if(jQuery(this).hasClass('colomat-close')){
				status = 'closed';
			}
			expires = colomatcookielife * 86400000;
			setCookie( jQuery(this).attr('cookie') , status, expires);
		}

		var id = jQuery(this).attr('id');

		//external class triggers
		if(jQuery(this).hasClass('colomatclasstrigger')){
			var classList = jQuery(this).attr('class').split(/\s+/);
			var class_arr = null;
			for (i = 0; i < classList.length; i++) {
				if(classList[i].length > 0 && classList[i].indexOf('colomatid-') != '-1'){
					class_arr = classList[i].split('-');
					pre_id = class_arr.splice(0, 1);
					id = class_arr.join('-');
				}
			}
		}


		//deal with extra tirggers
		var pre_id = id.split('-');
		if (pre_id[0].indexOf('extra') != '-1') {
			//console.log('this is an extra trigger');
			pre = pre_id.splice(0, 1);
			id = pre_id.join('-');

			//deal with any scroll to links from the Extra Collapse Trigger
			if(jQuery(this).hasClass('scroll-to-trigger')){
				var target_offset = jQuery('#'+id).offset();
				offset_top = target_offset.top;
			}

			//deal with any scroll to links from the Title Trigger
			if(jQuery('#'+id).hasClass('scroll-to-trigger')){
				offset_top = jQuery('#scrollonclose-'+id).attr('name');
				if (offset_top == 'auto') {
					var target_offset = jQuery('#'+id).offset();
					offset_top = target_offset.top;
				}
			}

			//toggle master trigger arrow
			jQuery('#'+id).toggleClass('colomat-close');

			//toggle any other extra trigger arrows
			jQuery('[id^=extra][id$='+id+']').toggleClass('colomat-close');
		}

		//deal with bot triggers
		else if(id.indexOf('bot-') != '-1'){
			id = id.substr(4);
			jQuery('#'+id).toggleClass('colomat-close');

			//deal with any scroll to links from the Internal Collapse Trigger
			if(jQuery(this).hasClass('scroll-to-trigger')){
				var target_offset = jQuery('#'+id).offset();
				offset_top = target_offset.top;
				//console.log(jQuery(this).attr('id') + ' has scroll-to-trigger with offset of: ' + offset_top);
			}

			//deal with any scroll to links from the Title Trigger
			if(jQuery('#'+id).hasClass('scroll-to-trigger')){
				offset_top = jQuery('#scrollonclose-'+id).attr('name');
				if (offset_top == 'auto') {
					var target_offset = jQuery('#'+id).offset();
					offset_top = target_offset.top;
				}
				//console.log(id + ' has scroll-to-trigger offset of: ' + offset_top)
			}

			//deal with cookie (otherwise the element thinks it's still open)
			if(jQuery('#'+id).attr('cookie')){
				status = 'closed';
				expires = colomatcookielife * 86400000;
				setCookie( jQuery('#'+id).attr('cookie') , status, expires);
			}
		}
		else{
			jQuery(this).toggleClass('colomat-close');
			//toggle any extra triggers
			jQuery('[id^=extra][id$='+id+']').toggleClass('colomat-close');
		}

		//check if the title needs to be swapped out
		if(jQuery("#swap-"+id).length > 0){
			swapTitle(jQuery('#'+id), "#swap-"+id);
		}

		//check if the excerpt needs to be swapped out
		if(jQuery("#swapexcerpt-"+id).length > 0){
			swapTitle("#excerpt-"+id, "#swapexcerpt-"+id);
		}

		//add visited class
		jQuery(this).addClass('colomat-visited');

		//toggle parent highlight class
		var parentID = 'parent-'+id;
		jQuery('#' + parentID).toggleClass('colomat-parent-highlight');

		trig_arr = jQuery(this).attr('id').split('-');
		targ = trig_arr.splice(0, 1);
		trig_id = trig_arr.join('-');
		if (!trig_id) {
			trig_id = id;
		}

		//check for snap-shut
		if(!jQuery(this).hasClass('colomat-close') && jQuery(this).hasClass('snap-shut')){
			jQuery('[id^=target][id$='+id+']').hide();
		}
		else {
			toggleState(jQuery(this), id, trig_id);
		}

		//deal with rel and highlander grouped items
		if(jQuery(this).attr('rel') !== undefined){
			var rel = jQuery(this).attr('rel');
			//other groups
			if(rel.indexOf('-highlander') != '-1'){
				closeOtherMembers(rel, id);
			}
			else{
				closeOtherGroups(rel);
			}
			//toggle expand/collapse .setall
			if ( jQuery('.setall[rel="' + rel +'"]').length ) {
				//console.log('we hae a set all for group ' + rel);
				//loop through all but the .setall element, if they all have the same status as this, flip the toggle.
				var master_item = jQuery(this).hasClass('colomat-close');
				//console.log ('check against ' + master_item);
				var all_the_same = true;
				jQuery('.collapseomatic:not(.setall)[rel="' + rel +'"]').each(function(index) {
					//console.log (index + ' is ' + jQuery(this).hasClass('colomat-close') );
					if (master_item != jQuery(this).hasClass('colomat-close') ) {
						all_the_same = false;
					}
				});
				if ( all_the_same ) {
					//console.log('all items are ' + master_item);
					if (master_item != jQuery('.setall[rel="' + rel +'"]').hasClass('colomat-close')) {
						//console.log('toggle setall toggle to ' + master_item);
						var toggleID = jQuery('.setall[rel="' + rel +'"]').attr('id');
						if ( master_item ) {
							jQuery('#'+toggleID).addClass('colomat-close');
							jQuery('#parent-'+toggleID).addClass('colomat-parent-highlight');
						}
						else {
							jQuery('#'+toggleID).removeClass('colomat-close');
							jQuery('#parent-'+toggleID).removeClass('colomat-parent-highlight');

						}

						if(jQuery("#swap-"+toggleID).length > 0){
							swapTitle("#"+toggleID, "#swap-"+toggleID);
						}

						if(jQuery("#swapexcerpt-"+toggleID).length > 0){
							swapTitle("#excerpt-"+toggleID, "#swapexcerpt-"+toggleID);
						}
					}

				}
			}
		}

		//deal with togglegroup items
		if(jQuery(this).attr('data-togglegroup') !== undefined){
			var toggroup = jQuery(this).attr('data-togglegroup');

			//toggle expand/collapse .setall
			if ( jQuery('.setall[data-togglegroup="' + toggroup +'"]').length ) {
				var master_item = jQuery(this).hasClass('colomat-close');
				var all_the_same = true;
				jQuery('.collapseomatic:not(.setall)[data-togglegroup="' + toggroup +'"]').each(function(index) {
					if (master_item != jQuery(this).hasClass('colomat-close') ) {
						all_the_same = false;
					}
				});
				if ( all_the_same ) {
					if (master_item != jQuery('.setall[data-togglegroup="' + toggroup +'"]').hasClass('colomat-close')) {
						//console.log('toggle setall toggle to ' + master_item);
						var toggleID = jQuery('.setall[data-togglegroup="' + toggroup +'"]').attr('id');
						if ( master_item ) {
							jQuery('#'+toggleID).addClass('colomat-close');
							jQuery('#parent-'+toggleID).addClass('colomat-parent-highlight');
						}
						else {
							jQuery('#'+toggleID).removeClass('colomat-close');
							jQuery('#parent-'+toggleID).removeClass('colomat-parent-highlight');

						}

						if(jQuery("#swap-"+toggleID).length > 0){
							swapTitle("#"+toggleID, "#swap-"+toggleID);
						}

						if(jQuery("#swapexcerpt-"+toggleID).length > 0){
							swapTitle("#excerpt-"+toggleID, "#swapexcerpt-"+toggleID);
						}
					}

				}
			}
		}

		if(offset_top){
			//offset
			/*
			if ( jQuery('#find-'+id).length ) {
				offset_top = offset_top + parseFloat( jQuery('#find-'+id).attr('data-offset') );
			}
			*/
			if( jQuery('#'+trig_id).attr('data-offset') ) {
				offset_top = parseFloat( offset_top + parseFloat( jQuery('#'+trig_id).attr('data-offset') ) );
			}

			//console.log('moving with an offset of: ' + offset_top);
			jQuery('html, body').animate({scrollTop:offset_top}, 500);
		}

	});

	//jQuery('.expandall').on('click', function(event) {
	jQuery(document).on('click', '.expandall', function(event) {
		if(jQuery(this).attr('rel') !== undefined){
			var rel = jQuery(this).attr('rel');
			var loop_items = jQuery('.collapseomatic:not(.colomat-close)[rel="' + rel +'"]');
		}
		else if(jQuery(this).attr('data-togglegroup') !== undefined){
			var toggroup = jQuery(this).attr('data-togglegroup');
			var loop_items = jQuery('.collapseomatic:not(.colomat-close)[data-togglegroup="' + toggroup +'"]');
		}
		else{
			var loop_items = jQuery('.collapseomatic:not(.colomat-close)');
		}
		colomat_expandall(loop_items);
	});

	//jQuery('.collapseall').on('click', function(event) {
	jQuery(document).on('click', '.collapseall', function(event) {
		if(jQuery(this).attr('rel') !== undefined){
			var rel = jQuery(this).attr('rel');
			var loop_items = jQuery('.collapseomatic.colomat-close[rel="' + rel +'"]');
		}
		else if(jQuery(this).attr('data-togglegroup') !== undefined){
			var toggroup = jQuery(this).attr('data-togglegroup');
			var loop_items = jQuery('.collapseomatic.colomat-close[data-togglegroup="' + toggroup +'"]');
		}
		else {
			var loop_items = jQuery('.collapseomatic.colomat-close');
		}
		colomat_collapseall(loop_items);
	});

	jQuery(document).on('click', '.setall', function(event) {
		var toggle_state = '';
		if(jQuery(this).attr('rel') !== undefined){
			var rel = jQuery(this).attr('rel');

			if(jQuery(this).hasClass('colomat-close')){
				var loop_items = jQuery('.collapseomatic[rel="' + rel +'"]:not(.colomat-close)');
			}
			else{
				var loop_items = jQuery('.collapseomatic.colomat-close[rel="' + rel +'"]');
				var toggle_state = 'close';
			}
		}
		else if(jQuery(this).attr('data-togglegroup') !== undefined){
			var toggroup = jQuery(this).attr('data-togglegroup');
			if(jQuery(this).hasClass('colomat-close')){
				var loop_items = jQuery('.collapseomatic[data-togglegroup="' + toggroup +'"]:not(.colomat-close)');
			}
			else{
				var loop_items = jQuery('.collapseomatic.colomat-close[data-togglegroup="' + toggroup +'"]');
				var toggle_state = 'close';
			}
		}
		else {
			if(jQuery(this).hasClass('colomat-close')){
				var loop_items = jQuery('.collapseomatic:not(.colomat-close)');
			}
			else{
				var loop_items = jQuery('.collapseomatic.colomat-close');
				var toggle_state = 'close';
			}
		}
		loop_items.each(function(index) {
			var thisid = jQuery(this).attr('id');
			if(toggle_state == 'close'){
				jQuery(this).removeClass('colomat-close');
				jQuery('#parent-'+thisid).removeClass('colomat-parent-highlight');
			}
			else{
				jQuery(this).addClass('colomat-close');
				jQuery('#parent-'+thisid).addClass('colomat-parent-highlight');
			}

			if(jQuery("#swap-"+thisid).length > 0){
				swapTitle(this, "#swap-"+thisid);
			}

			if(jQuery("#swapexcerpt-"+thisid).length > 0){
				swapTitle("#excerpt-"+thisid, "#swapexcerpt-"+thisid);
			}

			toggleState(jQuery(this), thisid, false);
		});
	});

	//handle new page loads with anchor
	var fullurl = document.location.toString();
	// the URL contains an anchor, but not a hash-bang (#!)
	if (fullurl.match('#(?!\!)')) {
		//console.log('hey dude, something is happeing... you might want to take a look');
		// click the navigation item corresponding to the anchor
		var anchor_arr = fullurl.split(/#(?!\!)/);
		if(anchor_arr.length > 1){
			junk = anchor_arr.splice(0, 1);
			anchor = anchor_arr.join('#');
		}
		else{
			anchor = anchor_arr[0];
		}

		//if the element exists
		if( jQuery('#' + anchor).length ){

			//expand any nested parents
			jQuery('#' + anchor).parents('.collapseomatic_content').each(function(index) {
				parent_arr = jQuery(this).attr('id').split('-');
				junk = parent_arr.splice(0, 1);
				parent = parent_arr.join('-');
				jQuery('#' + parent).click();
			})

			//if the element isn't already expanded, expand it
			if(!jQuery('#' + anchor).hasClass('colomat-close')){
				jQuery('#' + anchor).click();
			}

			if(typeof colomatoffset !== 'undefined'){
				var anchor_offset = jQuery('#' + anchor).offset();
				colomatoffset = colomatoffset + anchor_offset.top;
				jQuery('html, body').animate({scrollTop:colomatoffset}, 50);
			}
		}
	}

	//handle anchor links within the same page
	jQuery(document).on('click', 'a.expandanchor', function(event) {
		//event.preventDefault();
		var fullurl = jQuery(this).attr('href');
		// the URL contains an anchor but not a hash-bang
		if (fullurl.match('#(?!\!)')) {
			// click the navigation item corresponding to the anchor
			var anchor_arr = fullurl.split(/#(?!\!)/);

			if(anchor_arr.length > 1){
				junk = anchor_arr.splice(0, 1);
				anchor = anchor_arr.join('#');
			}
			else{
				anchor = anchor_arr[0];
			}

			if( jQuery('#' + anchor).length ){

				//expand any nested parents
				jQuery('#' + anchor).parents('.collapseomatic_content').each(function(index) {
					parent_arr = jQuery(this).attr('id').split('-');
					junk = parent_arr.splice(0, 1);
					parent = parent_arr.join('-');
					if(!jQuery('#' + parent).hasClass('colomat-close')){
						jQuery('#' + parent).click();
					}
				})

				if(!jQuery('#' + anchor).hasClass('colomat-close')){
					jQuery('#' + anchor).click();
				}
			}
		}
	});

	//jQuery('a.colomat-nolink').on('click', function(event) {
	jQuery(document).on('click', 'a.colomat-nolink', function(event) {
		event.preventDefault();
	});

	//external trigger maping
	jQuery(document).on('click', '.colomat_trigger', function(event) {
		var parent_trigger = jQuery('[data-external-trigger*="' + jQuery(this).attr('id') + '"]');
		//expand only
		if( jQuery(this).hasClass('colomat_expand_only') && !parent_trigger.hasClass('colomat-close') ){
			parent_trigger.trigger( "click" );
		}
		//collapse only
		else if( jQuery(this).hasClass('colomat_collapse_only') && parent_trigger.hasClass('colomat-close') ){
			parent_trigger.trigger( "click" );
		}
		//normal trigger
		else if( !jQuery(this).hasClass('colomat_expand_only') && !jQuery(this).hasClass('colomat_collapse_only') ){
			parent_trigger.trigger( "click" );
		}

	});
});
