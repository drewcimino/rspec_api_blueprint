unless ''.respond_to?(:indent)
  class String
    def indent(count, char = ' ')
      gsub(/([^\n]*)(\n|$)/) do |match|
        String.new.tap do |line|
          last_iteration = ($1 == "" && $2 == "")
          line << (char * count) unless last_iteration
          line << $1
          line << $2
        end
      end
    end
  end
end
