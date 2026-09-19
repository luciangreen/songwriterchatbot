# songwriterchatbot

Song Writer is a Prolog-based song-specification chatbot scaffold that interprets natural-language prompts, expands them into structured song specifications, dramatizes the musical arc, adapts the result into a Music Composer-style representation, and preserves non-destructive edit history.

## Included foundation

- modular Prolog API in `song_writer.pl`
- rule-based interpretation, expansion, dramatization, lyrics, inspiration, originality, evaluation, export, and editing helpers
- lightweight SWI-Prolog HTTP server entry point in `song_server.pl`
- static web shell in `web/`
- focused plunit coverage in `tests/test_song_writer.pl`
- 200 structural acceptance/training pairs in `tests/acceptance_pairs.pl`

## Command showcase

### 1) Run the full test suite

```sh
make test
```

What this does:
- Executes the `test` target from `Makefile`
- Runs SWI-Prolog plunit tests from `tests/test_song_writer.pl`
- Exits after tests complete

### 2) Start the local HTTP API server

```sh
swipl -q -g "['song_server.pl'],start_server(8080)"
```

What this does:
- Loads `song_server.pl`
- Starts the HTTP server on port `8080`
- Exposes:
  - `GET /api/health`
  - `GET /api/generate?prompt=...`

### 3) Check server health

```sh
curl "http://localhost:8080/api/health"
```

Expected response:

```json
{"status":"ok"}
```

### 4) Generate a song project from a prompt

```sh
curl --get "http://localhost:8080/api/generate" \
  --data-urlencode "prompt=Happy guitar pop song with lyrics about finally finishing university."
```

What this returns:
- A JSON object with a `project` field
- `project` contains the generated Prolog term as text

### 5) Use the core API directly in SWI-Prolog (without HTTP)

```sh
swipl -q -g "['song_writer.pl'],song_writer('A mysterious instrumental song about walking through Melbourne at 3 AM.', Project),write_term(Project,[quoted(true)]),nl,halt"
```

What this does:
- Loads the main module `song_writer.pl`
- Generates a project term from the prompt
- Pretty-prints the resulting Prolog structure in the terminal

### 6) Open an interactive Prolog REPL for experimentation

```sh
swipl
```

Then load modules and run commands interactively:

```prolog
?- ['song_writer.pl'].
?- song_writer("Happy guitar pop song with lyrics about finally finishing university.", Project).
```
