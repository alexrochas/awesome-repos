require 'octokit'
require 'pp'

def exitGently
  puts "Set GITHUB_PASS env variable and try again."
  exit
end

exitGently unless ENV['GITHUB_PASS']

client = Octokit::Client.new(:login => 'alexrochas', :password => ENV['GITHUB_PASS'], per_page: 200)
# client.auto_paginate = true

pp client.repos
repos = client
  .repos
  .select {|repo| !repo.private }

formatted_repos = repos.map {|repo|
  {
    name: repo.name,
    url: repo.html_url,
    description: repo.description,
    languages: client.languages(repo.full_name)
  }
}


File.open("README.gen", 'w') { |f|
  # README header
  f.write "# ![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)\n> A curated list of awesome topics in my github\n\n"

  # README body
  formatted_repos.map {|repo|
    f.write "[#{repo[:name]}](#{repo[:url]})\n"
    f.write "> #{repo[:description]}, [#{repo[:languages].map{|l| l.first.to_s}.join(', ')}]\n\n"
  }

  # README footer
  f.write "## Meta\n\nAlex Rocha - [about.me](http://about.me/alex.rochas))"

}

puts "Now move README to the root path with\n\nmv ./README.gen ../README.md"
