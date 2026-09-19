SWIPL=swipl

.PHONY: test
test:
	$(SWIPL) -q -g run_tests -t halt tests/test_song_writer.pl

