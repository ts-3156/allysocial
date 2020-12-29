class NattoClient

  URL_REGEXP = %r{(https?://)[\w/.\-]+}

  def count_words(text, min_word_length: 2, min_count: 2, debug: false)
    text = text.remove(URL_REGEXP).remove(/\0/).gsub(/\n/, ' ')

    truncated_text = truncate_text(text)
    puts truncated_text.inspect if debug

    parsed = parse(truncated_text)
    puts parsed.inspect if debug

    words = parsed.map { |p| extract_noun(p) }.compact
    puts words.inspect if debug

    words_count = words.each_with_object(Hash.new(0)) { |word, memo| memo[word] += 1 }

    words_count.each do |word, count|
      if word.include?(' ') ||
        word.match?(/^(\p{hiragana}){2}$/) ||
        word.length < min_word_length ||
        count < min_count
        words_count.delete(word)
      end
    end

    words_count.sort_by { |_, v| -v }.to_h
  end

  private

  def parse(text)
    dicdir = `#{ENV['MECAB_CONFIG'] || 'mecab-config'} --dicdir`.chomp + '/mecab-ipadic-neologd/'
    Natto::MeCab.new(dicdir: dicdir).parse(text).split("\n").map { |l| l.split("\t") }
  end

  MAX_BYTESIZE = 40.kilobytes

  def truncate_text(text)
    while text.bytesize > MAX_BYTESIZE do
      text = text.truncate(text.size * 0.9, omission: '')
    end
    text
  end

  def extract_noun(parsed)
    parsed[0] if (parsed[1] && !parsed[1].match?(/^(助詞|助動詞|記号)/))
  end
end
