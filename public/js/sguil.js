
//jQuery.easing.def = "easeOutBounce";

function scrollToUpdate (id) {
	$.scrollTo('tr.'+id, 1000);
}

function highlight_new_row(id) {
	var tableRow = 'tr.' + id;
	$(tableRow).animate({opacity: 1}, 3000);
	//$(document).bind(scrollToUpdate(id));
}

function hide_and_update_pane(url,selector) {
	var Pane = $('div.pane_holder div.pane_data');
	$('div.pane_holder div.pane_data #pane').hide();
	$('div.pane_holder div.pane_data '+selector).show();
}

var Sguil = {
	
	Helpers: {
		
		flashMessages: function() {
	    $('<div id="flash-messages"></div>').appendTo('body');
	  },

	  flashMessage: function(message) {
	    $('<p class="flash-message" />').text(message).appendTo("#flash-messages");
	  }
		
	},
	
	connect: function(){
		$("#growl").notify({
		    speed: 500,
		    expires: 3000
		});
		
		// $('div.pane_holder').resizable({
		// 	maxHeight: 700,
		// 	minHeight: 300,
		// 	animate: true,
		// 	handles: 'n',
		// 	grid: 50,
		// 	ghost: true
		// });
		
		$.post('/connect', {});
	},
	
	table: function(){
	// 	$('#sensor_stats').livequery(function() {
	// 		$('table.sensor_stats').trigger("update");
	// 		$(this).tablesorter({
	// 			sortlist: [[3,1]]
	// 		});
	// 	});
	},
	
	send_message: function(){

		$('form.new_user_message').livequery('submit',function() {
			var chatInput = $('input.message_input').val();
			$.post('/send/message', {msg:chatInput});
			$('input.message_input').val('');
			return false;
    });

		//$('input.message_input')

	},
	
	add_system_message: function(system){
		dateTime = new Date();
		$('div.pane_holder div.pane_data ul.system_messages').append('<li><span class="time">'+dateTime+'</span> <span class="name">'+system.object+':</span> <span class="msg">'+system.message+'</span></li>');
		
		$('#growl').notify("create", {
		    title: ''+system.object+' :',
		    text: system.msg
		},{
		    expires: 3000,
		    speed: 500
		});
	},
	
	add_usermsg: function(data){
		dateTime = new Date();
		$('div.pane_holder div.pane_data div.user_messages ul.messages').append('<li><span class="time">'+dateTime+'</span> <span class="name">'+data.username+':</span> <span class="msg">'+data.message+'</span></li>');
		
		if (sguil_user != data.username) {
		
			$('#growl').notify("create", {
			    title: ''+data.username+' Said:',
			    text: data.msg
			},{
			    expires: 3000,
			    speed: 500
			});
			
		};
		
		$('ul.messages').scrollTo('100%', 1);
	},
	
	update_pane: function(){
		
		var Pane = $('div.pane_holder div.pane_data');
		
		$('a.show_user_message').livequery('click',function() {
			hide_and_update_pane('/user_message', 'div.user_messages');
			$('ul.messages').scrollTo('100%', 1);
			$('input#message_input').focus();
			return false;
		});
		
		$('a.show_system_messages').livequery('click',function() {
			hide_and_update_pane('/system_messages', 'ul.system_messages');
			return false;
		});
		
		$('a.show_sensor_updates').livequery('click',function() {
			hide_and_update_pane('/sensor_updates', 'table.sensor_updates');
			return false;
		});

		$('a.hide_update_pane').livequery('click', function() {
			$(this).replaceWith("<a class='show_update_pane' href='#show'>Show Pane</a>")
			$('div.options ul li.tab').hide();
			$('div.pane_holder').animate({
			  "bottom": "-275px", "opacity": 0.8
			}, 500);
			return false;
		});
		
		$('a.show_update_pane').livequery('click', function() {
			$(this).replaceWith("<a class='hide_update_pane' href='#hide'>Hide Pane</a>");
			$('div.options ul li.tab').show();
			$('div.pane_holder').animate({
			  "bottom": "0px", "opacity": 1
			}, 500);
			return false;
		});
		
	},

	insert_event: function(data){		
		$('table.event_stats').trigger("update");
		
		var EventData = '<tr data-sensor="'+data.sensor_id+'" id="event'+data.event_id+'" class='+data.event_id+' style="opacity: 0.1;"> \
			<td>'+data.event_id+'</td> \
			<td class="priority_'+data.priority+'">'+data.priority+'</td> \
			<td>'+data.sensor+'</td> \
			<td class="name">'+data.signature+'</td> \
			<td class="source_id">'+data.source_ip+'</td> \
			<td class="source_port">'+data.source_port+'</td> \
			<td class="destination_ip">'+data.bytes+'</td> \
			<td class="destination_port">'+data.match+'</td> \
			<td>'+data.created_at+'</td> \
			</tr>';
			
			if ($('table.event_stats tbody.content tr.'+data.event_id).length > 0) {

				$('table.event_stats tbody.content tr.'+data.event_id).replaceWith(EventData);
				highlight_new_row(data.event_id);

			} else {

				$('table.event_stats tbody.content').append(EventData);
				highlight_new_row(data.event_id);

			};
		
	},

	add_sensor: function(data){
		$('table.sensor_stats').trigger("update");
		
		var SensorData = '<tr id="sensor'+data.id+'" class='+data.id+' style="opacity: 0.1;"> \
			<td>'+data.id+'</td> \
			<td class="name">'+data.name+'</td> \
			<td>'+data.packet_loss+'</td> \
			<td>'+data.avg_bw+'</td> \
			<td>'+data.alerts+'</td> \
			<td>'+data.packets+'</td> \
			<td>'+data.bytes+'</td> \
			<td>'+data.match+'</td> \
			<td>'+data.new_ssns+'</td> \
			<td>'+data.ttl_ssns+'</td> \
			<td>'+data.max_ssns+'</td> \
			<td>'+data.updated_at+'</td> \
			</tr>';

		if ($('table.sensor_stats tbody.content tr.'+data.id).length > 0) {
			
			$('table.sensor_stats tbody.content tr.'+data.id).replaceWith(SensorData);
			$('div.pane_data table.sensor_updates tbody.updates tr.'+data.id).replaceWith(SensorData)
			highlight_new_row(data.id);
			
		} else {
			
			$('table.sensor_stats tbody.content').append(SensorData);
			$('div.pane_data table.sensor_updates tbody.updates').prepend(SensorData)
			highlight_new_row(data.id);
			
		};
		//$('table').trigger('sorton', [[4,1]]);
	}
}


$(document).ready(function() {
	Sguil.connect();
	Sguil.table();
	Sguil.send_message();
	Sguil.update_pane();
});

// Logger = {
// 	incoming: function(message, callback) {
// 		console.log('incoming', message);
// 		callback(message)
// 	},
// 	outgoing: function(message, callback) {
// 		console.log('outgoing', message);
// 		callback(message);
// 	}
// };

var sguil = new Faye.Client('http://'+sguil_server+'/sguil', {timeout: 120})
// Add Logger
//sguil.addExtension(Logger);

var sensor_array = new Array();

var usermsg = sguil.subscribe('/usermsg', function (usermsg) {
	console.log(usermsg);
	Sguil.add_usermsg(usermsg);
});

var system_message = sguil.subscribe('/system_message', function (system) {
	console.log(system);
	Sguil.add_system_message(system);
});

var events = sguil.subscribe('/add_event', function(data) {
	console.log(data);
	Sguil.insert_event(data);
});

var sensor = sguil.subscribe('/sensor', function (sensor) {
	// sensor_array.push(sensor);
	console.log(sensor);
	Sguil.add_sensor(sensor);
	//$('table.sensor_stats').trigger("update");
});