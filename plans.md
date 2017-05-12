# thoughts:

to make this a webapp, i need to either re-create a user's MarkovHash for each request, or i need a way to store the MarkovHash between requests.

### re-create

- seems wasteful
- might go over the twitter API limit easily

### store

- could store on frontend
  - hash is very big - would it be a headache to pass it to the frontend?
    - what's the smallest i could get this data structure?
  - json stringifying and parsing could get weird?
    - maybe change `nil` to `""`?
    - any other weird characters?
  - would require recreating MarkovHash logic on frontend

- could store on backend
  - need to maintain state between requests - how to do that?
    - long-running processes?
      - elixir?
    - store information between requests - caching?
      - redis?
  - could pre-generate a ton of tweets, store them in a text file, and read from that file until it's empty (at which point spin up a new MarkovHash and fill it up again)
