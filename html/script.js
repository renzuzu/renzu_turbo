const playsound = (table) => {
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

window.addEventListener('message', (event) => {
    if (event.data.type == 'playsound') {
        playsound(event.data.content)
    }

    if (event.data.show) {
        document.querySelector('.racing-container').style.opacity = 1.0
    } else if(event.data.show == false) {
        document.querySelector('.racing-container').style.opacity = 0.0
    }
    if (event.data.type == 'turbo') {
        document.querySelector('#gauge-score').innerHTML = event.data.boost.toFixed(2)
        const percent = (event.data.boost / event.data.max) * 100
        document.querySelector('.racing-container .js-racing-progress').style.strokeDashoffset = 100 - percent
    }

})