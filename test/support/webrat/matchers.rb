# Monkey patch for Nokogiri changes - https://github.com/sparklemotion/nokogiri/issues/2469
module Webrat
  module Matchers
    class HaveSelector
      def query
        Nokogiri::CSS.parse(@expected.to_s).map do |ast|
          if ::Gem::Version.new(Nokogiri::VERSION) < ::Gem::Version.new('1.18')
            ast.to_xpath('//', Nokogiri::CSS::XPathVisitor.new)
          else
            ast.to_xpath(Nokogiri::CSS::XPathVisitor.new)
          end
        end.first
      end
    end
  end
end
