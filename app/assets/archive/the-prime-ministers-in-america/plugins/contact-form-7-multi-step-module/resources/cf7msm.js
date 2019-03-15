var cf7msm_ls;
jQuery(document).ready(function($) {
	var posted_data = cf7msm_posted_data;
	if ( cf7msm_hasLs() ) {
		cf7msm_ls = localStorage.getObject( 'cf7msm' );

		var step_field = $("input[name='step']");
		//multi step forms
		if (cf7msm_ls != null && step_field.length > 0) {
			var cf7_form = $(step_field[0].form);
			$.each(cf7msm_ls, function(key, val){
				if (key == 'cf7msm_prev_urls') {
					cf7_form.find('.wpcf7-back, .wpcf7-previous').click(function(e) {
						window.location.href = val[step_field.val()];
						e.preventDefault();
					});
				}
			});
		}
		/*
		//cf7msm3
		posted_data = cf7msm_ls;
		*/
	}
	if (posted_data) {
		var step_field = $("input[name='step']");
		//multi step forms
		if (step_field.length > 0) {
			var cf7_form = $(step_field[0].form);
			$.each(posted_data, function(key, val){
				/*
				//cf7msm3
				if (key == 'cf7msm_prev_urls') {
					cf7_form.find('.wpcf7-back, .wpcf7-previous').click(function(e) {
						window.location.href = val[step_field.val()];
						e.preventDefault();
					});
				}
				*/
				if ( ( key.indexOf('_') != 0 || key.indexOf('_wpcf7_radio_free_text_') == 0 || key.indexOf('_wpcf7_checkbox_free_text_') == 0 ) && key != 'step') {
					var field = cf7_form.find('*[name="' + key + '"]');
					if (field.length > 0) {
						if ( field.prop('type') == 'radio' || field.prop('type') == 'checkbox' ) {
							field.filter('input[value="' + val + '"]').prop('checked', true);
						}
						else {
							field.val(val);	
						}
					}
					else {
						//checkbox
						field = cf7_form.find('input[name="' + key + '[]"]'); //value is this or this or tihs
						if (field.length > 0) {
							if ( val != '' && val.length > 0  ) {
								$.each(val, function(i, v){
									field.filter('input[value="' + v + '"]').prop('checked', true);
								});	
							}
						}
					}
				}
			});
		} //end multi step forms
	}

	document.addEventListener( 'wpcf7mailsent', function( e ) {
		if ( cf7msm_hasLs() ) {
			var currStep = 0;
			var names = [];
			var currentInputs = {};
			cf7msm_ls = localStorage.getObject('cf7msm');
			if ( !cf7msm_ls ) {
				cf7msm_ls = {};
			}
			$.each(e.detail.inputs, function(i){
				var name = e.detail.inputs[i].name;
				var value = e.detail.inputs[i].value;

				//make it compatible with cookie version
				if ( name.indexOf('[]') === name.length - 2 ) {
					name = name.substring(0, name.length - 2 );
					if ( $.inArray(name, names) === -1 ) {
						currentInputs[name] = [];
					}
					currentInputs[name].push(value);
				}
				else {
					currentInputs[name] = value;
				}

				//figure out prev url
				if ( name === 'step' ) {
					if ( value.indexOf("-") !== -1 ) {
						var steps_prev_urls = {};
						if ( cf7msm_ls && cf7msm_ls.cf7msm_prev_urls ) {
							steps_prev_urls = cf7msm_ls.cf7msm_prev_urls;
						}
						var stepParts = value.split('-');
						currStep = parseInt( stepParts[0] );
						var totalSteps = parseInt( stepParts[1] );
						nextUrl = stepParts[2];
						if ( currStep < totalSteps ) {
							//is this the best way to get current url?
							var nextStep = (1+parseInt(currStep)) + '-' + totalSteps;
							steps_prev_urls[nextStep] = window.location.href;
							// hide the success messages on multi-step forms
							$('#' + e.detail.unitTag).find('div.wpcf7-mail-sent-ok').remove();
						}
						else if ( currStep === totalSteps ) {
							// hide the form on final multi-step form
							$(e.detail.unitTag + ' form').children().not('div.wpcf7-response-output').hide();
						}
						cf7msm_ls.cf7msm_prev_urls = steps_prev_urls;
					}
				}
				else {
					names.push(name);
				}
			});
			/*
			//cf7msm3
			if ( currStep != 0 ) {
				//this is a cf7msm form.
				if ( cf7msm['step-' + currStep + '-names'] ) {
					//clear past inputs for checkboxes
					var pastInputNames = cf7msm['step-' + currStep + '-names'];
					$.each(pastInputNames, function(i){
						var name = pastInputNames[i];
						delete cf7msm[name];
					});
					names = cf7msm_uniqueArray(cf7msm['step-' + currStep + '-names'], names);
				}
				//populate current
				$.each(currentInputs, function(name, value){
					cf7msm[name] = value;
				});
				cf7msm['step-' + currStep + '-names'] = names;
				localStorage.setObject( 'cf7msm', cf7msm );	
			}
			*/
			localStorage.setObject('cf7msm', cf7msm_ls);
		}
	}, false );
});

/**
 * Given 2 arrays, return a unique array
 * https://codegolf.stackexchange.com/questions/17127/array-merge-without-duplicates
 */
function cf7msm_uniqueArray(i,x) {
   h = {}
   n = []
   for (a = 2; a--; i=x)
      i.map(function(b){
        h[b] = h[b] || n.push(b)
      })
   return n
}

/**
 * check if local storage is usable.
 */
function cf7msm_hasLs() {
    var test = 'test';
    try {
        localStorage.setItem(test, test);
        localStorage.removeItem(test);
        return true;
    } catch(e) {
        return false;
    }
}
Storage.prototype.setObject = function(key, value) {
    this.setItem(key, JSON.stringify(value));
}

Storage.prototype.getObject = function(key) {
    var value = this.getItem(key);
    return value && JSON.parse(value);
}