# -*- encoding: UTF-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# カテゴリー
# 
Category.create(
  :id => 1,
  :name => "政治、経済"
)

Category.create(
  :id => 5,
  :name => "エンタメ"
)

Category.create(
  :id => 6,
  :name => "アニメとゲーム"
)
=begin
Category.create(
  :id => 0,
  :name => "政治、経済"
)

Category.create(
  :id => 1,
  :name => "サッカー"
)

Category.create(
  :id => 2,
  :name => "野球"
)
=end

# サブカテゴリー
# 
SubCategory.create(
  :id => 0,
  :name => "ニュース"
)

SubCategory.create(
  :id => 1,
  :name => "ブログ"
)

SubCategory.create(
  :id => 2,
  :name => "2chまとめ"
)

# ブログランキング
# 

BlogRankPage.create(
  :title =>    "ライブドア / 政治(総合)",
  :url =>      "http://blog.livedoor.com/category/22/",
  :feed_url => "http://blog.livedoor.com/xml/blog_ranking_cat22.rdf",
  :category_id => 0,
  :sub_category_id => 1,
  :blog_service_name => "livedoor",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "FC2 / 政治、経済",
  :url =>      "http://blog.fc2.com/subgenre/9/",
  :category_id => 0,
  :sub_category_id => 1,
  :blog_service_name => "fc2",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "Ameba / 政治、経済",
  :url =>      "http://ranking.ameba.jp/gr_seiji",
  :category_id => 0,
  :sub_category_id => 1,
  :blog_service_name => "Ameba",
  :max_register_count => 25
)


BlogRankPage.create(
  :title =>    "ライブドア / サッカー",
  :url =>      "http://blog.livedoor.com/category/9/",
  :feed_url => "http://blog.livedoor.com/xml/blog_ranking_cat9.rdf",
  :category_id => 1,
  :sub_category_id => 1,
  :blog_service_name => "livedoor",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "ライブドア / サッカーまとめ",
  :url =>      "http://blog.livedoor.com/category/446/",
  :feed_url => "http://blog.livedoor.com/xml/blog_ranking_cat446.rdf",
  :category_id => 1,
  :sub_category_id => 2,
  :blog_service_name => "livedoor",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "FC2 / サッカー",
  :url =>      "http://blog.fc2.com/subgenre/250/",
  :category_id => 1,
  :sub_category_id => 1,
  :blog_service_name => "fc2",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "Ameba / サッカー",
  :url =>      "http://ranking.ameba.jp/gr_soccer",
  :category_id => 1,
  :sub_category_id => 1,
  :blog_service_name => "Ameba",
  :max_register_count => 25
)


BlogRankPage.create(
  :title =>    "ライブドア / 野球",
  :url =>      "http://blog.livedoor.com/category/8/",
  :feed_url => "http://blog.livedoor.com/xml/blog_ranking_cat8.rdf",
  :category_id => 2,
  :sub_category_id => 1,
  :blog_service_name => "livedoor",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "ライブドア / 野球まとめ",
  :url =>      "http://blog.livedoor.com/category/445/",
  :feed_url => "http://blog.livedoor.com/xml/blog_ranking_cat445.rdf",
  :category_id => 2,
  :sub_category_id => 2,
  :blog_service_name => "livedoor",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "FC2 / 野球",
  :url =>      "http://blog.fc2.com/subgenre/249/",
  :category_id => 2,
  :sub_category_id => 1,
  :blog_service_name => "fc2",
  :max_register_count => 25
)

BlogRankPage.create(
  :title =>    "Ameba / 野球",
  :url =>      "http://ranking.ameba.jp/gr_baseball",
  :category_id => 2,
  :sub_category_id => 1,
  :blog_service_name => "Ameba",
  :max_register_count => 25
)

# サイト
# 
=begin
Site.create(
  :title => "BLOGOS 政治",
  :url => "http://blogos.com/genre/politics/",
  :feed_url => "http://blogos.com/feed/article_pickup/politics/",
  :category_id => 0,
  :sub_category_id => 0,
  :rank => nil
)

Site.create(
  :title => "BLOGOS 経済・社会",
  :url => "http://blogos.com/genre/economy/",
  :feed_url => "http://blogos.com/feed/article_pickup/economy/",
  :category_id => 0,
  :sub_category_id => 0,
  :rank => nil
)

Site.create(
  :title => "しんぶん赤旗",
  :url => "http://www.jcp.or.jp/akahata/",
  :feed_url => "http://www.jcp.or.jp/akahata/aik13/index.rdf",
  :category_id => 0,
  :sub_category_id => 0,
  :rank => nil
)

Site.create(
  :title => "政経ch",
  :url => "http://fxya.blog129.fc2.com/",
  :feed_url => "http://fxya.blog129.fc2.com/?xml",
  :category_id => 0,
  :sub_category_id => 2,
  :rank => nil
)


Site.create(
  :title => "サッカーキング",
  :url => "http://www.soccer-king.jp/news",
  :feed_url => "http://www.soccer-king.jp/RSS.rdf",
  :category_id => 1,
  :sub_category_id => 0,
  :rank => nil
)

Site.create(
  :title => "Goal.com",
  :url => "http://www.goal.com/jp/",
  :feed_url => "http://www.goal.com/jp/feeds/news?fmt=rss&ICID=HP",
  :category_id => 1,
  :sub_category_id => 0,
  :rank => nil
)

Site.create(
  :title => "スポーツナビ/サッカー",
  :url => "http://sportsnavi.yahoo.co.jp/sports/soccer/headlines/",
  :feed_url => "http://sportsnavi.yahoo.co.jp/sports/soccer/headlines/rss",
  :category_id => 1,
  :sub_category_id => 0,
  :rank => nil
)

Site.create(
  :title => "スポーツナビ＋ サッカー日本代表",
  :url => "http://www.plus-blog.sportsnavi.com/centric/soccer_japan",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/soccer_japan/rss2_0.xml",
  :category_id => 1,
  :sub_category_id => 1
)

Site.create(
  :title => "スポーツナビ＋ Jリーグ",
  :url => "http://www.plus-blog.sportsnavi.com/centric/jleague",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/jleague/rss2_0.xml",
:category_id => 1,
:sub_category_id => 1
)

Site.create(
  :title => "スポーツナビ＋ サッカーワールドカップ",
  :url => "http://www.plus-blog.sportsnavi.com/centric/soccer_wcup",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/soccer_wcup/rss2_0.xml",
:category_id => 1,
:sub_category_id => 1
)

Site.create(
  :title => "スポーツナビ＋ 欧州サッカー",
  :url => "http://www.plus-blog.sportsnavi.com/centric/eusoccer",
  :feed_url => "http://www.plus-blog.sportsnavi.com/feed/centric/eusoccer/rss2_0.xml",
:category_id => 1,
:sub_category_id => 1
)

=end
