class PrefixTrie
  attr_reader :root_node

  class Node
    attr_accessor :children
    attr_accessor :word
    attr_accessor :top_searches_below
    attr_accessor :frequency

    TOP_SEARCHS = 100

    def initialize()
      @children = {}
      @word = nil
      @top_searches_below = []
      @frequency = 0
    end
  end

  def initialize(all_strings)
    @root_node = Node.new
    all_strings.each do |string|
      insert string
    end
    build_top_searches @root_node
  end

  def is_word(string)
    node = find_node string
    return false if !node
    node.word
  end

  def top_searches(string)
    node = find_node string
    return [] if !node
    strings = []
    node.top_searches_below.each do |child|
      strings << child.word
    end
    strings
  end

  def update_frequency(string, plus_frequency)
    update_frequency_helper(string, 0, @root_node, plus_frequency)
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

  def update_frequency_helper(string, level, node, plus_frequency)
    if level < string.length
      update_frequency_helper(string, level + 1, node.children[string[level].downcase], plus_frequency)
    else
      node.frequency += plus_frequency
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