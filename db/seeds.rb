# -*- encoding: UTF-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Site.create(
  :name => "サッカーキング",
  :url => "http://www.soccer-king.jp/news",
  :feed_url => "http://www.soccer-king.jp/RSS.rdf"
)

Site.create(
  :name => "Goal.com",
  :url => "http://www.goal.com/jp/",
  :feed_url => "http://www.goal.com/jp/feeds/news?fmt=rss&ICID=HP"
)

Site.create(
  :name => "スポーツナビ/サッカー",
  :url => "http://sportsnavi.yahoo.co.jp/sports/soccer/headlines/",
  :feed_url => "http://sportsnavi.yahoo.co.jp/sports/soccer/headlines/rss"
)