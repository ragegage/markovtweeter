require 'twitter'

# ruby library to connect to Twitter's API
$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def $client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

# class to handle accessing values with probabilities attached
class MarkovHash
  def initialize(probability_hash)
    @hash = probability_hash
  end

  def self.from_twitter(username)
    puts "this may take a few seconds..."

    tweets = $client.get_all_tweets(username).map { |tw| tw.text }
    parse(tweets)
  end

  def self.parse(training)
    words = hash_from_array(training)

    MarkovHash.new(words)
  end

  def self.hash_from_array(training)
    words = Hash.new { [] }

    # takes list of strings, creates hash of their following values
    training.each do |string|
      word_arr = string.split
      words[nil] += [word_arr[0]] # adds starting words with nil as their pointer
      0.upto(word_arr.length - 1).each do |idx| # collects sentence-enders as pointing to nil
        words[word_arr[idx]] += [word_arr[idx + 1]]
      end
    end

    # transforms hash of inputs and next steps into probability hash
    words.each do |current_word, nexts|
      total = nexts.length.to_f
      prob_list = Hash.new { 0 }
      nexts.each do |next_option|
        prob_list[next_option] += 1/total
      end
      words[current_word] = prob_list
    end

    words
  end

  def access(input)
    options = @hash[input]
    r = rand
    prob = 0
    options.each do |k, v|
      prob += v
      return k if r < prob
    end
  end

  def [](input)
    access(input)
  end

  def string
    words = []
    until words.length > 0 && words.last == nil
      words << self[words.last]
    end
    sentence = words.join(" ")
    sentence[-1] = "."
    sentence
  end
end
