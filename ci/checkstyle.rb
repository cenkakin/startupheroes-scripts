require 'octokit'
require 'nokogiri'

def prepare_html_for_github
  html_doc = Nokogiri::HTML(File.read(ARGV[0]))
  results = html_doc.css('div#contentBox').to_s
  results
      .gsub('<img src="images/icon_info_sml.gif" alt="">', ':information_source:')
      .gsub('<img src="images/icon_warning_sml.gif" alt="">', ':warning:')
      .gsub('<img src="images/icon_error_sml.gif" alt="">', ':bangbang:')
      .gsub('<a href="checkstyle.rss"><img alt="rss feed" src="images/rss.png"></a>', '')
end

def comment_on_pr
  client = Octokit::Client.new :access_token => ENV['GITHUB_ACCESS_TOKEN']
  repo = ENV['CIRCLE_PROJECT_USERNAME'] + "/" + ENV['CIRCLE_PROJECT_REPONAME']
  pr_number = ENV['CIRCLE_PR_NUMBER']
  message = prepare_html_for_github
  client.add_comment(repo, pr_number, message)
end

comment_on_pr