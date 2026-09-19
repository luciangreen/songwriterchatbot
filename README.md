# songwriterchatbot

Song Writer is a Prolog-based song-specification chatbot scaffold that interprets natural-language prompts, expands them into structured song specifications, dramatizes the musical arc, adapts the result into a Music Composer-style representation, and preserves non-destructive edit history.

## Included foundation

- modular Prolog API in `song_writer.pl`
- rule-based interpretation, expansion, dramatization, lyrics, inspiration, originality, evaluation, export, and editing helpers
- lightweight SWI-Prolog HTTP server entry point in `song_server.pl`
- static web shell in `web/`
- focused plunit coverage in `tests/test_song_writer.pl`
- 200 structural acceptance/training pairs in `tests/acceptance_pairs.pl`

## Run tests

```sh
make test
```

## Start the local API server

```sh
swipl -q -g "['song_server.pl'],start_server(8080)"
```
