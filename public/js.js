document.addEventListener("DOMContentLoaded", () => {
  const usernameInput = document.getElementById("username")
  const submitUsername = document.getElementById("submit")
  const usernameForm = document.getElementById("form")
  const tweetList = document.getElementById("tweets")
  const generateTweetButton = document.getElementById("generate")
  const tweetingAs = document.getElementById("now-tweeting-as")
  let username = ""

  usernameForm.addEventListener("submit", (e) => {
    e.preventDefault()
    fetch(`https://markovtweeter.herokuapp.com/lookup/${usernameInput.value}`)
      .then((res) => {
        username = usernameInput.value
        usernameInput.value = ""
        tweetList.innerHTML = ""
        tweetingAs.innerText = `now tweeting in the style of @${username}`
        generateTweetButton.disabled = false
        console.log("got it")
      })

    tweetingAs.innerText = `creating a markov chain from
    @${usernameInput.value}'s twitter history`
    generateTweetButton.disabled = true
  })

  generateTweetButton.addEventListener("click", (e) => {
    e.preventDefault()
    fetch(`https://markovtweeter.herokuapp.com/lookup/${username}/search`)
      .then(res => res.json() )
      .then(res => {
        tweetList.innerHTML = `<li>${res.message}</li>` + tweetList.innerHTML
      })
  })
})
