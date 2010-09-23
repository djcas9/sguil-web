//
// Sguil[web] - A web client for the popular Sguil security analysis tool.
//
// Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//

//jQuery.easing.def = "easeOutBounce";

function scrollToUpdate (id) {
	$.scrollTo('tr.'+id, 1000);
}

// function highlight_new_row(id) {
// 	var tableRow = 'tr.' + id;
// 	$(tableRow).animate({opacity: 1}, 3000);
// 	//$(document).bind(scrollToUpdate(id));
// }

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
		
		// if (localStorage.getItem('events')) {
		// 	$('table#event_stats tbody.content').html(localStorage.getItem('events'));
		// };
		// 
		// if (localStorage.getItem('sensors')) {
		// 	$('table.sensor_updates tbody.updates').html(localStorage.getItem('sensors'));
		// };
		
		if (localStorage.getItem('chat')) {
			$('div.user_messages ul.messages').html(localStorage.getItem('chat'));
		};
		
		if (localStorage.getItem('system_message')) {
			$('div.system_messages').html(localStorage.getItem('system_message'));
		};
		
		$("#growl").notify({
		    speed: 500,
		    expires: 3000
		});
	},

	table: function(){
		$('#event_stats').livequery(function() {
			$('table.event_stats').trigger("update");
			$(this).tablesorter({
				sortlist: [[0,0]]
			});
		});
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
		    text: system.message
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
			    text: data.message
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
		if ($('.event_stats tbody.content tr.remove_me').length > 0) {
			$('.event_stats tbody.content tr.remove_me').remove();
		};
		
		var event_uid = data.sensor_id + '.' + data.event_id;
		
		var EventData = '<tr data-sensor="'+data.sensor_id+'" data-event="'+data.event_id+'" id="'+event_uid+'" class="'+event_uid+'"> \
			<td>'+data.event_id+'</td> \
			<td class="priority_'+data.priority+'">'+data.priority+'</td> \
			<td>'+data.sensor+'</td> \
			<td class="name">'+data.signature+'</td> \
			<td class="source_id">'+data.source_ip+'</td> \
			<td class="source_port">'+data.source_port+'</td> \
			<td class="destination_ip">'+data.destination_ip+'</td> \
			<td class="destination_port">'+data.destination_port+'</td> \
			<td>'+data.created_at+'</td> \
			</tr>';
			
			if ($('table.event_stats tbody.content tr.' + event_uid).length > 0) {
				$('table.event_stats tbody.content tr.' + event_uid).replaceWith(EventData);
			} else {
				$('table.event_stats tbody.content').append(EventData);
			};
	},

	increment_event: function(data){
		
		if ($('table.event_stats tbody.content tr.' + data.event_uid).length > 0) {
			console.log(data)
			//$('table.event_stats tbody.content tr.' + data.event_uid)
		};
		
	},

	add_sensor: function(data){
		$('table.sensor_stats').trigger("update");

		var SensorData = '<tr id="sensor'+data.id+'" class='+data.id+'> \
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

		if ($('div.pane_data table.sensor_updates tbody.updates tr.'+data.id).length > 0) {
			$('div.pane_data table.sensor_updates tbody.updates tr.'+data.id).replaceWith(SensorData)
		} else {
			$('div.pane_data table.sensor_updates tbody.updates').prepend(SensorData)
		};
		
		localStorage.setItem('sensors', $('table.sensor_updates tbody.updates').html());
		
	}
}


$(document).ready(function() {
	
	Sguil.connect();
	Sguil.table();
	Sguil.send_message();
	Sguil.update_pane();
	
});

var sguil = new Faye.Client('http://'+sguil_server+'/sguil')

Logger = {
	incoming: function(message, callback) {
		console.log('incoming', message);
		callback(message)
	},
	outgoing: function(message, callback) {
		console.log('outgoing', message);
		callback(message);
	}
};

//gAdd Logger
sguil.addExtension(Logger);

var sensor_array = new Array();

var usermsg = sguil.subscribe('/usermsg/'+sguil_uid, function (usermsg) {
	Sguil.add_usermsg(usermsg);
	localStorage.setItem('chat', $('div.user_messages ul.messages').html());
});

var system_message = sguil.subscribe('/system_message/'+sguil_uid, function (system) {
	Sguil.add_system_message(system);
	localStorage.setItem('system_message', $('div.system_messages').html());
});

var events = sguil.subscribe('/add_event/'+sguil_uid, function(data) {
	// $('table#event_stats tbody.content')
	Sguil.insert_event(data);
	$('table.event_stats').trigger("update"); 
});

var	increment_event = sguil.subscribe('/increment_event/'+sguil_uid, function(data) {
	Sguil.increment_event(data); 
});

var sensor = sguil.subscribe('/sensor/'+sguil_uid, function (sensor) {
	Sguil.add_sensor(sensor);
	// $('table.sensor_stats').trigger("update");
});