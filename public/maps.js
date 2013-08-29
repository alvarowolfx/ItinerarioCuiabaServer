var map;
var markersArray = [];

function initialize() {
  var haightAshbury = new google.maps.LatLng(37.7699298, -122.4469157);
  var mapOptions = {
    zoom: 12,
    center: haightAshbury,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  map =  new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  console.log('Tudo certo hein');
  
  carregarPontos();
  centerInUser();

}

function centerInUser(){
    if(navigator.geolocation){
        navigator.geolocation.getCurrentPosition(function(position) {
            var latitude = position.coords.latitude;
            var longitude = position.coords.longitude;
            var geolocpoint = new google.maps.LatLng(latitude, longitude);
            map.setCenter(geolocpoint );//line added for setting center
        });
    }
}

function carregarPontos() {
 
    $.getJSON('/api/v1/pontos_de_recarga', function(pontos) {
 
        $.each(pontos, function(index, ponto) {
            if(ponto.location){
                addMarker(ponto.location,ponto.name);
            }
        });
 
    });
 
}
 
function addMarker(location,title) {
    marker = new google.maps.Marker({
        position: new google.maps.LatLng(location.lat, location.lon),
        map: map,
        title: title
    });
    var infowindow = new google.maps.InfoWindow(), marker;
    google.maps.event.addListener(marker, 'click', (function(marker, i) {
        return function() {
            infowindow.setContent(marker.title);
            infowindow.open(map, marker);
        }
    })(marker))
  markersArray.push(marker);
}

