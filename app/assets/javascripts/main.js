/**
 *
 */
$(function(){

	console.info("");
	//jQueryの処理を記述
  
	$("input.submit").click(function() {
	  	// サイトidを取得
		var id = $(this).attr("id");
		// 更新
		updateSite(id);
	});
});

/**
 * サイトのカテゴリ変更
 *
 * @param id サイトid
 */
function updateSite(id) {
// 要リファクタリング
	var cat_id = $("input#" + id).prev().val();
	var site_name = $("input#" + id).prev().prev().val();

	var data = { 
		'site': { 
			'id': id,
			'name': site_name,
		 	'category_id': cat_id
		}
	};
	var url = "./update";

	// ajaxでPOST通信
	$.ajax({
		type: "POST",
		url: url,
		data: data,
		success: function() {
			console.info('update success.');
		}
	});

	//$("#tr" + id).hide();

	//$("tr.tr" + id).hide();
	//$("#categoryFixCheck"+id).attr("disabled", true);
	//$("#adultCheck"+id).attr("disabled", true);
}
