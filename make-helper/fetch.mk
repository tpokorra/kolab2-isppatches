# The targets we need to download
FETCH_TARGETS = $(FETCH_SOURCE) $(FETCH_RPM)

#Fetch target
.PHONY: fetch
fetch: $(FETCH_TARGETS)