require 'thread'

class PrefixTrie
  attr_reader :root_node

  class Node
    attr_accessor :children
    attr_accessor :word
    attr_accessor :top_searches_below
    attr_accessor :frequency

    TOP_SEARCHS = 15

    def initialize()
      @children = {}
      @word = nil
      @top_searches_below = []
      @frequency = 0
    end
  end

  def initialize(all_strings)
    @uuid = SecureRandom.base64
    @root_node = Node.new
    redis_uri = URI.parse(ENV["REDISTOGO_URL"])
    @redis_publish = Redis::Namespace.new("sf_movies:prefixtrie", :redis => Redis.new(url: redis_uri))
    @redis_subscribe = Redis::Namespace.new("sf_movies:prefixtrie", :redis => Redis.new(url: redis_uri))
    subsribe_redis_to_change
    @lock = Mutex.new

    @lock.synchronize do
      all_strings.each do |string|
        insert string
      end
      build_top_searches @root_node
    end
  end

  def subsribe_redis_to_change
    Thread.new do
      @redis_subscribe.subscribe("prefixtriechange") do |on|
        on.message do |channel, message|
          word, new_freq, uuid = JSON.load message
          update_frequency(word, new_freq) if uuid != @uuid
        end
      end
    end
  end

  def publish_change(word, new_freq)
    data = [ word, new_freq, @uuid ]
    @redis_publish.publish("prefixtriechange", "#{data.to_json}")
  end

  def is_word(string)
    @lock.synchronize do
      node = find_node string
      return false if !node
      node.word
    end
  end

  def top_searches(string)
    @lock.synchronize do
      node = find_node string
      return [] if !node
      words = []
      node.top_searches_below.each do |child|
        words << child.word
      end
      words
    end
  end

  def add_frequency(string, plus_frequency)
    @lock.synchronize do
      update_frequency_helper(string, 0, @root_node) do |node|
        node.frequency += plus_frequency
        publish_change(node.word, node.frequency)
      end
    end
  end

  def update_frequency(string, updated_frequency)
    @lock.synchronize do
      update_frequency_helper(string, 0, @root_node) do |node|
        node.frequency = updated_frequency
      end
    end
  end

private 
  def insert(string)
    temp = @root_node
    string.split("").each do |ch|
      ch.downcase!
      unless temp.children.key? ch
        newNode = Node.new
        temp.children[ch] = newNode
      end
      temp = temp.children[ch]
    end
    temp.word = string
  end

  def update_frequency_helper(string, level, node, &update_block)
    if level < string.length
      update_frequency_helper(string, level + 1, node.children[string[level].downcase], &update_block)
    else
      yield node
    end
    top_searches = []
    if node.word
      top_searches << node
    end
    node.children.each do |ch, child|
      top_searches += child.top_searches_below
    end
    top_searches.sort! do |a, b|
      b.frequency <=> a.frequency
    end
    node.top_searches_below = top_searches.first Node::TOP_SEARCHS
  end

  def build_top_searches(node)
    top_searches = []
    if node.word
      top_searches << node
    end
    node.children.each do |ch, child|
      build_top_searches(child)
      top_searches += child.top_searches_below
    end
    top_searches.sort! do |a, b|
      b.frequency <=> a.frequency
    end
    node.top_searches_below = top_searches.first Node::TOP_SEARCHS
  end

  def find_node(string)
    temp = @root_node
    string.split("").each do |ch|
      ch.downcase!
      return nil unless temp.children.key? ch
      temp = temp.children[ch]
    end
    temp
  end
end
