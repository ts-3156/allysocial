class Location
  def initialize(text)
    @text = text
  end

  def text
    @text || ''
  end

  JAPAN_KEYWORDS = '[Jj]apan|[Nn]ihon|[Nn]ippon|日本|にほん'

  def japan?
    text.match?(Regexp.new(JAPAN_KEYWORDS))
  end

  def self.japan(model)
    model.where(%Q(location regexp "#{JAPAN_KEYWORDS}"))
  end

  KANTO_KEYWORDS = '[Kk]anto|関東|かんとう|[Tt]okyo|東京都?|とうきょう|[Ii]baraki|茨城県?|いばらき|[Tt]o(chi|ti)gi|栃木県?|とちぎ|[Gg]unma|群馬県?|ぐんま|[Ss]aitama|埼玉県?|さいたま|([Cc]hi|[Tt]i)ba|千葉県?|ちば|[Kk]anagawa|神奈川県?|かながわ'

  def kanto?
    text.match?(Regexp.new(KANTO_KEYWORDS))
  end

  def self.kanto(model)
    model.where(%Q(location regexp "#{KANTO_KEYWORDS}"))
  end

  def tokyo?
    tokyo_23ku? || tokyo_yamanote?
  end

  def self.tokyo(model)
    tokyo_23ku(model).or(tokyo_yamanote(model))
  end

  TOKYO_23KU_KEYWORDS = '[Tt]okyo|東京都?|とうきょう|千代田区?|ちよだく?|中央区|ちゅうおうく|港区|みなとく|新宿区?|しんじゅくく?|文京区?|ぶんきょうく?|台東区?|たいとうく?|墨田区?|すみだく?|江東区?|こうとうく?|品川区?|しながわく?|目黒区?|めぐろく?|大田区?|おおたく?|世田谷区?|せたがやく?|渋谷区?|しぶやく?|中野区?|なかのく?|杉並区?|すぎなみく?|豊島区?|とよしまく?|北区|きたく|荒川区?|あらかわく?|板橋区?|いたばしく?|練馬区?|ねりまく?|足立区?|あだちく?|葛飾区?|かつしかく?|江戸川区?|えどがわく?'

  def tokyo_23ku?
    text.match?(Regexp.new(TOKYO_23KU_KEYWORDS))
  end

  def self.tokyo_23ku(model)
    model.where(%Q(location regexp "#{TOKYO_23KU_KEYWORDS}"))
  end

  TOKYO_YAMANOTE_KEYWORDS = '池袋|上野|秋葉原|神田|有楽町|品川|大崎|五反田|目黒|恵比寿|渋谷|原宿|代々木|新宿|新大久保|高田馬場'

  def tokyo_yamanote?
    text.match?(Regexp.new(TOKYO_YAMANOTE_KEYWORDS))
  end

  def self.tokyo_yamanote(model)
    model.where(%Q(location regexp "#{TOKYO_YAMANOTE_KEYWORDS}"))
  end
end
