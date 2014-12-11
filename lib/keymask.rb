# Keymask Gem
# 2014 Arthur Ketcham - GoWatchIt.com
#
# What: To ensure certain attributes are removed from a data structure
#   (such as a JSON API response body), instead of hard-coding complex
#   hash manipulations, this allows you to specifiy a set of "rules",
#   which will be used to filter out matching attributes by thier keys.
#
# How: You will provide a hash of blacklist rules. The keys being a
#   human-readable description, and the values being the rules.
#   rules need to be strings in a specific format. As an example:
#   A rule of {"My Rule" => "*.bar"} will remove the element key with "bar"
#   from
#     {"foo"=>{"bar"=>[1,2,3]},
#      "yoo"=>{"bar"=>100, "baz"=>100}
#     }
#   producing the result: {"foo"=>{}, "yoo"=>{"baz"=>100}}
#
#   In the rules, a dot (.) separates each level. The final item must
#   be a string matching a key. (support for symbol keys is TODO later)
#   Multiple rules in the rule hash are fine.
#   Anything left of the final item can be a string, "*", or "$".
#    "*" means to match any key at that level.
#    "$" means to apply rules to each element in an array.
#
#   {"Remove foo from all items"=>"$.foo"} will transform:
#     [{"foo"=>4, "bar"=>8}, {"foo"=>16, "bar"=>0}, {"foo"=>[1,2,3], "tar"=>{...}}]
#   into
#     [{"bar"=>8}, {"bar"=>0}, {"tar"=>{...}}]
#
# But wait there's more:
#   This gem also adds two methods to Hash and Array:
#   * #keymask(ruleset) Returns a copy of self, with the ruleset applied
#   * #keymask!(ruleset) Performs ruleset on self, returning result. (faster)
#
class Keymask
  require "keymask_methods"

  def set_rules(rules_hash)
    begin
      @rules = parse_rules(rules_hash)
    rescue => e
      raise ArgumentError, "Error: Keymask rules are broken. #{e.message}"
    end
    true
  end

  def filter(data)
    raise "Keymask rules must be set first. Try set_rules()" if @rules.nil?
    keymask_filter_deep(data, @rules)
  end

  private

  # A method to recursively delete keys in a JSON-style hash, matching a MongoDB-style dot-notation blacklist string
  def keymask_filter_deep(subject, rules, verbose = false)
    # Rules are in the format: {"Label" => "*.$.foo.bar"} # "*": any key, "$": all child elements, apply to foo's children,
    # delete "bar" attr ("*.$.foo.bar" is the rulechain, and "bar" is the last rule. Only keys matching the last rule are deleted)

    case subject
      when Array
        # Edit each element, applying blacklist recursively
        # '$' means apply later rules to all child elements
        deep_rulechains = rules.select{|k,v| v.shift == '$'} # Shift + Discard all rules missing a "$" on this level
        deep_rulechains.each do |label, rulechain|
          next if rulechain.empty?
          subject.map!{|child_elem| child_elem.kind_of?(Enumerable) ? keymask_filter_deep(child_elem, {label => rulechain.dup}) : child_elem }
          # Always do rulechain.dup to avoid inner recursion from modifying the values of the outer hash (hash values are passed by reference)
        end

      when Hash
        rules.each do |label, rulechain|
          next if rulechain.empty? || rulechain.nil?
          rule_key = rulechain.shift

          if ['*', '$'].include?(rule_key)
            subject.each{|k,v| subject[k] = keymask_filter_deep(v, {label => rulechain.dup}) if v.kind_of? Enumerable }

          elsif subject.has_key?(rule_key) && subject[rule_key].kind_of?(Enumerable) && !rulechain.empty?
            subject[rule_key] = keymask_filter_deep(subject[rule_key], {label => rulechain.dup})

          else
            if subject.delete(rule_key)
              puts "Applying blacklist rule #{label} with #{rule_key}." if verbose
            end
          end

        end

    end
    subject
  end

  # Transforms rule values to an array. E.g. {foo => 'x.y.z'} to {foo => ['x','y','z']}
  def parse_rules(rules_hash)
    rules_hash.each_with_object({}) {|(k, v), hash| hash[k] = v.split('.')}
  end

end
