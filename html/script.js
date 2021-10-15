function playsound(table) {
    var file = table['file']
    var volume = table['volume']
    var audioPlayer = null;
    if (audioPlayer != null) {
        audioPlayer.pause();
    }
    if (volume == undefined) {
        volume = 0.2
    }
    audioPlayer = new Audio("./audio/" + file + ".ogg");
    audioPlayer.volume = volume;
    audioPlayer.play();
}

window.addEventListener('message', function(event) {
    var data = event.data;
    if (event.data.type == 'playsound') {
        playsound(event.data.content)
    }

});