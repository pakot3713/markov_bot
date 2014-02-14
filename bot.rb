# -*- coding: utf-8 -*-
require 'MeCab'
require 'rubygems'
require 'sqlite3'
require 'twitter'

#Twitterのトークンの設定
TWITTER_ACCESS_TOKEN = ""
TWITTER_ACCESS_TOKEN_SECRET = ""
TWITTER_CONSUMER_KEY = ""
TWITTER_CONSUMER_SECRET = ""

class Markov_table
  def initialize(name)
    @name = name
    @sentense = ""
  end

#文章中の記号の表記ゆらぎを統一
  def replace_word(line)
    line.gsub!(/(<.+>)/, "")
    line.gsub!(/(…+)/,"…")
    line.gsub!(/(・・・+)/,"…")
    line.gsub!(/([ 　]+)/,"")
    line.gsub!(/(\(.+\))/,"\1")
    line.gsub!(/\/\/\/+/,"///")
    line.gsub!(/ー+/,"ー")
    line.gsub!(/。/,"")
    line.gsub!(/、/,"")
  end

#MeCabで分かち書きさせる
  def wakachigaki(line)
    mecab = MeCab::Tagger.new
    nodes = mecab.parseToNode(line)
    word_list = []
    while nodes do
      if nodes.surface != "" then
        word_list.push(nodes.surface.force_encoding("UTF-8"))
      end
      nodes = nodes.next
    end
    return word_list
  end

#文章からマルコフ連鎖のテーブルを作成
  def make_table
    f = open("#{@name}.dat","r")
    db = SQLite3::Database.new("#{@name}.db")
    sql_make_table = <<SQL
    create table Markov_table (
        first_word text,
        second_word text,
        third_word text
    );
SQL
    sql_add_words = "insert into Markov_table values (?, ?, ?)"
    db.execute(sql_make_table)
    f.each do |l|
      replace_word(l)
      word_list = wakachigaki(l)
      #文頭は"BEGIN"で表す
      db.execute(sql_add_words,"BEGIN",word_list[0],word_list[1])
      word_list.each_cons(3) do |w1,w2,w3|
        db.execute(sql_add_words,w1,w2,w3)
      end
      #文末は"END"で表す
      db.execute(sql_add_words,word_list.last(2)[0],word_list.last(2)[1],"END")
    end
    db.close
    f.close
  end

#マルコフ連鎖テーブルから文の生成
  def make_sentense
    if !File.exist?("#{@name}.db") then
      make_table()
    end
    db = SQLite3::Database.new("#{@name}.db")
    w_list = db.execute("select * from Markov_table where first_word=='BEGIN'")
    w_s = w_list[rand(w_list.size)]
    while w_s[2] != "END" do
      w_list = db.execute("select * from Markov_table where first_word==? AND second_word==?",w_s[1],w_s[2])
      w_s = w_list[rand(w_list.size)]
      @sentense += w_s[0]
    end
    return @sentense + w_s[1]
  end
end


class Twitter_bot
  def initialize(name)
    @name = name
    @twitter_post = Twitter::REST::Client.new do |conf|
      conf.consumer_key = TWITTER_CONSUMER_KEY
      conf.consumer_secret = TWITTER_CONSUMER_SECRET
      conf.access_token = TWITTER_ACCESS_TOKEN
      conf.access_token_secret = TWITTER_ACCESS_TOKEN_SECRET
    end
  end
  def post_sentense()
    pt = Markov_table.new(@name)
    sentense = ""
    loop do
      sentense = pt.make_sentense()
      if sentense != nil && sentense.size <= 140 then break end
    end
    @twitter_post.update(sentense)
  end
end

tw = Twitter_bot.new("") #filename
tw.post_sentense()
    
