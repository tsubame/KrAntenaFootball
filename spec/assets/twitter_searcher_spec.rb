# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/twitter_searcher'

describe TwitterSearcher do
  
  subject do
    TwitterSearcher.new
  end
 
  
  describe :search_twitter do
    context "文字列を渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do
        q = "ジュビロ"
        #res = subject.search_twitter(q)
        #res.size.should >= 1
        subject.error?.should == false
      end    
    end
    
    context "不正なURLを渡した時" do
      it "エラーがないこと" do
        q = "http://30000000022222"
        #res = subject.search_twitter(q)
        #subject.error?.should == false
      end    
    end
    
    context "文字列以外を渡した時" do
      it "戻り値がfalseであること" do        
        q = nil
        #res = subject.search_twitter(q)
        #res.should == false
        #subject.error?.should == true
        
        q = ""
        #res = subject.search_twitter(q)
        #res.should == false
        #subject.error?.should == true
      end    
    end
  end
  
  describe :search_twitter_parallel do
    context "キーワードを10個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        keywords = ["ジュビロ", "柿谷", "セレッソ", "レイソル", "田中", "TJ", "ネイマール", "大谷", "山田大記", "カカー", "ゴラッソ"]
  
        #res = subject.search_twitter_parallel(keywords)
        #res.size.should >= 1        
        subject.error?.should == false        
      end      
    end
    
    context "URLを11個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        urls = [
          "http://gendai.ismedia.jp/articles/-/37036",
          "http://japan.digitaldj-network.com/articles/18235.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000015-sanspo-ent",
          "http://atmatome.jp/u/vamonos_pest/3y2mv1y/",
          "http://zasshi.news.yahoo.co.jp/article?a=20130921-00000011-pseven-ent",
          "http://lifehack2ch.livedoor.biz/archives/51457477.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000096-spnannex-ent",
          "http://www.4gamer.net/games/234/G023417/20130921011/",
          "http://www.4gamer.net/games/233/G023374/20130921007/",
          "http://alfalfalfa.com/archives/6824587.html",
          "http://www.nikkei.com/article/DGXZZO59970440Q3A920C1000000/"
        ]  

        #res = subject.search_twitter_parallel(urls)
        #res.size.should >= 1        
        #subject.error?.should == false
      end      
    end
  end
  
  describe :search_twitter_parallel_limited do   
    context "URLを11個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        urls = [
          "http://gendai.ismedia.jp/articles/-/37036",
          "http://japan.digitaldj-network.com/articles/18235.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000015-sanspo-ent",
          "http://atmatome.jp/u/vamonos_pest/3y2mv1y/",
          "http://zasshi.news.yahoo.co.jp/article?a=20130921-00000011-pseven-ent",
          "http://lifehack2ch.livedoor.biz/archives/51457477.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000096-spnannex-ent",
          "http://www.4gamer.net/games/234/G023417/20130921011/",
          "http://www.4gamer.net/games/233/G023374/20130921007/",
          "http://alfalfalfa.com/archives/6824587.html",
          "http://www.nikkei.com/article/DGXZZO59970440Q3A920C1000000/"
        ]  
        res = {}
        #res = subject.search_twitter_parallel_limited(urls)
        #res.size.should >= 1        
        #subject.error?.should == false
        
        res.each do |key, value|
          #puts ""; puts key
          #value.each do |c|
          #  p c
          #end
        end
        
      end      
    end
  end
  
  describe :search_twitter_without_rt do   
    it "戻り値の配列のサイズが0ではなく、エラーがない" do  
      
      q = "上原"
      q = "http://headlines.yahoo.co.jp/hl?a=20130921-00000083-spnannex-base"
      #res = subject.search_twitter_without_rt(q)
      subject.error?.should == false
    end
  end
  
  describe :get_tw_comments_to_entry do
    it "戻り値の配列のサイズが0ではなく、エラーがない" do  
      entries = []
      entry = Entry.new
      entry.id = 1
      entry.title = "【速報】アスナとシャナが格ゲーで戦う!? 電撃文庫の人気キャラによる対戦格闘『電撃文庫 FIGHTING CLIMAX』が発表！【TGS2013】"
      entry.url   = "http://dengekionline.com/elem/000/000/715/715326/"
      #entries << entry
      entry = Entry.new
      entry.title = "【ステラ女学院高等科C3部】BD1巻の特典(BB弾)は使用しない方がいい模様｜オタク.com"
      entry.url   = "http://0taku.livedoor.biz/archives/4539476.html"
      #entries << entry
      entry = Entry.new
      entry.title = "朝日新聞デジタル：国産の全ゲーム保存計画　ファミコンからプレステまで - カルチャー"
      entry.url   = "http://www.asahi.com/culture/update/0921/OSK201309210002.html"
      entries << entry
      entry = Entry.new
      entry.title = "
      ［TGS 2013］伊藤賢治氏，光田康典氏，下村陽子氏が，旧スクウェア時代の思い出を語った「スクウェア・エニックス コンポーザー スペシャルトークショウ」をレポート - 4Gamer.net"

      entry.url = "http://www.4gamer.net/games/999/G999903/20130922005/"
      entries << entry
      
      entries.each do |entry|
        comments, rt_tweets = subject.get_tw_comments_to_entry(entry)
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
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/mkN2ykXuPD",
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） http://t.co/U7pTZYlDLX",
          "“週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］” http://t.co/qg6LS5LN1G",
          "“週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］” http://t.co/AFswn0lPG3 #life
          他25コメント http://t.co/u2FDj4R4MI",
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/C7IFtNcRFW",
          "http://t.co/Jvou7uLJtf",
          "“@MultipleTi: 週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/5D6W10uFou”",
          "【担当記事】週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/ES0b1kmnc6",
          "【見てるー(・∀・)】週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） http://t.co/objBR0gC8A",
          "“週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］” http://t.co/DowJgyJuXQ
          他7コメント http://t.co/aVMLnqiUA5",
          "“週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］” http://t.co/AFswn0lPG3 #life 他25コメント http://t.co/u2FDj4R4MI",
          "週末をより幸福に楽しむためのヒント（そして、平日も週末みたいに楽しくする方法） : ライフハッカー［日本版］ http://t.co/ln44oOvQqh by http://t.co/kzL0xnl5kq"
        ]
        
        expected = false
        
        texts.each do |text|
          comment = subject.pickup_comment_from_tweet(text, entry_title)
          comment.should == expected
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
          comment = subject.pickup_comment_from_tweet(text, entry_title)
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
