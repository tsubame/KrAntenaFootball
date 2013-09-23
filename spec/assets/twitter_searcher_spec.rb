# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/twitter_searcher'

describe TwitterSearcher do
  
  subject do
    TwitterSearcher.new
  end
 
  
  describe :is_tweet_not_entry_text? do
    it "返り値がexpectedと同じであること" do
      tweet_text = "物価水準の違いを調整した為替水準「実質実効為替レート」で、日本円は約30年ぶりの安値をつけた。だが、産業別にみると風景は大きく違う。自動車など輸送用機械は競争力が伸びているが、電気機械産業は韓国との競争で苦戦――。http://nikkei.com/article/DGXNZO60069060T20C13A9NN1000/ …"
      entry_title = "産業別競争力格差くっきり　実質実効為替レート　　：日本経済新聞"
      entry_text = "物価水準の違いを調整した為替水準「実質実効為替レート」で、日本円は約30年ぶりの安値をつけた。だが、産業別にみると風景は大きく違う。自動車など輸送用機械は競争力が伸びているが、電気機械産業は韓国との競争で苦戦――。産業別の実質レートという新指標を使うと、産業..."
      expected = false
      
      comment = subject.pickup_comment_from_tweet(tweet_text, entry_title)
      res = subject.is_tweet_not_entry_text?(comment, entry_text)
      res.should == expected
    end
  end
  
  describe :get_tw_comments_to_entry do
    it "戻り値の配列のサイズが0ではなく、エラーがない" do  
      entries = []
      entry = Entry.new
      entry.title = "【朗報】iOS7の「超天才的な使い方」が発見される（画像あり）ｗｗｗｗｗｗｗｗｗｗｗｗｗｗｗ"
      entry.url   = "http://alfalfalfa.com/archives/6826781.html"
      entries << entry
      entry = Entry.new
      entry.title = "産業別競争力格差くっきり　実質実効為替レート　　：日本経済新聞"
      entry.url = "http://www.nikkei.com/article/DGXNZO60069060T20C13A9NN1000/"
      entry.description = "物価水準の違いを調整した為替水準「実質実効為替レート」で、日本円は約30年ぶりの安値をつけた。だが、産業別にみると風景は大きく違う。自動車など輸送用機械は競争力が伸びているが、電気機械産業は韓国との競争で苦戦――。産業別の実質レートという新指標を使うと、産業..."
      #entries << entry
      
      entry = Entry.new
      entry.title = "【艦これ】艦隊これくしょん／リアル劇場【IL-2】 ‐ ニコニコ動画:Q"
      entry.url   = "http://www.nicovideo.jp/watch/sm21892733"
      entries << entry
      
      entries.each do |entry|
        comments = subject.get_tw_comments_to_entry(entry)
        subject.error?.should == false
        
        comments.each_with_index do |c, i|
          puts "#{i} #{c.text}"
        end
      end

    end
  end
  
  
  # 開発中  
  
  describe :pickup_comment_from_tweet do
    context "コメントなしのツイートを渡した時" do
      it "戻り値がfalseであること" do  
        entry_title = "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］"
        
        texts = [
          "“週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］” http://t.co/AFswn0lPG3 #life 他25コメント http://t.co/u2FDj4R4MI",
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/ln44oOvQqh by http://t.co/kzL0xnl5kq"
        ]
        
        expected = false
        
        texts.each do |text|
          #comment = subject.pickup_comment_from_tweet(text, entry_title)
          #comment.should == expected
        end

      end
    end
      
    context "【】が先頭に来るコメントなしのツイートを渡した時" do
      it "戻り値がfalseであること" do  
        entry_title = "【速報】アスナとシャナが格ゲーで戦う!? 電撃文庫の人気キャラによる対戦格闘『電撃文庫 FIGHTING CLIMAX』が発表！【TGS2013】"
          
          texts = [
            "【速報】アスナとシャナが格ゲーで戦う!? 電撃文庫の人気キャラによる対戦格闘『電撃文庫 FIGHTING CLIMAX』が発表！【TGS2013】 http://dengekionline.com/elem/000/000/715/715326/ … @dengekionlineさんから",
            ""
          ]
        
        expected = false
        
        texts.each do |text|
          comment = subject.pickup_comment_from_tweet(text, entry_title)
          comment.should == expected
        end

      end
    end
    
    context "コメントありのツイートを渡した時" do
      it "戻り値がexpectedsと同じであること" do  
        entry_title = "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］"
        
        texts = [
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/fQfo6ptscD これは思い当たることが多すぎてグサグサきた。 #fb",
          "良い仕事に恵まれている人は、週末にそれほど喜びを感じない。 / “週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］” http://t.co/AdFw1QEtEF",
          "簡単な方に流れていっているな、俺。｜週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/nA96xLggQQ",
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/Ghu4jpEw5v　結局どうすればいいかこれもうわかんねえな",
        ]
        
        expecteds = [
          "これは思い当たることが多すぎてグサグサきた。",
          "良い仕事に恵まれている人は、週末にそれほど喜びを感じない。",
          "簡単な方に流れていっているな、俺。",
          "結局どうすればいいかこれもうわかんねえな"
        ]
        
        texts.each_with_index do |text, i|
          #comment = subject.pickup_comment_from_tweet(text, entry_title)
          #comment.should == expecteds[i]
        end

      end
      
      it "戻り値がexpectedsと同じであること ニコニコ動画(原宿)" do  
        entry_title = "PS4版アイドルマスター　お願い！シンデレラPV ‐ ニコニコ動画(原宿)"
        p split_titles = subject.split_title(entry_title)
        texts = [
          "PS4版アイドルマスター　お願い！シンデレラPV (3:04) http://nico.ms/sm21873154  #sm21873154　エキプロやめろｗｗｗｗｗ",
          "【マイリスト】PS4版アイドルマスター　お願い！シンデレラPV http://nico.ms/sm21873154  #sm21873154"
         ]
        
        expecteds = [
          "エキプロやめろｗｗｗｗｗ",
          false
        ]
        
        texts.each_with_index do |text, i|
          #p comment = subject.pickup_comment_from_tweet(text, entry_title, split_titles)
          #comment.should == expecteds[i]
        end
      end
      
      it "戻り値がexpectedsと同じであること スクエニ" do  
        entry_title = "【朗報】iOS7の「超天才的な使い方」が発見される（画像あり）ｗｗｗｗｗｗｗｗｗｗｗｗｗｗｗ"
        p split_titles = subject.split_title(entry_title)
        texts = [
          ": 【朗報】iOS7の「超天才的な使い方」が発見される（画像あり）ｗｗｗｗｗｗｗｗｗｗｗｗｗｗｗ http://alfalfalfa.com/archives/6826781.html … 天才現る、これはスゴイ",
         ]
        
        expecteds = [
          "天才現る、これはスゴイ"
        ]
        
        texts.each_with_index do |text, i|
          p comment = subject.pickup_comment_from_tweet(text, entry_title, split_titles)
          comment.should == expecteds[i]
        end
    
      end
      
    end

  end
  
  describe :split_title do
    it "戻り値がexpectedsと同じであること" do  
      title = "【速報】アスナとシャナが格ゲーで戦う!? 電撃文庫の人気キャラによる対戦格闘『電撃文庫 FIGHTING CLIMAX』が発表！【TGS2013】"
        
      expecteds = [
          "【速報】アスナとシャナが格ゲーで戦う!? 電撃文庫の人気キャラによる対戦格闘『電撃文庫 FIGHTING CLIMAX』が発表！【TGS2013】",
          "電撃文庫の人気キャラによる対戦格闘『電撃文庫",
          "CLIMAX』が発表！【TGS2013】",
          "【速報】アスナとシャナが格ゲーで戦う!?",
          "FIGHTING",
         ]
      
      titles = subject.split_title(title)
      titles.should == expecteds
      
      titles.each_with_index do |part_title, i|
        part_title.should == expecteds[i]
      end
    end
    
    it "戻り値がexpectedsと同じであること lifeハッカー" do  
      title = "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］"
      expecteds = [
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］",
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法）",
          "ライフハッカー［日本版］",
         ]
      
      titles = subject.split_title(title)
      titles.should == expecteds
      
      titles.each_with_index do |part_title, i|
        part_title
        part_title.should == expecteds[i]
      end
    end
  end
  
  
=begin  
  describe :get_tw_comments_parallel_limited do   
    context "URLを11個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        entries = []
        entry = Entry.new
        entry.id = 1
        entry.title = "楽天・田中が開幕２２勝 ３３年ぶり　NHKニュース"
        entry.url   = "http://www3.nhk.or.jp/news/html/20130921/k10014718301000.html"
        entries << entry
        entry = Entry.new
        entry.id = 2
        entry.title = "史上最悪の核爆発 かろうじて免れる　NHKニュース"
        entry.url   = "http://www3.nhk.or.jp/news/html/20130921/k10014718221000.html"
        entries << entry
        entry = Entry.new
        entry.id = 3
        entry.title = "【速報】アスナとシャナが格ゲーで戦う!? 電撃文庫の人気キャラによる対戦格闘『電撃文庫 FIGHTING CLIMAX』が発表！【TGS2013】"
        entry.url   = "http://dengekionline.com/elem/000/000/715/715326/"
        entries << entry
          
        res = {}
        res = subject.get_tw_comments_parallel_limited(entries)
        res.size.should >= 1        
        subject.error?.should == false
        
        #comments.each_with_index do |c, i|
        #  puts "#{i} #{c.text}"
        #end
        
        res.each do |key, value|
          puts ""; puts key
          value.each_with_index do |c, i|
            puts "#{i} #{c.text}"
          end
        end
        
      end      
    end
  end

=begin 
  describe :pickup_comment_tweets do   
    it "戻り値の配列のサイズが0ではなく、エラーがない" do  
      q = "http://headlines.yahoo.co.jp/hl?a=20130921-00000083-spnannex-base"
      q = "http://dengekionline.com/elem/000/000/715/715326/"
      q = "http://allabout.co.jp/gm/gc/428214/"
      q = "http://alfalfalfa.com/archives/6824587.html"
      res = subject.search_twitter_without_rt(q)


      comments, no_comments = subject.pickup_comment_tweets(res)
      subject.error?.should == false
      
      comments.each do |c|
        p c.text
      end
      
      puts "------------"
      
      texts = []
      no_comments.each do |c|
        texts << c.text
      end
      texts = texts.sort do |a, b|
        b.size <=> a.size
      end
      
      texts.each_with_index do |t, i|
        texts[i] = t.strip
        texts[i] = texts[i].gsub(/[　\n]+/, "")
        p t
      end
      
      puts "------------"
       
      # ツイートの件数ループ
      comments.each do |c|
        c.text = c.text.strip
        c.text = c.text.gsub(/[　\n]+/, "")
        texts.each do |str|
          c.text = c.text.sub(str, "")
        end
        c.text = c.text.strip
        c.text = c.text.gsub(/[　\n]+/, "")
        p c.text
      end
    end
  
  end
=end  
 
end
