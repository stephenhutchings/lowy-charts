
jQuery(document).ready(function($){
	//delete
	$('#adb-delete-button').click(function(){
	
		if(!confirm('Are you sure?')) return;
		//gathering data
		alldataArr = [];
		
		var dataDiv = [];
		$('.adb-chk:checked').each(function(indx){
			dataObj = {};
			dataObj.id 	= $(this).data('id');
			dataObj.key = $(this).data('key');
			dataObj.val = $(this).val();
			alldataArr[indx] = dataObj;
			dataDiv[indx] = $(this);
		});
		
		
		//ajax call
		$.post(
			ajaxurl, {
				'action': 'delete_cf7_data',
				'data':   alldataArr
			}, 
			function(response){

				if(response=="success"){
					dataDiv.forEach(function(el){
						el.parent().parent().fadeOut();
					});
				}
			}
		);
	});
	
	//delete
	$('.del-button').click(function(){
	
		
		if(!confirm('Are you sure?')) return;
		
		$('#loading-panel').fadeIn();

		//gathering data
		dataArr = [];
		dataObjSingle = {};
		
			dataObjSingle.id 	= $(this).data('id');
			dataObjSingle.key 	= $(this).data('key');
			dataObjSingle.val 	= $(this).data('val');
			dataArr[0] 			= dataObjSingle;
			currentDiv 			= $(this);
		
		
		//ajax call
		$.post(
			ajaxurl, {
				'action': 'delete_cf7_data',
				'data':   dataArr
			}, 
			function(response){
				if(response=="success"){
						currentDiv.parent().parent().fadeOut(function(){
							$('#loading-panel').fadeOut();
						});
				}
			}
		);
	});
	
	$('#cf7-selector').change(function(){
		window.location = "?page=cf7-adb&id="+$(this).val();
	});
	//initiate tb paging
	 $('#property-lead-table').DataTable({'pageLength': 10});
	 
	 $('#property-lead-table tr').hover(function(){

		$(this).find('input').css('border-color','green');
	 },function(){
		$(this).find('input').css('border-color','#bbbbbb');
	 });
	 


	 jQuery('.cfdb-notif').delay(2000).fadeOut('slow');

	// Change Column name
	$('#property-lead-table_wrapper column-title span').click(function(){
		$(this).attr('contentEditable',true);
	})

	 
	 
});