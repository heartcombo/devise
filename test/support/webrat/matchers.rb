# Monkey patch for Nokogiri changes - https://github.com/sparklemotion/nokogiri/issues/2469
module Webrat
  module Matchers
    class HaveSelector
      def query
        Nokogiri::CSS.parse(@expected.to_s).map do |ast|
          ast.to_xpath("//", Nokogiri::CSS::XPathVisitor.new)
        end.first
      end
    end
  end
end