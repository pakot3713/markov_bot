マルコフ連鎖で簡単な文章を自動で生成する、いわゆる人工無能スクリプト。

マルコフ連鎖の説明はひとまず置いといて、処理の内容は以下のとおり。

(1)MeCab(形態素解析用ライブラリ)で文章を分かち書きし、単語ごとに分割する。MeCabすごい。
(2)ある単語と、その1つ前の単語・2つ前の単語からデータベースを作成する。
　 前2つの単語から次に続く単語を推定する2階のマルコフ連鎖となる。
　 データベース生成の処理は無駄が多く、時間がかかる。
　 文頭・文末はそれぞれ記号で表記する。
(3)データベースから文章を生成する。文頭記号から文生成を初めて文末記号にたどり着くまで続けるから、文章は長くなったり短くなったリ。140字以上ならやり直しする。

文生成の結果

https://twitter.com/toshino_bot

(VPS上で動かしたいけどRubyの環境が合わなくてあきらめた。)

上のbotでは、ゆるゆりのSSを千数百話分収集し、キャラクターごとに抽出した発言(約4MB分)を元に生成した文章の例。
いかにも人工無能っぽい意味の通らない文章ができた。
