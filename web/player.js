window.songWriterPlayer = {
  load(description) {
    const player = document.getElementById('player');
    if (player) player.textContent = description;
  }
};

