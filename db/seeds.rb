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
  :feed_url => "http://www.soccer-king.jp/RSS.rdf",
  :category_id => 0,
  :rank => nil
)

Site.create(
  :name => "Goal.com",
  :url => "http://www.goal.com/jp/",
  :feed_url => "http://www.goal.com/jp/feeds/news?fmt=rss&ICID=HP",
  :category_id => 0,
  :rank => nil
)

Site.create(
  :name => "スポーツナビ/サッカー",
  :url => "http://sportsnavi.yahoo.co.jp/sports/soccer/headlines/",
  :feed_url => "http://sportsnavi.yahoo.co.jp/sports/soccer/headlines/rss",
  :category_id => 0,
  :rank => nil
)

Site.create(
  :name => "スポーツナビ＋ サッカー日本代表",
  :url => "http://www.plus-blog.sportsnavi.com/centric/soccer_japan",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/soccer_japan/rss2_0.xml",
  :category_id => 3
)

Site.create(
  :name => "スポーツナビ＋ Jリーグ",
  :url => "http://www.plus-blog.sportsnavi.com/centric/jleague",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/jleague/rss2_0.xml",
  :category_id => 3
)

Site.create(
  :name => "スポーツナビ＋ サッカーワールドカップ",
  :url => "http://www.plus-blog.sportsnavi.com/centric/soccer_wcup",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/soccer_wcup/rss2_0.xml",
  :category_id => 3
)

Site.create(
  :name => "スポーツナビ＋ 欧州サッカー",
  :url => "http://www.plus-blog.sportsnavi.com/centric/eusoccer",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/eusoccer/rss2_0.xml",
  :category_id => 3
)


=begin
Site.create(
  :name => "スポーツナビ＋ ",
  :url => "",
  :feed_url => "",
  :category_id => 3
)
=end

Category.create(
  :id => 0,
  :name => "ニュース"
)

Category.create(
  :id => 1,
  :name => "2chまとめ"
)

Category.create(
  :id => 2,
  :name => "海外の反応"
)

Category.create(
  :id => 3,
  :name => "その他のブログ"
)