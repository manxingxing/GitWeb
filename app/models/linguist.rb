# -*- coding: utf-8 -*-
class Linguist
  CONFIG_FILE = File.join Rails.root, 'config', 'languages.yml'
  LANGUAGES = YAML.load(File.open(CONFIG_FILE)).with_indifferent_access
  LANGUAGE_ATTRS = LANGUAGES.map {|k,v| v.keys }.flatten.uniq.map(&:to_sym)

  Language = Struct.new(*LANGUAGE_ATTRS)

  class << self
    def [] name
      LANGUAGES.each do |key, value|
        return Language.new(*value.values_at(*LANGUAGE_ATTRS)) if key.downcase == name.downcase
      end
    end

    alias :get []
  end

  def initialize path
    @filename = File.basename path
    @extname = File.extname @filename
    @language = detect_language
  end

  attr_reader :language

private
  def detect_language
    LANGUAGES.each do |key, value|
      if (value["extensions"] && value["extensions"].include?(@extname)) or
         (value["filenames"]  && value["filenames"].include?(@filename))
        return Language.new(*value.values_at(*LANGUAGE_ATTRS))
      end
    end
    # fall back to Plain Text
    self.class.get('Text')
  end
end
