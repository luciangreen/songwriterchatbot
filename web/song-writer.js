const promptBox = document.getElementById('prompt');
const generateButton = document.getElementById('generate');
const chatLog = document.getElementById('chat-log');
const inspector = document.getElementById('inspector');

async function generateSong() {
  const prompt = promptBox.value.trim();
  if (!prompt) return;

  chatLog.textContent = `> ${prompt}\nGenerating...`;

  try {
    const response = await fetch(`/api/generate?prompt=${encodeURIComponent(prompt)}`);
    const data = await response.json();
    chatLog.textContent = `> ${prompt}\nGenerated project.`;
    inspector.textContent = data.project;
  } catch (_error) {
    chatLog.textContent = `> ${prompt}\nServer unavailable. Static UI only.`;
  }
}

generateButton.addEventListener('click', generateSong);

