# The `Expander` module is responsible for taking an array of intents or utterances,
# and expanding any strings containing the following tokens:
#
#     {I|we} heard you {love|hate} computers
#
# into the following Cartesian product:
#
#     I heard you love computers
#     I heard you hate computers
#     we heard you love computers
#     we heard you hate computers
#
# This greatly reduces the complexity of creating performant speech interfaces.
module Expando
  module Expander
    # Find all text enclosed within parentheses.
    EXPANSION_TOKEN_REGEX = /(?<!\\)\((.*?)\)/
    # Find any line beginning with a '#' as its first non-whitespace character.
    COMMENT_REGEX = /^\s*#/

    module_function

    # Generate a new `Expander`.
    #
    # @param [Array<String>] lines The text to scan and expand.
    # @return [Array] The expanded text.
    def expand!( lines )
      expanded_lines = []

      # Ignore any commented lines
      lines.reject! { |line| line.match(COMMENT_REGEX) }

      lines.each do |line|
        expansion_tokens = line.scan EXPANSION_TOKEN_REGEX

        # Don't perform expansion if no expansion tokens are present.
        if expansion_tokens.empty?
          expanded_lines << line
          next
        end

        # For each set of expansion tokens, create an array of all the tokenized
        # values contained within the parentheses, separated by `|`.
        expanded_tokens = []
        expansion_tokens.each_with_index do |token, index|
          expanded_tokens[index] = token[0].split( '|' )
        end

        # Produce Cartesian product of all tokenized values.
        token_product = expanded_tokens[ 0 ].product( *expanded_tokens[ 1..-1 ] )

        # For each combination of tokenized values...
        token_product.each do |replacement_values|
          expanded_line = line

          # For each individual tokenized value...
          replacement_values.each do |value|
            # ...replace the first location of an expansion token in the line with
            # the replacement tokenized expansion value.
            expanded_line = expanded_line.sub(EXPANSION_TOKEN_REGEX, value )
          end

          # TODO: Replace multiple spaces with a single space
          expanded_lines << expanded_line.strip
        end
      end

      expanded_lines
    end
  end
end
