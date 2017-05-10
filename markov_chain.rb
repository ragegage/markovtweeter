require 'twitter'

# f = File.readlines('florida_man1.txt')
# f2 = f.map {|w| w.gsub("---", "") }
# f2.map! {|w| w.gsub("\n", "") }
# mh = MarkovHash.parse f2

# class to handle accessing values with probabilities attached
$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

# client.user_timeline("_FloridaMan")

# id: 1122192223
# https://api.twitter.com/1.1/search/tweets.json?q=from:_FloridaMan

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

# a = ["this is a test", "this is not a test", "this is the coolest test ever"]
# a0 = "In probability theory and statistics, the term Markov property refers
# to the memoryless property of a stochastic process. It is named after
# the Russian mathematician Andrey Markov.[1] A stochastic process has the
# Markov property if the conditional probability distribution of future
# states of the process (conditional on both past and present states)
# depends only upon the present state, not on the sequence of events that
# preceded it. A process with this property is called a Markov process.
# The term strong Markov property is similar to the Markov property,
# except that the meaning of 'present' is defined in terms of a random
# variable known as a stopping time. The term Markov assumption is used to
# describe a model where the Markov property is assumed to hold, such as a
# hidden Markov model. A Markov random field[2] extends this property to
# two or more dimensions or to random variables defined for an
# interconnected network of items. An example of a model for such a field
# is the Ising model. A discrete-time stochastic process satisfying the
# Markov property is known as a Markov chain. "
#
# a0 += "Early researchers found that an electric or magnetic field could split
# radioactive emissions into three types of beams. The rays were given the
# names alpha, beta, and gamma, in order of their ability to penetrate
# matter. While alpha decay was observed only in heavier elements of
# atomic number 52 (tellurium) and greater, the other two types of decay
# were produced by all of the elements. Lead, atomic number 82, is the
# heaviest element to have any isotopes stable (to the limit of
# measurement) to radioactive decay. Radioactive decay is seen in all
# isotopes of all elements of atomic number 83 (bismuth) or greater.
# Bismuth, however, is only very slightly radioactive, with a half-life
# greater than the age of the universe; radioisotopes with extremely long
# half-lives are considered effectively stable for practical purposes.
# Transition diagram for decay modes of a radionuclide, with neutron
# number N and atomic number Z (shown are α, β±, p+, and n0 emissions, EC
# denotes electron capture). Types of radioactive decay related to N and Z
# numbers In analysing the nature of the decay products, it was obvious
# from the direction of the electromagnetic forces applied to the
# radiations by external magnetic and electric fields that alpha particles
# carried a positive charge, beta particles carried a negative charge, and
# gamma rays were neutral. From the magnitude of deflection, it was clear
# that alpha particles were much more massive than beta particles. Passing
# alpha particles through a very thin glass window and trapping them in a
# discharge tube allowed researchers to study the emission spectrum of the
# captured particles, and ultimately proved that alpha particles are
# helium nuclei. Other experiments showed beta radiation, resulting from
# decay and cathode rays, were high-speed electrons. Likewise, gamma
# radiation and X-rays were found to be high-energy electromagnetic
# radiation. The relationship between the types of decays also began to be
# examined: For example, gamma decay was almost always found to be
# associated with other types of decay, and occurred at about the same
# time, or afterwards. Gamma decay as a separate phenomenon, with its own
# half-life (now termed isomeric transition), was found in natural
# radioactivity to be a result of the gamma decay of excited metastable
# nuclear isomers, which were in turn created from other types of decay.
# Although alpha, beta, and gamma radiations were most commonly found,
# other types of emission were eventually discovered. Shortly after the
# discovery of the positron in cosmic ray products, it was realized that
# the same process that operates in classical beta decay can also produce
# positrons (positron emission), along with neutrinos (classical beta
# decay produces antineutrinos). In a more common analogous process,
# called electron capture, some proton-rich nuclides were found to capture
# their own atomic electrons instead of emitting positrons, and
# subsequently these nuclides emit only a neutrino and a gamma ray from
# the excited nucleus (and often also Auger electrons and characteristic
# X-rays, as a result of the re-ordering of electrons to fill the place of
# the missing captured electron). These types of decay involve the nuclear
# capture of electrons or emission of electrons or positrons, and thus
# acts to move a nucleus toward the ratio of neutrons to protons that has
# the least energy for a given total number of nucleons. This consequently
# produces a more stable (lower energy) nucleus. (A theoretical process of
# positron capture, analogous to electron capture, is possible in
# antimatter atoms, but has not been observed, as complex antimatter atoms
# beyond antihelium are not experimentally available.[20] Such a decay
# would require antimatter atoms at least as complex as beryllium-7, which
# is the lightest known isotope of normal matter to undergo decay by
# electron capture.) Shortly after the discovery of the neutron in 1932,
# Enrico Fermi realized that certain rare beta-decay reactions immediately
# yield neutrons as a decay particle (neutron emission). Isolated proton
# emission was eventually observed in some elements. It was also found
# that some heavy elements may undergo spontaneous fission into products
# that vary in composition. In a phenomenon called cluster decay, specific
# combinations of neutrons and protons other than alpha particles (helium
# nuclei) were found to be spontaneously emitted from atoms. Other types
# of radioactive decay were found to emit previously-seen particles, but
# via different mechanisms. An example is internal conversion, which
# results in an initial electron emission, and then often further
# characteristic X-rays and Auger electrons emissions, although the
# internal conversion process involves neither beta nor gamma decay. A
# neutrino is not emitted, and none of the electron(s) and photon(s)
# emitted originate in the nucleus, even though the energy to emit all of
# them does originate there. Internal conversion decay, like isomeric
# transition gamma decay and neutron emission, involves the release of
# energy by an excited nuclide, without the transmutation of one element
# into another. Rare events that involve a combination of two beta-decay
# type events happening simultaneously are known (see below). Any decay
# process that does not violate the conservation of energy or momentum
# laws (and perhaps other particle conservation laws) is permitted to
# happen, although not all have been detected. An interesting example
# discussed in a final section, is bound state beta decay of rhenium-187.
# In this process, beta electron-decay of the parent nuclide is not
# accompanied by beta electron emission, because the beta particle has
# been captured into the K-shell of the emitting atom. An antineutrino is
# emitted, as in all negative beta decays. Radionuclides can undergo a
# number of different reactions. These are summarized in the following
# table. A nucleus with mass number A and atomic number Z is represented
# as (A, Z). The column 'Daughter nucleus' indicates the difference
# between the new nucleus and the original nucleus. Thus, (A − 1, Z) means
# that the mass number is one less than before, but the atomic number is
# the same as before. If energy circumstances are favorable, a given
# radionuclide may undergo many competing types of decay, with some atoms
# decaying by one route, and others decaying by another. An example is
# copper-64, which has 29 protons, and 35 neutrons, which decays with a
# half-life of about 12.7 hours. This isotope has one unpaired proton and
# one unpaired neutron, so either the proton or the neutron can decay to
# the opposite particle. This particular nuclide (though not all nuclides
# in this situation) is almost equally likely to decay through positron
# emission (18%), or through electron capture (43%), as it does through
# electron emission (39%). The excited energy states resulting from these
# decays which fail to end in a ground energy state, also produce later
# internal conversion and gamma decay in almost 0.5% of the time. More
# common in heavy nuclides is competition between alpha and beta decay.
# The daughter nuclides will then normally decay through beta or alpha,
# respectively, to end up in the same place. "
#
# a0 += "Our interview will last between 1 and 2 hours, and will cover
# programming, system design, and general web knowledge.  The exact length
# and content of the interview varies. However, your interview will
# involve two or more of the sections listed below.   We use Google
# Hangouts for the interview. For the coding portions, you're free to use
# whatever environment you're most comfortable in (we'll follow along over
# screen share). Please make sure that you have a Google account before
# the interview, and that you have a functioning microphone. Programming
# In this section, we'll ask you to build a single-page web application.
# You're welcome to use any framework, language, and build process you're
# most familiar with. Make sure you set up any configuration or
# boilerplate before the interview starts so you don't waste time creating
# a project from scratch! In this section, we ask questions in a range of
# technical topics, and discuss the answers with you. We'll dive deep into
# Javascript, CSS, HTTP, security, and algorithms. We do not expect anyone
# to be strong in all of these areas. The idea of this section is to find
# what each engineer knows the most about (we generally view the interview
# as a search for areas of strength). This section is difficult to prepare
# for specifically. However, the MDN Learning Area is a comprehensive
# guide to web technologies, and The Algorithm Design Manual is useful for
# the algorithmic portion. In this final section, we'll talk through the
# design for a hypothetical web system. Here we look mostly for practical
# experience building websites / web systems. If you have this, then
# great! If you don't, that's fine too (we look for all kinds of
# strengths). However, we do recommend making sure you're familiar with
# databases, app servers, web servers, HTTP and how all these fit together
# behind a modern web system. The best advice we can give on the
# programming tasks is to slow down, take a breath, and think about what
# you're going to program. Your interviewer will be happy to discuss
# designs, and be a sounding board for ideas. Taking a few minutes to iron
# out a good design before you start programming is worth it. We do care
# about code cleanliness (correct indentation, reasonable naming, modular
# structure). Because time is short in an interview, however, we don't
# need you to write full unit tests (unless this is an important part of
# your process). We want to see you at your best. Don’t feel pressured to
# study or prepare in any way, but if you want to, here’s how we think you
# can best do so: Practice programming under pressure. An interview is a
# stressful situation, and this sometimes affects performance (especially
# for less experienced programmers). We recommend that you practice
# programming under self-imposed time limits, to get used to this stress.
# It is often useful as well to do mock interviews with friends, where you
# ask each other programming questions under time limits. Practice talking
# about system design. The system design questions aim to test your
# experience designing large software systems. We want to see that you can
# think abstractly about how to build software systems out of smaller
# components; and we want to see that you are comfortable doing so. You
# can practice this by reading about system design, for example on
# highscalability.com."
#
# a = a0.split(".")

# mh = MarkovHash.parse(a)



# words = Hash.new { [] }
#
# # takes list of strings, creates hash of their following values
# a.each do |string|
#   word_arr = string.split(" ")
#   words[nil] += [word_arr[0]] # adds starting words with nil as their pointer
#   0.upto(word_arr.length - 1).each do |idx|
#     words[word_arr[idx]] += [word_arr[idx + 1]]
#   end
# end
#
# # transforms hash of inputs and next steps into probability hash
# words.each do |current_word, nexts|
#   total = nexts.length.to_f
#   prob_list = Hash.new { 0 }
#   nexts.each do |next_option|
#     prob_list[next_option] += 1/total
#   end
#   words[current_word] = prob_list
# end

# mh = MarkovHash.new(words)





# takes probability hash, creates probability matrix
