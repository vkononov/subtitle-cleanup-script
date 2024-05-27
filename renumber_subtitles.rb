#!/usr/bin/env ruby

require 'fileutils'

# Special characters
SPACE = ' '.freeze
APOSTROPHE = 'â'.freeze
PARAGRAPH_MARK = '¶'.freeze
MUSIC_NOTE = '♪'.freeze
DASH = '-'.encode('utf-8')
EM_DASH = '—'.encode('utf-8')
ELLIPSES = '…'.encode('utf-8')

MIN_LINES_PER_BLOCK = 3

begin
  BLACKLIST_FILE = File.join(File.dirname(__FILE__), 'blacklist.txt')
  BLACKLIST_STRINGS = File.readlines(BLACKLIST_FILE).map { |line| line.chomp.downcase }
rescue Errno::ENOENT
  puts "Could not find the file: #{BLACKLIST_FILE}"
  exit
rescue StandardError => e
  puts "An error occurred: #{e.message}"
  exit
end

def renumber_srt_files(path)
  if File.directory?(path)
    Dir.chdir(path)
    srt_files = Dir.glob(File.join('**/*.srt'))
  elsif !File.exist?(path)
    puts 'Error: The provided path does not exist.'
    return
  elsif File.extname(path) != '.srt'
    puts 'Error: The provided file is not an SRT file.'
    return
  else
    srt_files = [path]
  end

  total_files = srt_files.size
  processed_files = 0

  srt_files.each do |file|
    puts "Processing file #{file}"
    content = File.read(file).encode('utf-8', invalid: :replace).strip

    content = content.encode('utf-8')

    blocks = content.split(/\s*\n\s*\n+\s*/)

    # remove text from each block that represents ads, or subtitle handles, or website urls
    blocks.reject!.each_with_index do |block, index|
      downcased_block = block.downcase
      contains_forbidden_text = BLACKLIST_STRINGS.any? { |string| downcased_block.include?(string) }
      too_few_lines = block.lines.count < MIN_LINES_PER_BLOCK
      if contains_forbidden_text || too_few_lines
        puts "REJECTED BLOCK #{index + 1}:\n===============\n#{block}\n===============\n\n"
      end
      contains_forbidden_text || too_few_lines
    end

    # clean up dashes
    blocks = blocks.map do |block|
      block = block.gsub(APOSTROPHE, "'")
      block = block.gsub(SPACE, ' ')
      block = block.gsub(PARAGRAPH_MARK, MUSIC_NOTE) # Replace paragraph mark with music note
      block = block.gsub(/#{DASH}#{DASH}(?!>)/, EM_DASH) # replace two dashes by an em dash
      block = block.gsub(/^#{DASH}/, "#{DASH} ") # add space after a dash at beginning of line
      block = block.gsub(/^#{EM_DASH}/, "#{EM_DASH} ") # add space after an em dash at beginning of line
      block = block.gsub(/#{EM_DASH}$/, " #{EM_DASH}") # add space before an em dash at end of line
      block = block.gsub(' .', '.').gsub(' :', ':').gsub(' ;', ';').gsub(' ?', '?').gsub(' !', '!') # remove extra spaces before punctuation
      block = block.gsub(/(?<=\(|\{|\[)\s+|\s+(?=\)|\}|\])/, '') # remove space within brackets
      block = block.squeeze(' ') # compress multiple empty spaces into one
      block = block.gsub(/[[:space:]]+$/, '') # remove empty spaces at the end of each line
      block = block.gsub(/#{ELLIPSES}$/, '...') # add space before an em dash at end of line
      block = block.gsub('..', '...') # change double periods to ellipses (3 periods)
      block = block.gsub(/\.{4,}/, '...') # change too many periods to ellipses (3 periods)
      block = block.gsub(%r{<font[^>]*>|</font>}, '') # remove <font> tags
      block = block.gsub(/(\.)(?=[A-Z](?!\w*\.\w*))/, '\1 ') # Add a missing space after . except in version numbers of domains
      block = block.gsub(/([?!])([A-Z0-9])/i, '\1 \2') # Add a missing space after ?! followed by a letter or a number
      block = block.gsub(/(?<!\s|\[)\[(.*?)\]/, ' [\1]') # add missing spaces before square brackets

      # Trim spaces before and after each line
      block = block.lines.map(&:strip).join("\n")

      block
    end

    renumbered_blocks = blocks.map.with_index(1) do |block, index|
      block.gsub!(/\A\D*/, '') # assume the block starts with a number and delete preceding invisible characters
      block.gsub(/\A\d+\s*$/, index.to_s).chomp # Add the index at the beginning of each block
    end

    renumbered_content = "#{renumbered_blocks.join("\n\n")}\n"
    File.write(file, renumbered_content)

    processed_files += 1
  end

  puts "Processed #{processed_files}/#{total_files} files."
end

path = ARGV[0]
renumber_srt_files(path)
