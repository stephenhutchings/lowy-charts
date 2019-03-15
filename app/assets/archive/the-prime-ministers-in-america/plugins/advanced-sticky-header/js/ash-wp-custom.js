var ash_wp_header_class = ash_wp_localized_vars.header_class;

var ash_wp_header_animate = ash_wp_localized_vars.animate;
if(ash_wp_header_animate !== '') {
	var ash_wp_animate = ash_wp_header_animate === '1' ? true : false;
} else {
	var ash_wp_animate = true;
}

var ash_wp_header_animation_type = ash_wp_localized_vars.transitionStyle;
if(ash_wp_header_animation_type !== '') {
	var ash_wp_animation_type = ash_wp_header_animation_type === '0' ? 'fade' : 'slide';
} else {
	var ash_wp_animation_type = 'fade';
}


var ash_wp_header_shadow = ash_wp_localized_vars.shadow;
var ash_wp_shadow = ash_wp_header_shadow === '1' ? true : false;

var ash_wp_header_sticky_already = ash_wp_localized_vars.stickyAlready;
var ash_wp_sitcky_already = ash_wp_header_sticky_already === '1' ? true : false;



var ash_wp_header_full_width = ash_wp_localized_vars.fullWidth;
var ash_wp_full_width = ash_wp_header_full_width === '1' ? true : false;

$ash_j=jQuery.noConflict();


$ash_j(document).ready(function(){

	if(ash_wp_header_class !== '') {

		if($ash_j('.' + ash_wp_header_class).length > 0) {

			$ash_j('.' + ash_wp_header_class).stickMe({
				animate: ash_wp_animate,
				shadow: ash_wp_shadow,
				transitionStyle: ash_wp_animation_type,
				stickyAlready: ash_wp_sitcky_already,
				fullWidth: ash_wp_full_width
			});

		}

		else {
			console.warn('Advanced sticky header was unable to find element with class: ' + ash_wp_header_class);
		}

	}

});